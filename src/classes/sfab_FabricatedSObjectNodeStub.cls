public class sfab_FabricatedSObjectNodeStub implements sfab_FabricatedSObjectNode  {
    public Map<String, Object> builtNode;

    public sfab_FabricatedSObjectNodeStub(Map<String, Object> builtNode) {
        this.builtNode = builtNode;
    }

    public Map<String, Object> build() {
        return builtNode;
    }
}