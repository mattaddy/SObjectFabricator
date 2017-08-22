@isTest
private class sfab_ParentRelationshipNodeTest {
    @isTest
    private static void build_expectSerializeInvokedOnParent() {
        sfab_FabricatedSObjectStub fabricatedParent = new sfab_FabricatedSObjectStub(Account.class);
        sfab_ParentRelationshipNode node = new sfab_ParentRelationshipNode('Account__r', fabricatedParent);

        node.build();

        System.assert(fabricatedParent.serializeInvoked);
    }

    @isTest
    private static void build_expectSerializedParentMap() {
        sfab_FabricatedSObjectStub fabricatedParent = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo' });
        sfab_ParentRelationshipNode node = new sfab_ParentRelationshipNode('Account__r', fabricatedParent);

        Map<String, Object> builtNode = node.build();

        System.assertEquals(new Map<String, Object> { 'Account__r' => fabricatedParent.serialize() }, builtNode);
    }
}