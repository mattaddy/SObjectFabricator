public virtual class sfab_FabricatedSObject {

    private Type sType;
    @testVisible private Map<String,sfab_FabricatedSObjectNode> nodes = new Map<String,sfab_FabricatedSObjectNode>();

    sfab_ObjectDescriber objectDescriber = new sfab_ObjectDescriber();

    public class FieldDoesNotExistException extends Exception {}
    public class ParentRelationshipDoesNotExistException extends Exception {}
    public class ChildRelationshipDoesNotExistException extends Exception {}

    public class FieldIsNotSimpleFieldException extends Exception {}
    public class FieldIsNotParentRelationshipException extends Exception {}
    public class FieldIsNotChildRelationshipException extends Exception {}

    public class FieldIsADifferentTypeException extends Exception {}

    public class ParentRelationshipObjectCannotBeAutoCreatedException extends Exception {}

    public class NodeNotSetException extends Exception {}

    /**
    * Constructs a FabricatedSObject of the given type.
    *
    * @param Type - The type of SObject to be fabricated (e.g. Contact.class)
    */
    public sfab_FabricatedSObject( Type sType ) {
        this.sType = sType;
    }

    /**
    * Constructs a FabricatedSObject of the given type, and then sets the fields specified in the given map.
    *
    * @param Type - The type of SObject to be fabricated (e.g. Contact.class)
    * @param Map<Schema.SObjectField,Object> - The fields to set on this object, with the desired values
    */
    public sfab_FabricatedSObject( Type sType, Map<Schema.SObjectField, Object> fields ) {
        this(sType);
        set(fields);
    }

    /**
    * Constructs a FabricatedSObject of the given type, and then sets the fields and relationships specified in the given map.
    *
    * Example valid field / relationship names:
    *   * Name
    *   * Account
    *   * Account.Name
    *   * Opportunities
    *   * Account.Opportunities
    *   * Account.Owner.Contact.FirstName
    *
    * @param Type - The type of SObject to be fabricated (e.g. Contact.class)
    * @param Map<String,Object> - The fields and relationships to set on this object, with the desired values
    */
    public sfab_FabricatedSObject(Type sType, Map<String, Object> fields) {
        this(sType);
        set(fields);
    }

    @testVisible
    protected sfab_FabricatedSObject( Type sType, List<sfab_FabricatedSObjectNode> nodes ) {
        this.sType = sType;
        this.nodes = new Map<String,sfab_FabricatedSObjectNode>();
        for ( sfab_FabricatedSObjectNode node : nodes ) {
            setNode( node.getName(), node );
        }
    }

    /**
    * Set the specified field to the specified value.
    *
    * Note: Only fields on this object's type may be set.  Only the 'name' of the field is used and expected results may
    * occur if you attempt to pass a field on a different object.
    *
    * @param Schema.SObjectField - The field to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject set( Schema.SObjectField field, Object value) {
        return setField( field, value );
    }

    /**
    * Set the specified field / relationship to the specified value.
    *
    * Example valid field / relationship names:
    *   * Name
    *   * Account
    *   * Account.Name
    *   * Opportunities
    *   * Account.Opportunities
    *   * Account.Owner.Contact.FirstName
    *
    * @param String - The field or relationship to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject set( String fieldName, Object value ) {

        // This looks like it duplicates the overloading of 'set', but unfortunately Apex determines the method to call
        // based on the static type of a parameter rather than the dynamic type.
        // I.E. if a passed parameter's value is declared as 'Object' it will always call the 'Object'
        // defined version of an overloaded method even when a more specific type matches for a given value.
        // This means that 'setParentField' will always call this version of the overloaded method regardless
        // of the contents of the value parameter.  So we need to manually check the instance type in the code.
        if ( value instanceOf List<sfab_FabricatedSObject> ) {
            return setChildren( fieldName, (List<sfab_FabricatedSObject>)value );
        }

        if ( value instanceOf sfab_FabricatedSObject ) {
            return setParent( fieldName, (sfab_FabricatedSObject)value );
        }

        return setField( fieldName, value );
    }

    /**
    * Set the specified parent relationship to the specified sfab_FabricatedSObject
    *
    * Is a more specific version of set( String fieldName, Object value )
    * Is a synonym of setParent( String relationshipName, sfab_FabricatedSObject fabricatedParent )
    *
    * @param String - The relationship to set
    * @param sfab_FabricatedSObject - The object that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject set( String relationshipName, sfab_FabricatedSObject fabricatedParent ) {
        return setParent( relationshipName, fabricatedParent );
    }

    /**
    * Set the specified child relationship to the specified list of sfab_FabricatedSObject
    *
    * Is a more specific version of set( String fieldName, Object value )
    * Is a synonym of setChildren( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren )
    *
    * @param String - The relationship to set
    * @param List<sfab_FabricatedSObject> - The objects that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject set( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren ) {
        return setChildren( relationshipName, fabricatedChildren );
    }

    /**
    * Add the specified sfab_FabricatedSObject to the specified child relationship, setting it as an empty list to start
    * if it does not already exist
    *
    * Is a synonym of addChild( String relationshipName, sfab_FabricatedSObject fabricatedChild )
    *
    * @param String - The relationship to set
    * @param sfab_FabricatedSObject - The object to add to the child relationship's list
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject add( String relationshipName, sfab_FabricatedSObject fabricatedChild ) {
        return addChild( relationshipName, fabricatedChild );
    }

    /**
    * Set the specified field, which exists directly on this object, to the specified value.
    *
    * @param Schema.SObjectField - The field to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject set( Map<Schema.SObjectField, Object> fields ) {
        for ( Schema.SObjectField field : fields.keySet() ) {
            setField( field, fields.get( field ) );
        }
        return this;
    }

    /**
    * Set the specified fields and relationships to the specified values.
    *
    * Example valid field / relationship names:
    *   * Name
    *   * Account
    *   * Account.Name
    *   * Opportunities
    *   * Account.Opportunities
    *   * Account.Owner.Contact.FirstName
    *
    * @param Map<String,Object> - The fields / relationships to set (indexes), and the values to set them to.
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    *
    */
    public sfab_FabricatedSObject set( Map<String, Object> fields ) {
        for (String fieldName : fields.keySet()) {
            Object value = fields.get( fieldName );
            set( fieldName, fields.get(fieldName) );
        }
        return this;
    }

    /**
    * Set the specified field, which exists directly on this object, to the specified value.
    *
    * Is a synonym of set( Schema.SObjectField field, Object value )
    *
    * @param Schema.SObjectField - The field to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setField( Schema.SObjectField field, Object value ) {
        return setDirectField( field.getDescribe().getName(), value );
    }

    /**
    * Set the specified field, which may be directly on this object or on a parent, to the specified value.
    *
    * Is a more specific version of set( String fieldName, Object value )
    *
    * @param String - The field to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setField( String fieldName, Object value ) {
        if ( new sfab_FieldNameSplitter( fieldName ).isAParentNavigation() ) {
            return setParentField( fieldName, value );
        }
        return setDirectField( fieldName, value );
    }

    /**
    * Set the specified parent relationship to the specified sfab_FabricatedSObject
    *
    * Is a more specific version of set( String fieldName, Object value )
    * Is a synonym of set( String relationshipName, sfab_FabricatedSObject fabricatedParent )
    *
    * @param String - The relationship to set
    * @param sfab_FabricatedSObject - The object that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setParent( String relationshipName, sfab_FabricatedSObject fabricatedParent ) {
        if ( new sfab_FieldNameSplitter( relationshipName ).isAParentNavigation() ) {
            return setParentField( relationshipName, fabricatedParent );
        }
        return setDirectParent( relationshipName, fabricatedParent );
    }

    /**
    * Set the specified child relationship to the specified list of sfab_FabricatedSObject
    *
    * Is a more specific version of set( String fieldName, Object value )
    * Is a synonym of set( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren )
    *
    * @param String - The relationship to set
    * @param List<sfab_FabricatedSObject> - The objects that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setChildren( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren ) {
        if ( new sfab_FieldNameSplitter( relationshipName ).isAParentNavigation() ) {
            return setParentField( relationshipName, fabricatedChildren );
        }
        return setDirectChildren( relationshipName, fabricatedChildren );
    }

    /**
    * Add the specified sfab_FabricatedSObject to the specified child relationship, setting it as an empty list to start
    * if it does not already exist
    *
    * Is a synonym of add( String relationshipName, sfab_FabricatedSObject fabricatedChild )
    *
    * @param String - The relationship to set
    * @param sfab_FabricatedSObject - The object to add to the child relationship's list
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject addChild( String relationshipName, sfab_FabricatedSObject fabricatedChild ) {

        if ( new sfab_FieldNameSplitter( relationshipName ).isAParentNavigation() ) {
            addParentChild( relationshipName, fabricatedChild );
        } else {
            childFieldIsChildRelationship( relationshipName );
            checkTypeIsValidForChildRelationship( relationshipName, fabricatedChild );
            if ( !nodeExists( relationshipName ) ) {
                setNode( relationshipName, new sfab_ChildRelationshipNode( relationshipName ) );
            }
            getChildRelationshipNode( relationshipName ).addChild( fabricatedChild );
        }
        return this;
    }

    /**
    * Builds the SObject that this sfab_FabricatedSObject represents
    *
    * @return SObject - The built SObject
    */
    public SObject toSObject() {
        SObject newObject = (SObject)JSON.deserialize(JSON.serialize(serialize()), sType);
        postBuildProcess( newObject );
        return newObject;
    }

    /**
    * An internal method that should not be called directly.
    * Is public because of the requirement to call it from other outer classes within the library
    */
    public void postBuildProcess( SObject objectToProcess ) {
        for ( String nodeName : nodes.keySet() ) {
            nodes.get( nodeName ).postBuildProcess( objectToProcess );
        }
    }

    /**
    * Internal method that should not be called directly.
    */
    public virtual Map<String, Object> serialize() {
        Map<String, Object> fields = new Map<String, Object>();
        for (sfab_FabricatedSObjectNode node : nodes.values()) {
            fields.putAll(node.serialize());
        }
        return fields;
    }

    /**
    * Returns a String representation of the name of the SObject Type that this sfab_FabricatedSObject represents
    *
    * @return String - The name of the SObject Type
    */
    public String getSobjectName() {
        return String.valueOf( sType );
    }

    /**
    * Given a field name, will split it into its parent and child references, checking that the parent relatioonship
    * exists and defaulting the field to an empty version of the appropriate object.
    *
    * @param String - The name of the field to split and defaul
    * @return Map<String,String> - The
    */
    private sfab_FieldNameSplitter defaultParentField( String fieldName ) {

        sfab_FieldNameSplitter fieldNameSplitter = new sfab_FieldNameSplitter( fieldName );
        String parentFieldName = fieldNameSplitter.getParentFieldName();

        checkFieldIsParentRelationship( parentFieldName );

        if ( ! nodeExists( parentFieldName ) ) {
            try {
                set( parentFieldName, objectDescriber.buildFabricatedObjectForRelationship( getSobjectName(), parentFieldName ) );
            } catch ( Exception e ) {
                throw new ParentRelationshipObjectCannotBeAutoCreatedException( 'Could not auto-assign an object for the field ' + fieldName + ': ' + e.getMessage() );
            }
        }

        return fieldNameSplitter;
    }

    /**
    * Set the specified field, which exists directly on this object, to the specified value.
    *
    * Is a more specific version of set( String fieldName, Object value )
    *
    * @param String - The field to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    private sfab_FabricatedSObject setDirectField( String fieldName, Object value ) {

        Schema.SobjectField theField = objectDescriber.getField( getSObjectName(), fieldName );

        if ( theField == null ) {

            if ( objectDescriber.objectHasParentRelationshipNamed( getSobjectName(), fieldName ) ) {
                throw new FieldIsNotSimpleFieldException( 'The field '+ getSobjectName() +'.' + fieldName + ' cannot to set to a primitive, it is a parent relationship field' );
            }

            if ( objectDescriber.objectHasChildRelationshipNamed( getSObjectName(), fieldName ) ) {
                throw new FieldIsNotSimpleFieldException( 'The field '+ getSobjectName() +'.' + fieldName + ' cannot to set to a primitive, it is a child relationship field' );
            }

            throw new FieldDoesNotExistException( 'The field ' + getSobjectName() + '.' + fieldName + ' does not exist' );
        }

        return setNode( fieldName, new sfab_FieldValuePairNode( theField, value ) );
    }

    /**
    * Set the specified parent relationship, which is directly on the current object
    * to the specified sfab_FabricatedSObject
    *
    * @param String - The relationship to set
    * @param sfab_FabricatedSObject - The object that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    private sfab_FabricatedSObject setDirectParent( String relationshipName, sfab_FabricatedSObject fabricatedParent ) {
        checkFieldIsParentRelationship( relationshipName );
        checkTypeIsValidForParentRelationship( relationshipName, fabricatedParent );
        return setNode( relationshipName, new sfab_ParentRelationshipNode(relationshipName, fabricatedParent));
    }

    /**
    * Set the specified child relationship, which is directly on the current object
    * to the specified list of sfab_FabricatedSObject
    *
    * @param String - The relationship to set
    * @param List<sfab_FabricatedSObject> - The objects that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    private sfab_FabricatedSObject setDirectChildren( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren ) {
        childFieldIsChildRelationship( relationshipName );
        checkTypeIsValidForChildRelationship( relationshipName, fabricatedChildren );
        return setNode( relationshipName, new sfab_ChildRelationshipNode( relationshipName, fabricatedChildren ) );
    }

    /**
    * Internal method that should not be called directly.
    * Ensures that the field on the parent record specified in the field name is set to the specified value
    */
    private sfab_FabricatedSObject setParentField( String fieldName, Object value ) {
        sfab_FieldNameSplitter fields = defaultParentField( fieldName );
        getParentRelationshipNode( fields.getParentFieldName() ).set( fields.getChildFieldName(), value );
        return this;
    }

    /**
    * Internal method that should not be called directly.
    * Ensures that the child relationship on the parent record specified in the field name has the specified object added
    */
    private sfab_FabricatedSObject addParentChild( String fieldName, sfab_FabricatedSObject fabricatedChild ) {
        sfab_FieldNameSplitter fields = defaultParentField( fieldName );
        getParentRelationshipNode( fields.getParentFieldName() ).add( fields.getChildFieldName(), fabricatedChild );
        return this;
    }

    /**
    * Internal method that should not be called directly.
    * Checks that the specied node exists and is set to a value
    */
    private Boolean nodeExists( String nodeName ) {
        return nodes.containsKey( nodeName );
    }

    /**
    * Internal method that should not be called directly.
    * Sets the specified node to the specified value
    */
    private sfab_FabricatedSObject setNode( String nodeName, sfab_FabricatedSObjectNode node ) {
        nodes.put( nodeName, node );
        return this;
    }

    /**
    * Internal method that should not be called directly.
    * Gets the current value of the specified node, throwing an excepton if it is not set
    */
    private sfab_FabricatedSObjectNode getNode( String nodeName ) {
        if ( ! nodeExists( nodeName ) ) {
            throw new NodeNotSetException( 'Attempt to get the value of node "' + nodeName + '" when it was not set' );
        }
        return nodes.get( nodeName );
    }

    /**
    * Internal method that should not be called directly.
    * Gets value of the specified field node, throwing an excepton if it is not set to a sfab_FieldValuePairNode
    */
    private sfab_FieldValuePairNode getFieldNode( String fieldName ) {
        return ((sfab_FieldValuePairNode)getNode( fieldName ));
    }

    /**
    * Internal method that should not be called directly.
    * Gets value of the specified parent relationship node, throwing an excepton if it is not set to a sfab_ParentRelationshipNode
    */
    private sfab_ParentRelationshipNode getParentRelationshipNode( String relationshipName ) {
        return ((sfab_ParentRelationshipNode)getNode( relationshipName ));
    }

    /**
    * Internal method that should not be called directly.
    * Gets value of the specified parent relationship node, throwing an excepton if it is not set to a sfab_ChildRelationshipNode
    */
    private sfab_ChildRelationshipNode getChildRelationshipNode( String relationshipName ) {
        return ((sfab_ChildRelationshipNode)getNode( relationshipName ));
    }

    /**
    * Internal method that should not be called directly.
    * Gets the field value of the specified field.
    */
    @testVisible
    private Object getFieldValue( String fieldName ) {
        return getFieldNode( fieldName )?.getValue();
    }

    /**
    * Internal method that should not be called directly.
    * Gets the parent fabricated object of the specified parent relationship field
    */
    @testVisible
    private sfab_FabricatedSObject getParent( String relationshipName ) {
        return getParentRelationshipNode( relationshipName )?.getParent();
    }

    /**
    * Internal method that should not be called directly.
    * Gets the child fabricated objects of the specified child relationship field
    */
    @testVisible
    private List<sfab_FabricatedSObject> getChildren( String relationshipName ) {
        return getChildRelationshipNode( relationshipName )?.getChildren();
    }

    /**
    * Internal method that should not be called directly.
    * Gets the number of child fabricated objects held in the specified child relationship field
    */
    @testVisible
    private Integer getNumberOfChildren( String relationshipName ) {
        return getChildRelationshipNode( relationshipName )?.getNumberOfChildren();
    }

    /**
    * Internal method that should not be called directly.
    * Gets the total number of nodes (being fields and relationships) that are set on this object
    */
    @testVisible
    private Integer getNumberOfNodes() {
        return nodes.size();
    }

    /**
    * Internal method that should not be called directly.
    * Checks if the field with the given name is a parent relationship, throwing an exception if not
    */
    private void checkFieldIsParentRelationship( String parentFieldName ) {

        if ( !objectDescriber.objectHasParentRelationshipNamed( getSobjectName(), parentFieldName ) ) {
            if (  objectDescriber.objectHasSimpleFieldNamed( getSobjectName(), parentFieldName )
                || objectDescriber.objectHasChildRelationshipNamed( getSobjectName(), parentFieldName ) ) {
                throw new FieldIsNotParentRelationshipException( 'The field ' + getSobjectName() + '.' + parentFieldName + ' is not a parent relationship' );
            }

            throw new ParentRelationshipDoesNotExistException( 'The parent relationship ' + getSobjectName() + '.' + parentFieldName + ' does not exist' );
        }
    }

    /**
    * Internal method that should not be called directly.
    * Checks if the field with the given name is a parent relationship for an sobject of the same type as the given Fabricated SObject
    */
    // TODO: push into sfab_ParentRelationshipNode?
    private void checkTypeIsValidForParentRelationship( String relationshipName, sfab_FabricatedSObject fabricatedParent  ){
        List<String> validObjectTypes = objectDescriber.getObjectTypesForParentRelationship( getSobjectName(), relationshipName );
        if ( ! validObjectTypes.contains( fabricatedParent.getSobjectName() ) ) {
            throw new FieldIsADifferentTypeException( 'The field ' + getSobjectName() + '.' + relationshipName + ' is ' + String.join( validObjectTypes, ',' ) + ', not ' + fabricatedParent.getSobjectName() );
        }
    }

    /**
    * Internal method that should not be called directly.
    * Checks if the field with the given name is a child relationship for an sobject of the same type as the given Fabricated SObject
    */
    // TODO: push into sfab_ChildRelationshipNode?
    private void checkTypeIsValidForChildRelationship( String relationshipName, sfab_FabricatedSObject fabricatedChild  ){
        String validObjectType = objectDescriber.getObjectTypeForChildRelationship( getSobjectName(), relationshipName );
        if ( validObjectType != fabricatedChild.getSobjectName() ) {
            throw new FieldIsADifferentTypeException( 'The relationship ' + getSobjectName() + '.' + relationshipName + ' is ' + validObjectType + ', not ' + fabricatedChild.getSobjectName() );
        }
    }

    /**
    * Internal method that should not be called directly.
    * Checks if the field with the given name is a child relationship for an sobject of the same type as the given Fabricated SObject
    */
    // TODO: push into sfab_ChildRelationshipNode?
    private void checkTypeIsValidForChildRelationship( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren  ){
        for ( sfab_FabricatedSObject thisChild : fabricatedChildren ) {
            checkTypeIsValidForChildRelationship( relationshipName, thisChild );
        }
    }

    /**
    * Internal method that should not be called directly.
    * Checks if the fields with the given name is a child relationship, throwing an exception if not
    */
    private void childFieldIsChildRelationship( String childRelationshipName ) {

        if ( !objectDescriber.objectHasChildRelationshipNamed( getSobjectName(), childRelationshipName ) ) {
            if (  objectDescriber.objectHasSimpleFieldNamed( getSobjectName(), childRelationshipName )
                || objectDescriber.objectHasParentRelationshipNamed( getSobjectName(), childRelationshipName ) ) {
                throw new FieldIsNotChildRelationshipException( 'The field ' + getSobjectName() + '.' + childRelationshipName + ' is not a child relationship' );
            }

            throw new ChildRelationshipDoesNotExistException( 'The child relationship ' + getSobjectName() + '.' + childRelationshipName + ' does not exist' );
        }
    }

    /**
    * Internal class that interprets a field name and determines
    * if it represents a parent.child specification
    */
    class sfab_FieldNameSplitter {

        private String fullFieldName;

        public sfab_FieldNameSplitter( String fullFieldName ) {
            this.fullFieldName = fullFieldName;
        }

        /**
        * Internal method that should not be called directly.
        * Returns the parent field component of the current field name
        */
        public String getParentFieldName() {
            return fullFieldName.substringBefore( '.' );
        }

        /**
        * Internal method that should not be called directly.
        * Returns the child field component of the current field name
        */
        public String getChildFieldName() {
            return fullFieldName.substringAfter( '.' );
        }

        /**
        * Internal method that should not be called directly.
        * States if the current field name represents a navigation to a parent field
        */
        public Boolean isAParentNavigation() {
            return fullFieldName.contains( '.' );
        }
    }
}