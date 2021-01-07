public with sharing class sfab_ObjectRelationshipDescriber {

    public class ParentRelationshipObjectCannotBeAutoCreatedException extends Exception {}
    public class ParentRelationshipDoesNotExistException extends Exception {}

    static Map<String,SingleObjectRelationshipDescriber> SingleObjectRelationshipDescribers = new Map<String,SingleObjectRelationshipDescriber>();

    public Boolean objectHasParentRelationshipNamed( String objectName, String relationshipName ) {
        ensureSingleObjectRelationshipDescriberIsInitialised( objectName );
        return getRelationshipDescriber( objectName )?.hasParentRelationshipNamed( relationshipName );
    }

    public sfab_FabricatedSObject buildFabricatedObjectForRelationship( String objectName, String relationshipName ) {

        if ( String.isEmpty( objectName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship because the object name has not been specified' );
        }

        if ( String.isEmpty( relationshipName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship because the relationship name has not been specified' );
        }

        ensureSingleObjectRelationshipDescriberIsInitialised( objectName );
        SingleObjectRelationshipDescriber relationshipDescriber = getRelationshipDescriber( objectName );

        if ( ! relationshipDescriber.objectExists() ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship ' + objectName + '.' + relationshipName + ' because the object type does not exist' );
        }
        if ( ! relationshipDescriber.hasParentRelationshipNamed( relationshipName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship ' + objectName + '.' + relationshipName + ' because the relationship does not exist' );
        }

        return relationshipDescriber.buildFabricatedObjectForRelationship( relationshipName );
    }

    private void ensureSingleObjectRelationshipDescriberIsInitialised( String objectName ) {
        if ( ! singleObjectRelationshipDescribers.containsKey( objectName ) ) {
            singleObjectRelationshipDescribers.put( objectName, new SingleObjectRelationshipDescriber( objectName ) );
        }
    }

    private SingleObjectRelationshipDescriber getRelationshipDescriber( String objectName ) {
        return singleObjectRelationshipDescribers.get( objectName );
    }

    private Boolean relationshipDescriberExists( String objectName ) {
        return singleObjectRelationshipDescribers.containsKey( objectName );
    }

    public class SingleObjectRelationshipDescriber {

        private String  objectName;

        Boolean fieldsInitialised = false;

        private Map<String,SObjectField> fields {
            get {
                if ( ! fieldsInitialised ) {
                    fieldsInitialised = true;
                    fields = Schema.getGlobalDescribe()
                                        ?.get( objectName )
                                        ?.getDescribe()
                                        ?.fields
                                        ?.getMap();
                }
                return fields;
            }
            set;
        }

        private Map<String,ParentRelationship> parentRelationships {
            get {
                if ( parentRelationships == null ) {
                    parentRelationships = new Map<String,ParentRelationship>();

                    if ( fields != null ) {
                        for ( SObjectField thisField : fields.values() ) {
                            ParentRelationship relationship = new ParentRelationship()
                                                                    .setChildObjectName( objectName )
                                                                    .setFieldDescribe( thisField.getDescribe() );
                            if ( relationship.isValid() ) {
                                parentRelationships.put( relationship.getName(), relationship );
                            }
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

        public Boolean objectExists() {
            return fields != null;
        }

        public Boolean hasParentRelationshipNamed( String relationshipName ) {
            return parentRelationships.containsKey( relationshipName );
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
            // more errors...
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