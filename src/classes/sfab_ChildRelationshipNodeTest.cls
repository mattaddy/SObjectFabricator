@isTest
private class sfab_ChildRelationshipNodeTest {
    @isTest
    private static void serialize_expectSerializeInvokedOnChildren() {
        sfab_FabricatedSObjectStub child1 = new sfab_FabricatedSObjectStub(Account.class);
        sfab_FabricatedSObjectStub child2 = new sfab_FabricatedSObjectStub(Account.class);
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r', new List<sfab_FabricatedSObject> { child1, child2 });

        node.serialize();

        System.assert(child1.serializeInvoked);
        System.assert(child2.serializeInvoked);
    }

    @isTest
    private static void serialize_expectDoneMapKey() {
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r', new List<sfab_FabricatedSObject>());

        Map<String, Object> builtNode = node.serialize();

        System.assert(((Map<String, Object>)builtNode.get('Accounts__r')).containsKey('done'));
        System.assert((Boolean)((Map<String, Object>)builtNode.get('Accounts__r')).get('done'));
    }

    @isTest
    private static void serialize_expectTotalSizeMapKey() {
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r', new List<sfab_FabricatedSObjectStub> {
                new sfab_FabricatedSObjectStub(Account.class),
                new sfab_FabricatedSObjectStub(Account.class)
        });

        Map<String, Object> builtNode = node.serialize();

        System.assert(((Map<String, Object>)builtNode.get('Accounts__r')).containsKey('totalSize'));
        System.assertEquals(2, ((Map<String, Object>)builtNode.get('Accounts__r')).get('totalSize'));
    }

    @isTest
    private static void serialize_expectSerializedChildrenMap() {
        sfab_FabricatedSObjectStub child1 = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-1' });
        sfab_FabricatedSObjectStub child2 = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-2' });
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r', new List<sfab_FabricatedSObject> { child1, child2 });

        List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();
        serializedChildren.add(child1.serialize());
        serializedChildren.add(child2.serialize());

        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(serializedChildren, ((Map<String, Object>)builtNode.get('Accounts__r')).get('records'));
    }

    @isTest
    private static void getNumberOfChildren_expectNumberOfChildrenAdded() {

        sfab_FabricatedSObjectStub child1 = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-1' });
        sfab_FabricatedSObjectStub child2 = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-2' });
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r', new List<sfab_FabricatedSObject> { child1, child2 });

        System.assertEquals(2, node.getNumberOfChildren());
    }

    @isTest
    private static void getChildren_expectTheChildren() {

        sfab_FabricatedSObjectStub child1 = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-1' });
        sfab_FabricatedSObjectStub child2 = new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-2' });
        List<sfab_FabricatedSObjectStub> children = new List<sfab_FabricatedSObjectStub> { child1, child2 };
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r', children);

        System.assertEquals(children, node.getChildren());
    }

    @isTest
    private static void getName_expectTheName() {
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r');
        System.assertEquals('Accounts__r', node.getName());
    }

    @isTest
    private static void constructor_withNoChildren_expectEmptyChildren() {
        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r');
        System.assertEquals(0, node.getNumberOfChildren());
    }

    @isTest
    private static void addChild_expectAddsAChildNode() {

        sfab_ChildRelationshipNode node = new sfab_ChildRelationshipNode('Accounts__r' );
        node.addChild( new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-1' } ) );
        node.addChild( new sfab_FabricatedSObjectStub(Account.class, new Map<String, Object> { 'Name' => 'Foo-2' } ) );

        System.assertEquals(2, node.getNumberOfChildren());
    }
}