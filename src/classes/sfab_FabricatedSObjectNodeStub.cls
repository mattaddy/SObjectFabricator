public class sfab_FabricatedSObjectNodeStub implements sfab_FabricatedSObjectNode  {
    public Boolean serializeInvoked = false;
    public Map<String, Object> serializedNode;
    private String name;

    public sfab_FabricatedSObjectNodeStub( String name ) {
        serializedNode = new Map<String, Object>();
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public sfab_FabricatedSObjectNodeStub(Map<String, Object> serializedNode) {
        this.serializedNode = serializedNode;
    }

    public Map<String, Object> serialize() {
        serializeInvoked = true;
        return serializedNode;
    }

    public void postBuildProcess( Object objectToProcess ) {
    }
}