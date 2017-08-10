public class ChildRelationshipNode implements FabricatedSObjectNode {
    private String fieldName;
    private List<FabricatedSObject> children;

    public ChildRelationshipNode(String fieldName, List<FabricatedSObject> children) {
        this.fieldName = fieldName;
        this.children = children;
    }

    public Map<String, Object> build() {
        List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();

        for (FabricatedSObject child : children) {
            serializedChildren.add(child.serialize());
        }

        return new Map<String, Object> {
                fieldName => new Map<String, Object> {
                        'totalSize' => children.size(),
                        'done' => true,
                        'records' => serializedChildren
                }
        };
    }
}