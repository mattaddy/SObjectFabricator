public class FabricatedSObjectNodeStub implements FabricatedSObjectNode {
    public Map<String, Object> builtNode;

    public FabricatedSObjectNodeStub(Map<String, Object> builtNode) {
        this.builtNode = builtNode;
    }

    public Map<String, Object> build() {
        return builtNode;
    }
}