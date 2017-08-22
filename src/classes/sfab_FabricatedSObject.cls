public virtual class sfab_FabricatedSObject {
    private Type sType;
    @testVisible private List<sfab_FabricatedSObjectNode> nodes = new List<sfab_FabricatedSObjectNode>();

    public sfab_FabricatedSObject(Type sType) {
        this.sType = sType;
    }

    @testVisible protected sfab_FabricatedSObject(Type sType, List<sfab_FabricatedSObjectNode> nodes) {
        this.sType = sType;
        this.nodes = nodes;
    }

    public sfab_FabricatedSObject setField(Schema.SObjectField field, Object value) {
        nodes.add(new sfab_FieldValuePairNode(field, value));
        return this;
    }

    public sfab_FabricatedSObject setParent(String relationshipName, sfab_FabricatedSObject vSObject) {
        nodes.add(new sfab_ParentRelationshipNode(relationshipName, vSObject));
        return this;
    }

    public sfab_FabricatedSObject setChildren(String relationshipName, List<sfab_FabricatedSObject> vSObjects) {
        nodes.add(new sfab_ChildRelationshipNode(relationshipName, vSObjects));
        return this;
    }

    public Type getType() {
        return sType;
    }

    public virtual Map<String, Object> serialize() {
        Map<String, Object> fields = new Map<String, Object>();

        for (sfab_FabricatedSObjectNode node : nodes) {
            fields.putAll(node.build());
        }

        return fields;
    }
}