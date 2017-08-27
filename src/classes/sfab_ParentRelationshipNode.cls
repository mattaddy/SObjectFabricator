public class sfab_ParentRelationshipNode implements sfab_FabricatedSObjectNode {
    private String fieldName;
    private sfab_FabricatedSObject parent;

    public sfab_ParentRelationshipNode(String fieldName, sfab_FabricatedSObject parent) {
        this.fieldName = fieldName;
        this.parent = parent;
    }

    public Map<String, Object> build() {
        return new Map<String, Object> { fieldName => parent.serialize() };
    }
}