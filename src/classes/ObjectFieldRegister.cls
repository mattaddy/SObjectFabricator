public with sharing class ObjectFieldRegister {

    static Map<String,ObjectRelationshipDescriber> objectRelationshipDescribers = new Map<String,ObjectRelationshipDescriber>();

    public Boolean objectHasParentRelationshipNamed( String objectName, String relationshipName ) {
        ensureObjectRelationshipDescriberIsInitialised( objectName );
        return getRelationshipDescriber( objectName ).hasParentRelationshipNamed( relationshipName );
    }

    public sfab_FabricatedSObject buildFabricatedObjectForRelationship( String objectName, String relationshipName ) {
        ensureObjectRelationshipDescriberIsInitialised( objectName );
        return getRelationshipDescriber( objectName ).buildFabricatedObjectForRelationship( relationshipName );
    }

    public void ensureObjectRelationshipDescriberIsInitialised( String objectName ) {
        if ( ! objectRelationshipDescribers.containsKey( objectName ) ) {
            objectRelationshipDescribers.put( objectName, new ObjectRelationshipDescriber( objectName ) );
        }
    }

    public ObjectRelationshipDescriber getRelationshipDescriber( String objectName ) {
        return objectRelationshipDescribers.get( objectName );
    }

    public class ObjectRelationshipDescriber {

        private String objectName;

        private Map<String,ParentRelationship> parentRelationships {
            get {
                if ( parentRelationships == null ) {
                    parentRelationships = new Map<String,ParentRelationship>();

                    Map<String,SObjectField> fields = Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap();

                    for ( SObjectField thisField : fields.values() ) {
                        // push these describe examinations into ParentRelationship
                        // implement 'representable'
                        DescribeFieldResult fieldDescribe = thisField.getDescribe();
                        if ( fieldDescribe.getReferenceTo().size() == 1 ) {
                            parentRelationships.put( fieldDescribe.getRelationshipName(),
                                                    new ParentRelationship()
                                                        .setChildObjectName( objectName )
                                                        .setFieldDescribe( fieldDescribe ) );
                        }
                    }
                }
                return parentRelationships;
            }
            set;
        }

        public ObjectRelationshipDescriber( String objectName ) {
            this.objectName = objectName;
        }

        public Boolean hasParentRelationshipNamed( String relationshipName ) {
            return parentRelationships.containsKey( relationshipName );
        }

        public String getParentRelationshipFieldName( String relationshipName ) {
            return parentRelationships.get( relationshipName )?.getFieldName();
        }

        public String getParentRelationshipTargetType( String relationshipName ) {
            return parentRelationships.get( relationshipName )?.getTargetObjectType();
        }

        public sfab_FabricatedSObject buildFabricatedObjectForRelationship( String relationshipName ) {
            return parentRelationships.get( relationshipName )?.buildFabricatedObject();
        }
    }

    private class ParentRelationship {

        private String childObjectName;
        private Schema.DescribeFieldResult fieldDescribe;

        public ParentRelationship setFieldDescribe( Schema.DescribeFieldResult fieldDescribe ) {
            this.fieldDescribe = fieldDescribe;
            return this;
        }

        public ParentRelationship setChildObjectName( String childObjectName ) {
            this.childObjectName = childObjectName;
            return this;
        }

        public String getFieldName() {
            return fieldDescribe.getName();
        }

        public String getTargetObjectType() {
            return fieldDescribe.getReferenceTo()[0].getDescribe().getName();
        }

        public sfab_FabricatedSObject buildFabricatedObject() {
            return new sfab_FabricatedSObject( Type.forName( getTargetObjectType() ) );
        }
    }
}