@isTest
private class FabricatedSObjectTest {
    @isTest
    private static void serialize_emptyNodes_expectEmptyMap() {
        FabricatedSObject fabricatedSObject = new FabricatedSObject(Account.class, new List<FabricatedSObjectNodeStub>());
        Map<String, Object> serializedNodes = fabricatedSObject.serialize();
        System.assertEquals(new Map<String, Object>(), serializedNodes);
    }

    @isTest
    private static void serialize_nonEmptyNodes_expectBuiltNodes() {
        FabricatedSObjectNodeStub node1 = new FabricatedSObjectNodeStub(new Map<String, Object> { 'key1' => 'value1' });
        FabricatedSObjectNodeStub node2 = new FabricatedSObjectNodeStub(new Map<String, Object> { 'key2' => 'value2' });

        Map<String, Object> builtNodes = new Map<String, Object>();
        builtNodes.putAll(node1.build());
        builtNodes.putAll(node2.build());

        List<FabricatedSObjectNodeStub> nodes = new List<FabricatedSObjectNodeStub> { node1, node2 };

        Map<String, Object> serializedNodes = new FabricatedSObject(Account.class, nodes).serialize();

        System.assertEquals(serializedNodes, builtNodes);
    }

    @isTest
    private static void setField_expectFieldAddedToNodes() {
        FabricatedSObject fabricatedSObject = new FabricatedSObject(Account.class);
        fabricatedSObject.setField(Account.Id, 'Id-1');
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }

    @isTest
    private static void setParent_expectFieldAddedToNodes() {
        FabricatedSObject fabricatedSObject = new FabricatedSObject(Opportunity.class);
        fabricatedSObject.setParent('Account', new FabricatedSObject(Account.class));
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }

    @isTest
    private static void setChildren_expectFieldAdded() {
        FabricatedSObject fabricatedSObject = new FabricatedSObject(Account.class);
        fabricatedSObject.setChildren('Opportunites', new List<FabricatedSObject>());
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }
}