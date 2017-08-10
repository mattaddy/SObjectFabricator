public class SObjectFabricator {
    public SObject fabricate(FabricatedSObject fabricatedSObject) {
        return (SObject)JSON.deserialize(JSON.serialize(fabricatedSObject.serialize()), fabricatedSObject.getType());
    }
}