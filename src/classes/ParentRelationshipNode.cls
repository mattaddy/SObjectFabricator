public class ParentRelationshipNode implements FabricatedSObjectNode {
    private String fieldName;
    private FabricatedSObject parent;

    public ParentRelationshipNode(String fieldName, FabricatedSObject parent) {
        this.fieldName = fieldName;
        this.parent = parent;
    }

    public Map<String, Object> build() {
        return new Map<String, Object> { fieldName => parent.serialize() };
    }
}