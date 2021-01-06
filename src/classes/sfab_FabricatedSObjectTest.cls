@isTest
private class sfab_FabricatedSObjectTest {
    @isTest
    private static void constructor_expectFieldsSetViaSObjectField() {
        Map<Schema.SObjectField, Object> accountFields = new Map<SObjectField, Object> {
                Account.Id => 'Id-1',
                Account.Name => 'Foo'
        };

        sfab_FabricatedSObject fabricatedAccount = new sfab_FabricatedSObject(Account.class, accountFields);
        System.assertEquals(accountFields.size(), fabricatedAccount.nodes.size());
    }

    @isTest
    private static void constructor_expectFieldsSetViaString() {
        Map<String, Object> accountFields = new Map<String, Object> {
                'Id' => 'Id-1',
                'Name' => 'Foo'
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
        sfab_FabricatedSObjectNodeStub node1 = new sfab_FabricatedSObjectNodeStub( 'node1' );
        sfab_FabricatedSObjectNodeStub node2 = new sfab_FabricatedSObjectNodeStub( 'node2' );
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
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Id' ))?.value );
    }

    @isTest
    private static void setField_whenString_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.setField('Id', 'Id-1');
        System.assertEquals(1, fabricatedSObject.nodes.size());
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Id' )).value );
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
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Id' )).value );
    }

    @isTest
    private static void set_whenStringField_expectFieldAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        fabricatedSObject.set('Id', 'Id-1');
        System.assertEquals(1, fabricatedSObject.nodes.size());
        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Id' )).value );
    }

    @isTest
    private static void set_whenStringFieldForParent_expectParentAddedToNodes() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Contact.class);
        fabricatedSObject.set('Account.Id', 'Account-Id-1');
        fabricatedSObject.set('Account.Name', 'Account-Name');
        fabricatedSObject.set('Id', 'Contact-Id-1');
        System.assertEquals(2, fabricatedSObject.nodes.size());

        sfab_ParentRelationshipNode parentNode = ((sfab_ParentRelationshipNode)fabricatedSObject.nodes.get( 'Account' ));
        System.assertNotEquals(null, parentNode);

        System.assertEquals( 'Account-Id-1', ((sfab_FieldValuePairNode)parentNode.parent.nodes.get( 'Id' )).value );
        System.assertEquals( 'Account-Name', ((sfab_FieldValuePairNode)parentNode.parent.nodes.get( 'Name' )).value );
        System.assertEquals( 'Contact-Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Id' )).value );
    }

    @isTest
    private static void set_whenStringFieldForParentNotARelationship_expectException() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Account.class);
        Boolean exceptionThrown = false;
        String  exceptionMessage;
        try {
            fabricatedSObject.set('Name.NotARelationship', 'name is not a relationship');
        }
        // TODO: change this to a sfab_FabricatedSObject exception
        catch ( sfab_FabricatedSObject.ParentRelationshipDoesNotExistException e ) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        System.assert( exceptionThrown );
    }

    @isTest
    private static void set_whenStringFieldForParentPolymorphic_expectException() {
        sfab_FabricatedSObject fabricatedSObject = new sfab_FabricatedSObject(Task.class);
        Boolean exceptionThrown = false;
        String  exceptionMessage;
        try {
            fabricatedSObject.set('Owner.Username', 'cannot create polymorphic ones automatically');
        }
        // TODO: change this to a sfab_FabricatedSObject exception
        catch ( ObjectFieldRegister.ParentRelationshipObjectCannotBeAutoCreatedException e ) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        System.assert( exceptionThrown );
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

        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Id' )).value );
        System.assertEquals( 'Foo', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Name' )).value );
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
                'Owner'         =>  new sfab_FabricatedSObject( User.class )
                                        .set( 'Username', 'The user' )
        };

        fabricatedSObject.set(fields);
        System.assertEquals( 4, fabricatedSObject.nodes.size(), 'set, when given a map indexed by string, will add each of the fields' );

        System.assertEquals( 'Id-1', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Id' )).value, 'set, when given a map indexed by string, will add each of the fields, setting the value of a simple field' );
        System.assertEquals( 'Foo', ((sfab_FieldValuePairNode)fabricatedSObject.nodes.get( 'Name' )).value, 'set, when given a map indexed by string, will add each of the fields, setting the value of a simple field' );
        System.assertEquals( 1, ((sfab_ChildRelationshipNode)fabricatedSObject.nodes.get( 'Contacts' )).children.size(), 'set, when given a map indexed by string, will add each of the fields, setting the value of a child relationship field' );
        System.assertEquals( 1, ((sfab_ParentRelationshipNode)fabricatedSObject.nodes.get( 'Owner' )).parent.nodes.size(), 'set, when given a map indexed by string, will add each of the fields, setting the value of a parent relationship field' );
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