public with sharing class sfab_ObjectRelationshipDescriber {

    public class ParentRelationshipObjectCannotBeAutoCreatedException extends Exception {}

    static Map<String,SingleObjectRelationshipDescriber> SingleObjectRelationshipDescribers = new Map<String,SingleObjectRelationshipDescriber>();

    public Boolean objectHasParentRelationshipNamed( String objectName, String relationshipName ) {
        ensureSingleObjectRelationshipDescriberIsInitialised( objectName );
        return getRelationshipDescriber( objectName ).hasParentRelationshipNamed( relationshipName );
    }

    public sfab_FabricatedSObject buildFabricatedObjectForRelationship( String objectName, String relationshipName ) {
        ensureSingleObjectRelationshipDescriberIsInitialised( objectName );
        return getRelationshipDescriber( objectName ).buildFabricatedObjectForRelationship( relationshipName );
    }

    public void ensureSingleObjectRelationshipDescriberIsInitialised( String objectName ) {
        if ( ! SingleObjectRelationshipDescribers.containsKey( objectName ) ) {
            SingleObjectRelationshipDescribers.put( objectName, new SingleObjectRelationshipDescriber( objectName ) );
        }
    }

    public SingleObjectRelationshipDescriber getRelationshipDescriber( String objectName ) {
        return SingleObjectRelationshipDescribers.get( objectName );
    }

    public class SingleObjectRelationshipDescriber {

        private String objectName;

        private Map<String,ParentRelationship> parentRelationships {
            get {
                if ( parentRelationships == null ) {
                    parentRelationships = new Map<String,ParentRelationship>();

                    Map<String,SObjectField> fields = Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap();

                    for ( SObjectField thisField : fields.values() ) {

                        ParentRelationship relationship = new ParentRelationship()
                                                                .setChildObjectName( objectName )
                                                                .setFieldDescribe( thisField.getDescribe() );
                        if ( relationship.isValid() ) {
                            parentRelationships.put( relationship.getName(), relationship );
                        }
                    }
                }
                return parentRelationships;
            }
            set;
        }

        public SingleObjectRelationshipDescriber( String objectName ) {
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

        public String getName() {
            return fieldDescribe.getRelationshipName();
        }

        public String getFullName() {
            return childObjectName + '.' + getName();
        }

        public String getFieldName() {
            return fieldDescribe.getName();
        }

        public String getTargetObjectType() {
            if ( !isValid() ) {
                return null;
            }
            return fieldDescribe.getReferenceTo()[0].getDescribe().getName();
        }

        public sfab_FabricatedSObject buildFabricatedObject() {
            if ( isPolymorphic() ) {
                throw new ParentRelationshipObjectCannotBeAutoCreatedException( 'Cannot automatically create a Fabricated Object for the relationship ' + getFullName() + ' as it is polymorphic and so not possible to automatically ascertain which SObject to use' );
            }
            return new sfab_FabricatedSObject( Type.forName( getTargetObjectType() ) );
        }

        public Boolean isValid() {
            return fieldDescribe?.getReferenceTo()?.size() > 0;
        }

        private Boolean isPolymorphic() {
            return fieldDescribe.getReferenceTo().size() > 1;
        }
    }
}