public class sfab_FieldValuePairNode implements sfab_FabricatedSObjectNode {
    @testVisible protected Schema.SObjectField field;
    @testVisible protected Object value;

    public sfab_FieldValuePairNode(Schema.SObjectField field, Object value) {
        this.field = field;
        this.value = value;
    }

    public String getName() {
        return field?.getDescribe().getName();
    }

    public Object getValue() {
        return value;
    }

    public Map<String, Object> serialize() {
        // TODO: if not blob, do this
        return new Map<String, Object> { getName() => value };
    }

    public void postBuildProcess( Object objectToProcess ) {
        // TODO: move the blob field processing into here
    }
}