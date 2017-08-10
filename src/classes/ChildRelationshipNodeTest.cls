@isTest
private class ChildRelationshipNodeTest {
    @isTest
    private static void build_expectSerializeInvokedOnChildren() {
        FabricatedSObjectStub child1 = new FabricatedSObjectStub(Account.class);
        FabricatedSObjectStub child2 = new FabricatedSObjectStub(Account.class);
        ChildRelationshipNode node = new ChildRelationshipNode('Accounts__r', new List<FabricatedSObject> { child1, child2 });

        node.build();

        System.assert(child1.serializeInvoked);
        System.assert(child2.serializeInvoked);
    }

    @isTest
    private static void build_expectDoneMapKey() {
        ChildRelationshipNode node = new ChildRelationshipNode('Accounts__r', new List<FabricatedSObject>());

        Map<String, Object> builtNode = node.build();

        System.assert(((Map<String, Object>)builtNode.get('Accounts__r')).containsKey('done'));
        System.assert((Boolean)((Map<String, Object>)builtNode.get('Accounts__r')).get('done'));
    }

    @isTest
    private static void build_expectTotalSizeMapKey() {
        ChildRelationshipNode node = new ChildRelationshipNode('Accounts__r', new List<FabricatedSObjectStub> {
                new FabricatedSObjectStub(Account.class),
                new FabricatedSObjectStub(Account.class)
        });

        Map<String, Object> builtNode = node.build();

        System.assert(((Map<String, Object>)builtNode.get('Accounts__r')).containsKey('totalSize'));
        System.assertEquals(2, ((Map<String, Object>)builtNode.get('Accounts__r')).get('totalSize'));
    }

    @isTest
    private static void build_expectSerializedChildrenMap() {
        FabricatedSObjectStub child1 = new FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-1' });
        FabricatedSObjectStub child2 = new FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-2' });
        ChildRelationshipNode node = new ChildRelationshipNode('Accounts__r', new List<FabricatedSObject> { child1, child2 });

        List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();
        serializedChildren.add(child1.serialize());
        serializedChildren.add(child2.serialize());

        Map<String, Object> builtNode = node.build();

        System.assertEquals(serializedChildren, ((Map<String, Object>)builtNode.get('Accounts__r')).get('records'));
    }
}