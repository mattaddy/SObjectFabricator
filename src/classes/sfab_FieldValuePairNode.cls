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

    public Map<String,Object> serialize() {
        if ( fieldIsBlob() ) {
            return new Map<String,Object>(); // is handled by the post process instead as deserializing a blob field does not work (API 50)
        } else {
            return new Map<String,Object> { getName() => value };
        }
    }

    public void postBuildProcess( Object objectToProcess ) {
        if ( fieldIsBlob() ) {
            Blob valueToSet;
            if ( value instanceOf Blob ) {
                valueToSet = (Blob)value;
            } else if ( value instanceOf String ) {
                valueToSet = Blob.valueOf( (String)value );
            }
            ((Sobject)objectToProcess).put( field, valueToSet );
        }
    }

    private Boolean fieldIsBlob() {
        return field.getDescribe().getType() == Schema.DisplayType.BASE64;
    }
}