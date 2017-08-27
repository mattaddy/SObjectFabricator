public class sfab_SObjectFabricator {
    public SObject fabricate(sfab_FabricatedSObject fabricatedSObject) {
        return (SObject)JSON.deserialize(JSON.serialize(fabricatedSObject.serialize()), fabricatedSObject.getType());
    }
}