public class sfab_ChildRelationshipNode implements sfab_FabricatedSObjectNode {
    @testVisible private String fieldName;
    @testVisible private List<sfab_FabricatedSObject> children;

    public sfab_ChildRelationshipNode( String fieldName ) {
        this.fieldName = fieldName;
        this.children = new List<sfab_FabricatedSObject>();
    }

    public sfab_ChildRelationshipNode(String fieldName, List<sfab_FabricatedSObject> children) {
        this.fieldName = fieldName;
        this.children = children;
    }

    public sfab_ChildRelationshipNode addChild( sfab_FabricatedSObject child ) {
        this.children.add( child );
        return this;
    }

    public String getName() {
        return fieldName;
    }

    public Integer getNumberOfChildren() {
        return children.size();
    }

    public List<sfab_FabricatedSObject> getChildren() {
        return children;
    }

    public Map<String, Object> serialize() {
        List<Map<String, Object>> serializedChildren = new List<Map<String, Object>>();

        for (sfab_FabricatedSObject child : children) {
            serializedChildren.add(child.serialize());
        }

        return new Map<String, Object> {
                fieldName => new Map<String, Object> {
                        'totalSize' => children.size(),
                        'done' => true,
                        'records' => serializedChildren
                }
        };
    }

    public void postBuildProcess( Object objectToProcess ) {
        // Note: this relies on the deserialization of the Fabricated SObject returning the
        // child objects in same order as the input map, otherwise the Blob field values
        // will be applied to the wrong objects.  As far as we can tell, this is reliable
        // at the time of writing.  If it becomes not the case, this will need re-writing
        List<Sobject> childSobjects = ((Sobject)objectToProcess).getSObjects( fieldName );
        for ( Integer i=0; i<childSobjects.size(); i++ ) {
            children[i].postBuildProcess( childSobjects[i] );
        }
    }
}