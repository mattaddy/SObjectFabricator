@isTest
private class SObjectFabricatorTest {
    @isTest
    private static void fabricate_expectSerializeInvoked() {
        FabricatedSObjectStub fabricatedSObject = new FabricatedSObjectStub(Account.class);
        SObjectFabricator fabricator = new SObjectFabricator();

        fabricator.fabricate(fabricatedSObject);

        System.assert(fabricatedSObject.serializeInvoked);
    }

    @isTest
    private static void fabricate_expectSpecifiedSObjectType() {
        FabricatedSObjectStub fabricatedSObject = new FabricatedSObjectStub(Account.class);
        SObjectFabricator fabricator = new SObjectFabricator();

        SObject sObj = fabricator.fabricate(fabricatedSObject);

        System.assert(sObj instanceof Account);
    }

    @isTest
    private static void fabricate_expectProperties() {
        Map<String, Object> fields = new Map<String, Object> { 'Id' => 'id-1', 'Name' => 'Foo' };
        FabricatedSObjectStub fabricatedSObject = new FabricatedSObjectStub(Account.class, fields);
        SObjectFabricator fabricator = new SObjectFabricator();

        SObject sObj = fabricator.fabricate(fabricatedSObject);

        System.assertEquals(fields.get('Id'), sObj.Id);
        System.assertEquals(fields.get('Name'), sObj.get('Name'));
    }
}