public with sharing class sfab_ObjectDescriber {

    public class ParentRelationshipObjectCannotBeAutoCreatedException extends Exception {}
    public class ParentRelationshipDoesNotExistException extends Exception {}

    static Map<String,SingleObjectDescriber> singleObjectDescribers = new Map<String,SingleObjectDescriber>();

    public SobjectField getField( String objectName, String fieldName ) {
        ensureSingleObjectDescriberIsInitialised( objectName );
        return getObjectDescriber( objectName )?.getField( fieldName );
    }

    public Boolean objectHasSimpleFieldNamed( String objectName, String fieldName ) {
        ensureSingleObjectDescriberIsInitialised( objectName );
        return getObjectDescriber( objectName )?.hasSimpleFieldNamed( fieldName );
    }

    public Boolean objectHasParentRelationshipNamed( String objectName, String relationshipName ) {
        ensureSingleObjectDescriberIsInitialised( objectName );
        return getObjectDescriber( objectName )?.hasParentRelationshipNamed( relationshipName );
    }

    public List<String> getObjectTypesForParentRelationship( String objectName, String relationshipName ) {
        ensureSingleObjectDescriberIsInitialised( objectName );
        return getObjectDescriber( objectName )?.getValidObjectsForParentRelationship( relationshipName );
    }

    public Boolean objectHasChildRelationshipNamed( String objectName, String relationshipName ) {
        ensureSingleObjectDescriberIsInitialised( objectName );
        return getObjectDescriber( objectName )?.hasChildRelationshipNamed( relationshipName );
    }

    public String getObjectTypeForChildRelationship( String objectName, String relationshipName ) {
        ensureSingleObjectDescriberIsInitialised( objectName );
        return getObjectDescriber( objectName )?.getValidObjectForChildRelationship( relationshipName );
    }

    // TODO: should this actually be in FabricatedObject?  At this point we are no longer describing the object!
    public sfab_FabricatedSObject buildFabricatedObjectForRelationship( String objectName, String relationshipName ) {

        if ( String.isEmpty( objectName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship because the object name has not been specified' );
        }

        if ( String.isEmpty( relationshipName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship because the relationship name has not been specified' );
        }

        ensureSingleObjectDescriberIsInitialised( objectName );
        SingleObjectDescriber relationshipDescriber = getObjectDescriber( objectName );

        if ( ! relationshipDescriber.objectExists() ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship ' + objectName + '.' + relationshipName + ' because the object type does not exist' );
        }
        if ( ! relationshipDescriber.hasParentRelationshipNamed( relationshipName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'Cannot automatically create a Fabricated Object for the relationship ' + objectName + '.' + relationshipName + ' because the relationship does not exist' );
        }

        return relationshipDescriber.buildFabricatedObjectForRelationship( relationshipName );
    }

    private void ensureSingleObjectDescriberIsInitialised( String objectName ) {
        if ( ! singleObjectDescribers.containsKey( objectName ) ) {
            singleObjectDescribers.put( objectName, new SingleObjectDescriber( objectName ) );
        }
    }

    private SingleObjectDescriber getObjectDescriber( String objectName ) {
        return singleObjectDescribers.get( objectName );
    }

    public class SingleObjectDescriber {

        private String  objectName;

        Boolean fieldsInitialised = false;

        private Schema.DescribeSObjectResult objectDescribe {
            get {
                if ( objectDescribe == null ) {
                    objectDescribe = Schema.getGlobalDescribe()
                                        ?.get( objectName )
                                        ?.getDescribe();
                }
                return objectDescribe;
            }
            set;
        }

        private Map<String,SObjectField> fields {
            get {
                if ( ! fieldsInitialised ) {
                    fieldsInitialised = true;
                    fields = objectDescribe
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

        private Map<String,ChildRelationship> childRelationships {
            get {
                if ( childRelationships == null ) {

                    List<Schema.ChildRelationship> schemaRelationships = objectDescribe?.getChildRelationships();
                    if ( schemaRelationships == null ) {
                        return new Map<String,ChildRelationship>();
                    }

                    childRelationships = new Map<String,ChildRelationship>();

                    for( Schema.ChildRelationship thisSchemaChildRelationship : schemaRelationships ) {

                        ChildRelationship relationship = new ChildRelationship()
                                                                .setParentObjectName( objectName )
                                                                .setSchemaRelationship( thisSchemaChildRelationship );

                        if ( relationship.isValid() ) {
                            childRelationships.put( relationship.getName(), relationship );
                        }
                    }
                }
                return childRelationships;
            }
            set;
        }

        public SingleObjectDescriber( String objectName ) {
            this.objectName = objectName;
        }

        public Boolean objectExists() {
            return fields != null;
        }

        public Boolean hasFieldNamed( String fieldName ) {
            return objectExists() && fields.containsKey( fieldName );
        }

        public SObjectField getField( String fieldName ) {
            if ( ! hasFieldNamed( fieldName ) ) {
                return null;
            }
            return fields.get( fieldName );
        }

        public Boolean hasSimpleFieldNamed( String fieldName ) {
            return objectExists() && hasFieldNamed( fieldName ) && ! hasParentRelationshipNamed( fieldName ) && ! hasChildRelationshipNamed( fieldName );
        }

        public Boolean hasParentRelationshipNamed( String relationshipName ) {
            return objectExists() && parentRelationships.containsKey( relationshipName );
        }

        public Boolean hasChildRelationshipNamed( String relationshipName ) {
            return objectExists() && childRelationships.containsKey( relationshipName );
        }

        public List<String> getValidObjectsForParentRelationship( String relationshipName ) {
            if ( !hasParentRelationshipNamed( relationshipName ) ) {
                return new List<String>();
            }
            List<String> validObjects = getParentRelationshipNamed( relationshipName ).getTargetObjectTypes();
            validObjects.sort();
            return validObjects;
        }

        public String getValidObjectForChildRelationship( String relationshipName ) {
            if ( !hasChildRelationshipNamed( relationshipName ) ) {
                return null;
            }
            return getChildRelationshipNamed( relationshipName )?.getChildObjectType();
        }

        public sfab_FabricatedSObject buildFabricatedObjectForRelationship( String relationshipName ) {
            return getParentRelationshipNamed( relationshipName )?.buildFabricatedObject();
        }

        private ParentRelationship getParentRelationshipNamed( String relationshipName ) {
            return parentRelationships.get( relationshipName );
        }

        private ChildRelationship getChildRelationshipNamed( String relationshipName ) {
            return childRelationships.get( relationshipName );
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

        public List<String> getTargetObjectTypes() {

            if ( !isValid() ) {
                return new List<String>();
            }

            List<String> targetObjectTypes = new List<String>();
            for ( Schema.sObjectType thisReferenceTo : fieldDescribe.getReferenceTo() ) {
                targetObjectTypes.add( thisReferenceTo.getDescribe().getName() );
            }
            return targetObjectTypes;
        }

        public sfab_FabricatedSObject buildFabricatedObject() {
            if ( isPolymorphic() ) {
                throw new ParentRelationshipObjectCannotBeAutoCreatedException( 'Cannot automatically create a Fabricated Object for the relationship ' + getFullName() + ' as it is polymorphic and so not possible to automatically ascertain which SObject to use' );
            }
            return new sfab_FabricatedSObject( Type.forName( getTargetObjectTypes()[0] ) );
        }

        public Boolean isValid() {
            return fieldDescribe?.getReferenceTo()?.size() > 0;
        }

        private Boolean isPolymorphic() {
            return fieldDescribe.getReferenceTo().size() > 1;
        }
    }

    private class ChildRelationship {

        private Schema.ChildRelationship schemaRelationship;
        private String parentObjectName;

        public ChildRelationship setSchemaRelationship( Schema.ChildRelationship schemaRelationship ) {
            this.schemaRelationship = schemaRelationship;
            return this;
        }

        public ChildRelationship setParentObjectName( String parentObjectName ) {
            this.parentObjectName = parentObjectName;
            return this;
        }

        public String getParentObjectName() {
            return parentObjectName;
        }

        public String getFullName() {
            return parentObjectName + '.' + getName();
        }

        public String getName() {
            return schemaRelationship.getRelationshipName();
        }

        public String getChildObjectType() {
            return String.valueOf( schemaRelationship.getChildSObject() );
        }

        // Some don't have names - and if they don't have names they can't possibly be
        // set by the fabricator, so must be invalid.
        public Boolean isValid() {
            return getName() != null;
        }
    }
}