public virtual class FabricatedSObject {
    private Type sType;
    @testVisible private List<FabricatedSObjectNode> nodes = new List<FabricatedSObjectNode>();

    public FabricatedSObject(Type sType) {
        this.sType = sType;
    }

    @testVisible protected FabricatedSObject(Type sType, List<FabricatedSObjectNode> nodes) {
        this.sType = sType;
        this.nodes = nodes;
    }

    public FabricatedSObject setField(Schema.SObjectField field, Object value) {
        nodes.add(new FieldValuePairNode(field, value));
        return this;
    }

    public FabricatedSObject setParent(String relationshipName, FabricatedSObject vSObject) {
        nodes.add(new ParentRelationshipNode(relationshipName, vSObject));
        return this;
    }

    public FabricatedSObject setChildren(String relationshipName, List<FabricatedSObject> vSObjects) {
        nodes.add(new ChildRelationshipNode(relationshipName, vSObjects));
        return this;
    }

    public Type getType() {
        return sType;
    }

    public virtual Map<String, Object> serialize() {
        Map<String, Object> fields = new Map<String, Object>();

        for (FabricatedSObjectNode node : nodes) {
            fields.putAll(node.build());
        }

        return fields;
    }
}