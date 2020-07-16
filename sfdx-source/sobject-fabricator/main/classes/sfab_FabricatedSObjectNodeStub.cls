public class sfab_FabricatedSObjectNodeStub implements sfab_FabricatedSObjectNode  {
    public Boolean serializeInvoked = false;
    public Map<String, Object> serializedNode;

    public sfab_FabricatedSObjectNodeStub() {
        serializedNode = new Map<String, Object>();
    }

    public sfab_FabricatedSObjectNodeStub(Map<String, Object> serializedNode) {
        this.serializedNode = serializedNode;
    }

    public Map<String, Object> serialize() {
        serializeInvoked = true;
        return serializedNode;
    }
}