@isTest
private class sfab_FieldValuePairNodeTest {
    @isTest
    private static void serialize_expectMap() {
        sfab_FieldValuePairNode node = new sfab_FieldValuePairNode(Account.Name, 'Foo');
        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(new Map<String, Object> { 'Name' => 'Foo' }, builtNode);
    }

    @isTest
    private static void getName_expectNameFromField() {
        sfab_FieldValuePairNode node = new sfab_FieldValuePairNode(Account.Name, 'Foo');
        System.assertEquals( 'Name', node.getName() );
    }

    @isTest
    private static void getName_whenNoField_expectNull() {
        sfab_FieldValuePairNode node = new sfab_FieldValuePairNode(null, 'Foo');
        System.assertEquals( null, node.getName() );
    }

    @isTest
    private static void getValue_expectValueFromField() {
        sfab_FieldValuePairNode node = new sfab_FieldValuePairNode(Account.Name, 'Foo');
        System.assertEquals( 'Foo', node.getValue() );
    }
}