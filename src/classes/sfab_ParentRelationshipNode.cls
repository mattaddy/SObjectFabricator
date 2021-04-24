public class sfab_ParentRelationshipNode implements sfab_FabricatedSObjectNode {
    @testVisible private String fieldName;
    @testVisible private sfab_FabricatedSObject parent;

    public sfab_ParentRelationshipNode(String fieldName, sfab_FabricatedSObject parent) {
        this.fieldName = fieldName;
        this.parent = parent;
    }

    public String getName() {
        return fieldName;
    }

    public sfab_FabricatedSObject getParent() {
        return parent;
    }

    public sfab_FabricatedSObject set( String fieldName, Object value ) {
        return parent.set( fieldName, value );
    }

    public sfab_FabricatedSObject add( String fieldName, sfab_FabricatedSObject fabricatedChild ) {
        return parent.add( fieldName, fabricatedChild );
    }

    public Map<String, Object> serialize() {
        return new Map<String, Object> { fieldName => parent.serialize() };
    }

    public void postBuildProcess( Object objectToProcess ) {
        parent.postBuildProcess( ((Sobject)objectToProcess).getSobject( fieldName ) );
    }

}