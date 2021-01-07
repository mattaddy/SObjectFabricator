@isTest
public with sharing class sfab_ObjectRelationshipDescriberTest {

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAValidRelationship_expectReturnTrue() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectRelationshipDescriber()
                                                    .objectHasParentRelationshipNamed('Contact','Account');
        System.assert( hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAPolymorphicRelationship_expectReturnTrue() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectRelationshipDescriber()
                                                    .objectHasParentRelationshipNamed('Task','Owner');
        System.assert( hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAnInvalidRelationship_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectRelationshipDescriber()
                                                    .objectHasParentRelationshipNamed('Contact','NotARelationship');
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAnInvalidObject_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectRelationshipDescriber()
                                                    .objectHasParentRelationshipNamed('NotAnObject','Account');
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenANullObject_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectRelationshipDescriber()
                                                    .objectHasParentRelationshipNamed(null,'Account');
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenANullRelationship_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectRelationshipDescriber()
                                                    .objectHasParentRelationshipNamed('Contact',null);
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAValidRelationship_expectAFabObject() {
        sfab_FabricatedSObject fabricatedObject = new sfab_ObjectRelationshipDescriber()
                                                    .buildFabricatedObjectForRelationship('Contact','Owner');
        System.assertEquals( 'User', fabricatedObject.getSobjectName() );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAPolymorphicRelationship_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectRelationshipDescriber()
                                                        .buildFabricatedObjectForRelationship('Task','Owner');
        } catch ( sfab_ObjectRelationshipDescriber.ParentRelationshipObjectCannotBeAutoCreatedException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship Task.Owner as it is polymorphic and so not possible to automatically ascertain which SObject to use', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAnInvalidRelationship_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectRelationshipDescriber()
                                                        .buildFabricatedObjectForRelationship('Contact','Invalid');
        } catch ( sfab_ObjectRelationshipDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship Contact.Invalid because the relationship does not exist', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAnInvalidObject_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectRelationshipDescriber()
                                                        .buildFabricatedObjectForRelationship('Invalid','Account');
        } catch ( sfab_ObjectRelationshipDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship Invalid.Account because the object type does not exist', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenANullRelationship_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectRelationshipDescriber()
                                                        .buildFabricatedObjectForRelationship('Contact',null);
        } catch ( sfab_ObjectRelationshipDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship because the relationship name has not been specified', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenANullObject_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectRelationshipDescriber()
                                                        .buildFabricatedObjectForRelationship(null,'Account');
        } catch ( sfab_ObjectRelationshipDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship because the object name has not been specified', exceptionMessage );
    }
}