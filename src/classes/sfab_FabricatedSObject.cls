public virtual class sfab_FabricatedSObject {
    private Type sType;
    @testVisible private List<sfab_FabricatedSObjectNode> nodes = new List<sfab_FabricatedSObjectNode>();

    public class FieldDoesNotExistException extends Exception {}

    public sfab_FabricatedSObject(Type sType) {
        this.sType = sType;
    }

    public sfab_FabricatedSObject(Type sType, Map<Schema.SObjectField, Object> fields) {
        this(sType);
        set(fields);
    }

    @testVisible protected sfab_FabricatedSObject(Type sType, List<sfab_FabricatedSObjectNode> nodes) {
        this.sType = sType;
        this.nodes = nodes;
    }

    public sfab_FabricatedSObject set( Schema.SObjectField field, Object value) {
        return setField( field, value );
    }

    public sfab_FabricatedSObject set( String fieldName, Object value) {
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
            if ( value instanceOf sfab_FabricatedSObject ) {
                set( fieldName, (sfab_FabricatedSObject)value );

            } else if ( value instanceOf List<sfab_FabricatedSObject> ) {
                set( fieldName, (List<sfab_FabricatedSObject>)value );

            } else {
                set( fieldName, fields.get(fieldName) );
            }
        }
        return this;
    }

    public sfab_FabricatedSObject setField(Schema.SObjectField field, Object value) {
        nodes.add(new sfab_FieldValuePairNode(field, value));
        return this;
    }

    public sfab_FabricatedSObject setField( String fieldName, Object value ) {
        Schema.SobjectField theField = Schema.getGlobalDescribe()
                                                .get( String.valueOf( sType ) )
                                                ?.getDescribe()
                                                ?.fields
                                                ?.getMap()
                                                ?.get( fieldName );
        if ( theField == null ) {
            throw new FieldDoesNotExistException( 'The field ' + String.valueOf( sType ) + '.' + fieldName + ' does not exist' );
        }

        return setField( theField, value );
    }

    public sfab_FabricatedSObject setParent(String relationshipName, sfab_FabricatedSObject fabricatedParent) {
        nodes.add(new sfab_ParentRelationshipNode(relationshipName, fabricatedParent));
        return this;
    }

    public sfab_FabricatedSObject setChildren(String relationshipName, List<sfab_FabricatedSObject> fabricatedChildren) {
        nodes.add(new sfab_ChildRelationshipNode(relationshipName, fabricatedChildren));
        return this;
    }

    public SObject toSObject() {
        return (SObject)JSON.deserialize(JSON.serialize(serialize()), sType);
    }

    public virtual Map<String, Object> serialize() {
        Map<String, Object> fields = new Map<String, Object>();

        for (sfab_FabricatedSObjectNode node : nodes) {
            fields.putAll(node.serialize());
        }

        return fields;
    }
}