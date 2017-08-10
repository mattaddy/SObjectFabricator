public class FieldValuePairNode implements FabricatedSObjectNode {
    protected Schema.SObjectField field;
    protected Object value;

    public FieldValuePairNode(Schema.SObjectField field, Object value) {
        this.field = field;
        this.value = value;
    }

    public Map<String, Object> build() {
        return new Map<String, Object> { field.getDescribe().getName() => value };
    }
}