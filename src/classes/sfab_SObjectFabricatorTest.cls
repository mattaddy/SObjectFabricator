@isTest
private class sfab_SObjectFabricatorTest {
    @isTest
    private static void fabricate_expectSerializeInvoked() {
        sfab_FabricatedSObjectStub fabricatedSObject = new sfab_FabricatedSObjectStub(Account.class);
        sfab_SObjectFabricator fabricator = new sfab_SObjectFabricator();

        fabricator.fabricate(fabricatedSObject);

        System.assert(fabricatedSObject.serializeInvoked);
    }

    @isTest
    private static void fabricate_expectSpecifiedSObjectType() {
        sfab_FabricatedSObjectStub fabricatedSObject = new sfab_FabricatedSObjectStub(Account.class);
        sfab_SObjectFabricator fabricator = new sfab_SObjectFabricator();

        SObject sObj = fabricator.fabricate(fabricatedSObject);

        System.assert(sObj instanceof Account);
    }

    @isTest
    private static void fabricate_expectProperties() {
        Map<String, Object> fields = new Map<String, Object> { 'Id' => 'id-1', 'Name' => 'Foo' };
        sfab_FabricatedSObjectStub fabricatedSObject = new sfab_FabricatedSObjectStub(Account.class, fields);
        sfab_SObjectFabricator fabricator = new sfab_SObjectFabricator();

        SObject sObj = fabricator.fabricate(fabricatedSObject);

        System.assertEquals(fields.get('Id'), sObj.Id);
        System.assertEquals(fields.get('Name'), sObj.get('Name'));
    }
}