public virtual class sfab_FabricatedSObject {
    private Type sType;
    @testVisible private Map<String,sfab_FabricatedSObjectNode> nodes = new Map<String,sfab_FabricatedSObjectNode>();

    ObjectFieldRegister objectFieldRegister = new ObjectFieldRegister();

    public class FieldDoesNotExistException extends Exception {}
    public class ParentRelationshipDoesNotExistException extends Exception {}

    public sfab_FabricatedSObject(Type sType) {
        this.sType = sType;
    }

    public sfab_FabricatedSObject(Type sType, Map<Schema.SObjectField, Object> fields) {
        this(sType);
        set(fields);
    }

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

    public sfab_FabricatedSObject set( Schema.SObjectField field, Object value) {
        return setField( field, value );
    }

    public sfab_FabricatedSObject set( String fieldName, Object value ) {

        if ( fieldName.contains( '.' ) ) {
            return setParentField( fieldName, value );
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

    private String getSobjectName() {
        return String.valueOf( sType );
    }

    private sfab_FabricatedSObject setParentField( String fieldName, Object value ) {
        String relationshipName = fieldName.substringBefore( '.' );
        String childFieldName   = fieldName.substringAfter( '.' );

        if ( !objectFieldRegister.objectHasParentRelationshipNamed( getSobjectName(), relationshipName ) ) {
            throw new ParentRelationshipDoesNotExistException( 'The parent relationship ' + getSobjectName() + '.' + relationshipName + ' does not exist' );
        }

        if ( !nodes.containsKey( relationshipName ) ) {
            set( relationshipName, objectFieldRegister.buildFabricatedObjectForRelationship( getSobjectName(), relationshipName ) );
        }

        // TODO: bit hacky...
        ((sfab_ParentRelationshipNode)nodes.get( relationshipName ))?.getFabricatedObject()?.set( childFieldName, value );
        return this;
    }
}