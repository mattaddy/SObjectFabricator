@isTest
private class sfab_FabricatedSObjectTest {
    @isTest
    private static void constructor_expectFieldsSet() {
        Map<Schema.SObjectField, Object> accountFields = new Map<SObjectField, Object> {
                Account.Id => 'Id-1',
                Account.Name => 'Foo'
        };

        sfab_FabricatedSObject fabricatedAccount = new sfab_FabricatedSObject(Account.class, accountFields);
        System.assertEquals(accountFields.size(), fabricatedAccount.nodes.size());
    }

    @isTest
    private static void toSObject_expectSpecifiedSObjectType() {
        SObject sObj = new sfab_FabricatedSObject(Account.class).toSObject();
        System.assert(sObj instanceof Account);
    }

    @isTest
    private static void toSObject_expectBuildInvokedOnNodes() {
        sfab_FabricatedSObjectNodeStub node1 = new sfab_FabricatedSObjectNodeStub();
        sfab_FabricatedSObjectNodeStub node2 = new sfab_FabricatedSObjectNodeStub();
        SObject sObj = new sfab_FabricatedSObject(Account.class, new List<sfab_FabricatedSObjectNode> { node1, node2 }).toSObject();
        System.assert(node1.serializeInvoked);
        System.assert(node2.serializeInvoked);
    }

    @isTest
    private static void toSObject_expectProperties() {
        Map<String, Object> fields = new Map<String, Object> { 'Id' => 'id-1', 'Name' => 'Foo' };
        sfab_FabricatedSObjectNodeStub node = new sfab_FabricatedSObjectNodeStub(fields);
        SObject sObj = new sfab_FabricatedSObject(Account.class, new List<sfab_FabricatedSObjectNode> { node }).toSObject();
        System.assertEquals(fields.get('Id'), sObj.Id);
        System.assertEquals(fields.get('Name'), sObj.get('Name'));
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
    private static void setParentByToken_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Opportunity.class);
        fabricatedSObject.setParent(Opportunity.AccountId, new sfab_FabricatedSObject(Account.class));
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }
    
    @isTest
    private static void setParentWithId_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedParentSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedParentSObject.setField(Account.Id, 'Id-1');
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Opportunity.class);
        fabricatedSObject.setParent(Opportunity.AccountId, fabricatedParentSObject, Account.Id);
        System.assertEquals(2, fabricatedSObject.nodes.size());
        System.assertEquals('Id-1', fabricatedSObject.getFieldValue(Opportunity.AccountId));
    }

    @isTest
    private static void setChildren_expectFieldAdded() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.setChildren('Opportunites', new List<sfab_FabricatedSObject>());
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }
    
    @isTest
    private static void getFieldValue_expectValue() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.setField(Account.Id, 'Id-1');
        System.assertEquals('Id-1', fabricatedSObject.getFieldValue(Account.Id));
    }
    
    @isTest
    private static void getFieldValue_expectNotFound() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        System.assertEquals(null, fabricatedSObject.getFieldValue(Account.Id));
    }
}