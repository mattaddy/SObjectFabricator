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

    // TODO: test
    public sfab_FabricatedSObject getParent() {
        return parent;
    }

    public sfab_FabricatedSObject setField( String fieldName, Object value ) {
        return parent.set( fieldName, value );
    }

    public Map<String, Object> serialize() {
        return new Map<String, Object> { fieldName => parent.serialize() };
    }
}