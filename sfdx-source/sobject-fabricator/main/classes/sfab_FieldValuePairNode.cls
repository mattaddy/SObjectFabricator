public class sfab_FieldValuePairNode implements sfab_FabricatedSObjectNode {
    protected Schema.SObjectField field;
    protected Object value;

    public sfab_FieldValuePairNode(Schema.SObjectField field, Object value) {
        this.field = field;
        this.value = value;
    }

    public Map<String, Object> serialize() {
        return new Map<String, Object> { field.getDescribe().getName() => value };
    }
}