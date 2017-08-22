@isTest
private class sfab_FabricatedSObjectTest {
    @isTest
    private static void serialize_emptyNodes_expectEmptyMap() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class, new List<sfab_FabricatedSObjectNodeStub>());
        Map<String, Object> serializedNodes = fabricatedSObject.serialize();
        System.assertEquals(new Map<String, Object>(), serializedNodes);
    }

    @isTest
    private static void serialize_nonEmptyNodes_expectBuiltNodes() {
        sfab_FabricatedSObjectNodeStub node1 = new sfab_FabricatedSObjectNodeStub(new Map<String, Object> { 'key1' => 'value1' });
        sfab_FabricatedSObjectNodeStub node2 = new sfab_FabricatedSObjectNodeStub(new Map<String, Object> { 'key2' => 'value2' });

        Map<String, Object> builtNodes = new Map<String, Object>();
        builtNodes.putAll(node1.build());
        builtNodes.putAll(node2.build());

        List<sfab_FabricatedSObjectNodeStub> nodes = new List<sfab_FabricatedSObjectNodeStub> { node1, node2 };

        Map<String, Object> serializedNodes = new sfab_FabricatedSObject(Account.class, nodes).serialize();

        System.assertEquals(serializedNodes, builtNodes);
    }

    @isTest
    private static void setField_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.setField(Account.Id, 'Id-1');
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }

    @isTest
    private static void setParent_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Opportunity.class);
        fabricatedSObject.setParent('Account', new sfab_FabricatedSObject(Account.class));
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }

    @isTest
    private static void setChildren_expectFieldAdded() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.setChildren('Opportunites', new List<sfab_FabricatedSObject>());
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }
}