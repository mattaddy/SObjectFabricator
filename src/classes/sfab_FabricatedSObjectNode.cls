public interface sfab_FabricatedSObjectNode {
    Map<String, Object> serialize();
    void postBuildProcess( Object objectToProcess );
    String getName();
}