@isTest
private class ParentRelationshipNodeTest {
    @isTest
    private static void build_expectSerializeInvokedOnParent() {
        FabricatedSObjectStub fabricatedParent = new FabricatedSObjectStub(Account.class);
        ParentRelationshipNode node = new ParentRelationshipNode('Account__r', fabricatedParent);

        node.build();

        System.assert(fabricatedParent.serializeInvoked);
    }

    @isTest
    private static void build_expectSerializedParentMap() {
        FabricatedSObjectStub fabricatedParent = new FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo' });
        ParentRelationshipNode node = new ParentRelationshipNode('Account__r', fabricatedParent);

        Map<String, Object> builtNode = node.build();

        System.assertEquals(new Map<String, Object> { 'Account__r' => fabricatedParent.serialize() }, builtNode);
    }
}