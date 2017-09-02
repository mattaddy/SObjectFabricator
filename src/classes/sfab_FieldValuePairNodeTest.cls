@isTest
private class sfab_FieldValuePairNodeTest {
    @isTest
    private static void build_expectMap() {
        sfab_FieldValuePairNode node = new sfab_FieldValuePairNode(Account.Name, 'Foo');
        Map<String, Object> builtNode = node.serialize();

        System.assertEquals(new Map<String, Object> { 'Name' => 'Foo' }, builtNode);
    }
}