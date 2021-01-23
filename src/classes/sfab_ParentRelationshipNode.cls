public class sfab_ParentRelationshipNode implements sfab_FabricatedSObjectNode {
    @testVisible private String fieldName;
    @testVisible private sfab_FabricatedSObject parent;

    public sfab_ParentRelationshipNode(String fieldName, sfab_FabricatedSObject parent) {
        this.fieldName = fieldName;
        this.parent = parent;
    }

    public String getName() {
        return fieldName;
    }

    public sfab_FabricatedSObject setField( String fieldname, Object value ) {
        return parent.set( fieldname, value );
    }

    public Map<String, Object> serialize() {
        return new Map<String, Object> { fieldName => parent.serialize() };
    }
}