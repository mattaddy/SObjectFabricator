public virtual class sfab_FabricatedSObject {
    private Type sType;
    @testVisible private Map<String,sfab_FabricatedSObjectNode> nodes = new Map<String,sfab_FabricatedSObjectNode>();

    sfab_ObjectDescriber sfab_ObjectDescriber = new sfab_ObjectDescriber();

    public class FieldDoesNotExistException extends Exception {}
    public class ParentRelationshipDoesNotExistException extends Exception {}
    public class ParentRelationshipObjectCannotBeAutoCreatedException extends Exception {}

    /**
    * Constructs a FabricatedSObject of the given type.
    *
    * @param Type - The type of SObject to be fabricated (e.g. Contact.class)
    */
    public sfab_FabricatedSObject(Type sType) {
        this.sType = sType;
    }

    /**
    * Constructs a FabricatedSObject of the given type, and then sets the fields specified in the given map.
    *
    * @param Type - The type of SObject to be fabricated (e.g. Contact.class)
    * @param Map<Schema.SObjectField,Object> - The fields to set on this object, with the desired values
    */
    public sfab_FabricatedSObject(Type sType, Map<Schema.SObjectField, Object> fields) {
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

    @testVisible protected sfab_FabricatedSObject( Type sType, List<sfab_FabricatedSObjectNode> nodes ) {
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
        if ( fieldName.contains( '.' ) ) {
            return setParentField( fieldName, value );
        }

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
    * Is a more specific version of set(String fieldName, Object value)
    * Is a synonym of setParent(String relationshipName, sfab_FabricatedSObject fabricatedParent)
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
    * Is a more specific version of set(String fieldName, Object value)
    * Is a synonym of setChildren(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren)
    *
    * @param String - The relationship to set
    * @param List<sfab_FabricatedSObject> - The objects that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject set( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren ) {
        return setChildren( relationshipName, fabricatedChildren );
    }

    // TODO: document
    // TODO: test
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
        for (Schema.SObjectField field : fields.keySet()) {
            setField(field, fields.get(field));
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
    * Is a synonym of set(Schema.SObjectField field, Object value)
    *
    * @param Schema.SObjectField - The field to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setField(Schema.SObjectField field, Object value) {
        return setNode( field.getDescribe().getName(), new sfab_FieldValuePairNode(field, value));
    }

    /**
    * Set the specified field, which exists directly on this object, to the specified value.
    *
    * Is a more specific version of set(String fieldName, Object value)
    *
    * @param String - The field to set
    * @param Object - The value that the field should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setField( String fieldName, Object value ) {
        Schema.SobjectField theField = Schema.getGlobalDescribe()
                                                .get( getSobjectName() )
                                                ?.getDescribe()
                                                ?.fields
                                                ?.getMap()
                                                ?.get( fieldName );
        if ( theField == null ) {
            throw new FieldDoesNotExistException( 'The field ' + getSobjectName() + '.' + fieldName + ' does not exist' );
        }

        return setField( theField, value );
    }

    /**
    * Set the specified parent relationship to the specified sfab_FabricatedSObject
    *
    * Is a more specific version of set(String fieldName, Object value)
    * Is a synonym of set(String relationshipName, sfab_FabricatedSObject fabricatedParent)
    *
    * @param String - The relationship to set
    * @param sfab_FabricatedSObject - The object that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setParent(String relationshipName, sfab_FabricatedSObject fabricatedParent) {
        return setNode( relationshipName, new sfab_ParentRelationshipNode(relationshipName, fabricatedParent));
    }

    /**
    * Set the specified child relationship to the specified list of sfab_FabricatedSObject
    *
    * Is a more specific version of set(String fieldName, Object value)
    * Is a synonym of set(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren)
    *
    * @param String - The relationship to set
    * @param List<sfab_FabricatedSObject> - The objects that the relationship should be set to
    * @return sfab_FabricatedSObject - This, allowing for a fluent interface
    */
    public sfab_FabricatedSObject setChildren(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
        return setNode( relationshipName, new sfab_ChildRelationshipNode(relationshipName, fabricatedChildren));
    }

    // TODO: document
    // TODO: test
    public sfab_FabricatedSObject addChild( String relationshipName, sfab_FabricatedSObject fabricatedChild ) {

        // TODO: can this do some navigation down fields too?
        //
        // so we can: contact.add( 'Account.Opportunities', theOpportunity )
        //
        if ( !nodeExists( relationshipName ) ) {
            setNode( relationshipName, new sfab_ChildRelationshipNode( relationshipName ) );
        }
        // TODO: needs some protection that the node is a sfab_ChildRelationshipNode
        getChildRelationshipNode( relationshipName ).addChild( fabricatedChild );
        return this;
    }

    /**
    * Builds the SObject that this sfab_FabricatedSObject represents
    *
    * @return SObject - The built SObject
    */
    public SObject toSObject() {
        return (SObject)JSON.deserialize(JSON.serialize(serialize()), sType);
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

    private sfab_FabricatedSObject setParentField( String fieldName, Object value ) {
        String relationshipName = fieldName.substringBefore( '.' );
        String childFieldName   = fieldName.substringAfter( '.' );

        if ( !sfab_ObjectDescriber.objectHasParentRelationshipNamed( getSobjectName(), relationshipName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'The parent relationship ' + getSobjectName() + '.' + relationshipName + ' does not exist' );
        }

        if ( ! nodeExists( relationshipName ) ) {
            try {
                set( relationshipName, sfab_ObjectDescriber.buildFabricatedObjectForRelationship( getSobjectName(), relationshipName ) );
            } catch ( Exception e ) {
                throw new ParentRelationshipObjectCannotBeAutoCreatedException( 'Could not auto-assign an object for the field ' + fieldName + ': ' + e.getMessage() );
            }
        }

        getParentRelationshipNode( relationshipName ).setField( childFieldName, value );
        return this;
    }

    // TODO: extract the class sfab_FabricatedSObjectNodes?
    private Boolean nodeExists( String nodeName ) {
        return nodes.containsKey( nodeName );
    }

    private sfab_FabricatedSObject setNode( String nodeName, sfab_FabricatedSObjectNode node ) {
        nodes.put( nodeName, node );
        return this;
    }

    private sfab_FabricatedSObjectNode getNode( String nodeName ) {
        return nodes.get( nodeName );
    }

    // TODO: some kind of reasonable error if it's not a child relationship node
    private sfab_ParentRelationshipNode getParentRelationshipNode( String relationshipName ) {
        return ((sfab_ParentRelationshipNode)getNode( relationshipName ));
    }

    // TODO: some kind of reasonable error if it's not a child relationship node
    private sfab_ChildRelationshipNode getChildRelationshipNode( String relationshipName ) {
        return ((sfab_ChildRelationshipNode)getNode( relationshipName ));
    }

}