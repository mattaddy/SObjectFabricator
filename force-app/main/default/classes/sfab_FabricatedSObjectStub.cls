public class sfab_FabricatedSObjectStub extends sfab_FabricatedSObject {
    private Map<String, Object> serializedMap;
    @testVisible private Boolean serializeInvoked = false;

    public sfab_FabricatedSObjectStub(Type sType) {
        super(sType);
        this.serializedMap = new Map<String, Object>();
    }

    public sfab_FabricatedSObjectStub(Type sType, Map<String, Object> serializedMap) {
        super(sType);
        this.serializedMap = serializedMap;
    }

    public override Map<String, Object> serialize() {
        serializeInvoked = true;
        return serializedMap;
    }
}