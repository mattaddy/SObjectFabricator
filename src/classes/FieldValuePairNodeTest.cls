@isTest
private class FieldValuePairNodeTest {
    @isTest
    private static void build_expectMap() {
        FieldValuePairNode node = new FieldValuePairNode(Account.Name, 'Foo');
        Map<String, Object> builtNode = node.build();

        System.assertEquals(new Map<String, Object> { 'Name' => 'Foo' }, builtNode);
    }
}