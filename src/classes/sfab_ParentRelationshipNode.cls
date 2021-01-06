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

    // TODO: this breaks the law of demeter... do I care?
    public sfab_FabricatedSObject getFabricatedObject() {
        return parent;
    }

    public Map<String, Object> serialize() {
        return new Map<String, Object> { fieldName => parent.serialize() };
    }
}