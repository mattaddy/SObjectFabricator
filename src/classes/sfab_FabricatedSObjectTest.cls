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
        System.assertEquals( 'Id', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).field) );
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).value );
    }

    @isTest
    private static void setField_whenString_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.setField('Id', 'Id-1');
        System.assertEquals(1, fabricatedSObject.nodes.size());
        System.assertEquals( 'Id', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).field) );
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).value );
    }

    @isTest
    private static void setField_whenStringIsInvalidField_expectException() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        Boolean exceptionThrown = false;
        String  exceptionMessage;
        try {
            fabricatedSObject.setField('Invalid', 'Id-1');
        }
        catch ( sfab_FabricatedSObject.FieldDoesNotExistException e ) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        System.assert( exceptionThrown );
    }

    @isTest
    private static void set_whenField_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.set(Account.Id, 'Id-1');
        System.assertEquals(1, fabricatedSObject.nodes.size());
        System.assertEquals( 'Id', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).field) );
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).value );
    }

    @isTest
    private static void set_whenStringField_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.set('Id', 'Id-1');
        System.assertEquals(1, fabricatedSObject.nodes.size());
        System.assertEquals( 'Id', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).field) );
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).value );
    }

    @isTest
    private static void set_whenMapSobjectField_expectFieldsAddedToNodes() {

        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);

        Map<Schema.SObjectField, Object> fields = new Map<SObjectField, Object> {
                Account.Id => 'Id-1',
                Account.Name => 'Foo'
        };

        fabricatedSObject.set(fields);
        System.assertEquals( fields.size(), fabricatedSObject.nodes.size());

        System.assertEquals( 'Id', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).field) );
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).value );

        System.assertEquals( 'Name', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[1]).field) );
        System.assertEquals( 'Foo', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[1]).value );
    }

    @isTest
    private static void set_whenMapString_expectFieldsParentsAndChildrenAddedToNodes() {

        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);

        Map<String,Object> fields = new Map<String,Object> {
                'Id'            =>  'Id-1',
                'Name'          =>  'Foo',
                'Contacts'      =>  new List<sfab_FabricatedSObject>{
                                        new sfab_FabricatedSObject( Contact.class )
                                            .set( 'Name', 'ContactName' )
                                    },
                'AccountOwner'  =>  new sfab_FabricatedSObject( User.class )
                                        .set( 'Username', 'The user' )
        };

        fabricatedSObject.set(fields);
        System.assertEquals( 4, fabricatedSObject.nodes.size(), 'set, when given a map indexed by string, will add each of the fields' );

        System.assertEquals( 'Id', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).field), 'set, when given a map indexed by string, will add each of the fields (checking name of field 0)' );
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[0]).value, 'set, when given a map indexed by string, will add each of the fields, setting the value of a simple field' );

        System.assertEquals( 'Name', String.valueOf(((sfab_FieldValuePairNode)fabricatedSObject.nodes[1]).field), 'set, when given a map indexed by string, will add each of the fields (checking name of field 1)' );
        System.assertEquals( 'Foo', ((sfab_FieldValuePairNode)fabricatedSObject.nodes[1]).value, 'set, when given a map indexed by string, will add each of the fields, setting the value of a simple field' );

        System.assertEquals( 'Contacts', ((sfab_ChildRelationshipNode)fabricatedSObject.nodes[2]).fieldName, 'set, when given a map indexed by string, will add each of the fields (checking name of field 2)' );
        System.assertEquals( 1, ((sfab_ChildRelationshipNode)fabricatedSObject.nodes[2]).children.size(), 'set, when given a map indexed by string, will add each of the fields, setting the value of a child relationship field' );

        System.assertEquals( 'AccountOwner', ((sfab_ParentRelationshipNode)fabricatedSObject.nodes[3]).fieldName, 'set, when given a map indexed by string, will add each of the fields (checking name of field 3)' );
        System.assertEquals( 1, ((sfab_ParentRelationshipNode)fabricatedSObject.nodes[3]).parent.nodes.size(), 'set, when given a map indexed by string, will add each of the fields, setting the value of a parent relationship field' );
    }

    @isTest
    private static void setParent_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Opportunity.class);
        fabricatedSObject.setParent('Account', new sfab_FabricatedSObject(Account.class));
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }

    @isTest
    private static void set_whenParent_expectFieldAddedToNodes() {
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

    @isTest
    private static void set_whenChild_expectFieldAdded() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.setChildren('Opportunites', new List<sfab_FabricatedSObject>());
        System.assertEquals(1, fabricatedSObject.nodes.size());
    }
}