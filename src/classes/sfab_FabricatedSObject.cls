public virtual class sfab_FabricatedSObject {
    private Type sType;
    @testVisible private Map<String,sfab_FabricatedSObjectNode> nodes = new Map<String,sfab_FabricatedSObjectNode>();

    sfab_ObjectRelationshipDescriber sfab_ObjectRelationshipDescriber = new sfab_ObjectRelationshipDescriber();

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
    *   * Fields can be set by stating the field name (E.g. Name) and passing the correct data-type
    *   * Parent objects can be set by stating the relationship name (E.g. Account) and passing an sfab_FabricatedSObject.
    *   * Parent object fields can be set by stating the relationship name followed by the field name (E.g. Account.Name) and passing a value.
    *   * Child relationships can be set by stating the relationship name (E.g. Contacts) and passing a list of sfab_FabricatedSObjects
    *
    * @param Type - The type of SObject to be fabricated (e.g. Contact.class)
    * @param Map<String,Object> - The fields and relationships to set on this object, with the desired values
    */
    public sfab_FabricatedSObject(Type sType, Map<String, Object> fields) {
        this(sType);
        set(fields);
    }

    @testVisible protected sfab_FabricatedSObject(Type sType, List<sfab_FabricatedSObjectNode> nodes) {
        this.sType = sType;
        this.nodes = new Map<String,sfab_FabricatedSObjectNode>();
        for ( sfab_FabricatedSObjectNode node : nodes ) {
            this.nodes.put( node.getName(), node );
        }
    }

    /**
    * Set the specified field to the specified value.
    *
    * Note: only fields on this object's type may be set.  Only the 'name' of the field is used and expected results may
    * occur if you attempt to pass a field on a different object.
    *
    * @param Schema.SObjectField - The field to set
    * @param Object - The value that the field should be set to
    */
    public sfab_FabricatedSObject set( Schema.SObjectField field, Object value) {
        return setField( field, value );
    }

    /**
    * Set the specified field to the specified value.
    *
    *   * Fields can be set by stating the field name (E.g. Name) and passing the correct data-type
    *   * Parent objects can be set by stating the relationship name (E.g. Account) and passing an sfab_FabricatedSObject.
    *   * Parent object fields can be set by stating the relationship name followed by the field name (E.g. Account.Name) and passing a value.
    *   * Child relationships can be set by stating the relationship name (E.g. Contacts) and passing a list of sfab_FabricatedSObjects
    *
    * @param Schema.SObjectField - The field to set
    * @param Object - The value that the field should be set to
    */

    public sfab_FabricatedSObject set( String fieldName, Object value ) {

        // This looks like it duplicates the overloading of set, but unfortunately Apex determines the method to call
        // based on the static type of a parameter rather than the dynamic type.
        // I.E. if a passed parameter's value is declared as 'Object' it will always call the 'Object'
        // defined version of an overloaded method even when a more specific type matches.
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

    public sfab_FabricatedSObject set( String relationshipName, sfab_FabricatedSObject fabricatedParent ) {
        return setParent( relationshipName, fabricatedParent );
    }

    public sfab_FabricatedSObject set( String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
        return setChildren( relationshipName, fabricatedChildren );
    }

    public sfab_FabricatedSObject set( Map<Schema.SObjectField, Object> fields ) {
        for (Schema.SObjectField field : fields.keySet()) {
            setField(field, fields.get(field));
        }
        return this;
    }

    public sfab_FabricatedSObject set( Map<String, Object> fields ) {
        for (String fieldName : fields.keySet()) {
            Object value = fields.get( fieldName );
            set( fieldName, fields.get(fieldName) );
        }
        return this;
    }

    public sfab_FabricatedSObject setField(Schema.SObjectField field, Object value) {
        nodes.put( field.getDescribe().getName(), new sfab_FieldValuePairNode(field, value));
        return this;
    }

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

    public sfab_FabricatedSObject setParent(String relationshipName, sfab_FabricatedSObject fabricatedParent) {
        nodes.put( relationshipName, new sfab_ParentRelationshipNode(relationshipName, fabricatedParent));
        return this;
    }

    public sfab_FabricatedSObject setChildren(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
        nodes.put( relationshipName, new sfab_ChildRelationshipNode(relationshipName, fabricatedChildren));
        return this;
    }

    public SObject toSObject() {
        return (SObject)JSON.deserialize(JSON.serialize(serialize()), sType);
    }

    public virtual Map<String, Object> serialize() {
        Map<String, Object> fields = new Map<String, Object>();
        for (sfab_FabricatedSObjectNode node : nodes.values()) {
            fields.putAll(node.serialize());
        }
        return fields;
    }

    public String getSobjectName() {
        return String.valueOf( sType );
    }

    private sfab_FabricatedSObject setParentField( String fieldName, Object value ) {
        String relationshipName = fieldName.substringBefore( '.' );
        String childFieldName   = fieldName.substringAfter( '.' );

        if ( !sfab_ObjectRelationshipDescriber.objectHasParentRelationshipNamed( getSobjectName(), relationshipName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'The parent relationship ' + getSobjectName() + '.' + relationshipName + ' does not exist' );
        }

        if ( !nodes.containsKey( relationshipName ) ) {
            try {
                set( relationshipName, sfab_ObjectRelationshipDescriber.buildFabricatedObjectForRelationship( getSobjectName(), relationshipName ) );
            } catch ( Exception e ) {
                throw new ParentRelationshipObjectCannotBeAutoCreatedException( 'Could not auto-assign an object for the field ' + fieldName + ': ' + e.getMessage() );
            }
        }

        ((sfab_ParentRelationshipNode)nodes.get( relationshipName ))?.getFabricatedObject()?.set( childFieldName, value );
        return this;
    }
}