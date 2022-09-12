@isTest
private class sfab_ParentRelationshipNodeTest {
    @isTest
    private static void serialize_expectSerializeInvokedOnParent() {
        sfab_FabricatedSObjectStub fabricatedParent = new sfab_FabricatedSObjectStub(Account.class);
        sfab_ParentRelationshipNode node = new sfab_ParentRelationshipNode('Account__r', fabricatedParent);

        node.serialize();

        System.assert(fabricatedParent.serializeInvoked);
    }

    @isTest
    private static void serialize_expectSerializedParentMap() {
        sfab_FabricatedSObjectStub fabricatedParent = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo' });
        sfab_ParentRelationshipNode node = new sfab_ParentRelationshipNode('Account__r', fabricatedParent);

        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(new Map<String, Object> { 'Account__r' => fabricatedParent.serialize() }, builtNode);
    }

    @isTest
    private static void getName_expectParentReturned() {
        sfab_FabricatedSObjectStub fabricatedParent = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo' });
        sfab_ParentRelationshipNode node = new sfab_ParentRelationshipNode('Account__r', fabricatedParent);

        System.assertEquals( 'Account__r', node.getName() );
    }

    @isTest
    private static void getParent_expectParentReturned() {
        sfab_FabricatedSObjectStub fabricatedParent = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo' });
        sfab_ParentRelationshipNode node = new sfab_ParentRelationshipNode('Account__r', fabricatedParent);

        System.assertEquals( fabricatedParent, node.getParent() );
    }
}