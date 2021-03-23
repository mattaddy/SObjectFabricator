@isTest
public with sharing class sfab_ObjectDescriberTest {

    @isTest
    private static void getField_whenGivenAFieldThatExist_expectTheField() {
        SObjectField field = new sfab_ObjectDescriber()
                                    .getField( 'Contact', 'Id' );
        System.assertEquals( 'Id', field.getDescribe().getName() );
    }

    @isTest
    private static void getField_whenGivenAFieldThatDoesNotExist_expectNull() {
        SObjectField field = new sfab_ObjectDescriber()
                                    .getField( 'Contact', 'NotValid' );
        System.assertEquals( null, field );
    }

    @isTest
    private static void getField_whenGivenAnObjectThatDoesNotExist_expectNull() {
        SObjectField field = new sfab_ObjectDescriber()
                                    .getField( 'NotValid', 'Id' );
        System.assertEquals( null, field );
    }

    @isTest
    private static void objectHasSimpleFieldNamed_whenGivenASimpleField_expectTrue() {
        Boolean simpleField = new sfab_ObjectDescriber()
                                    .objectHasSimpleFieldNamed( 'Contact', 'AccountId' );
        System.assert( simpleField );
    }

    @isTest
    private static void objectHasSimpleFieldNamed_whenGivenParentRelationshipField_expectFalse() {
        Boolean simpleField = new sfab_ObjectDescriber()
                                    .objectHasSimpleFieldNamed( 'Contact', 'Account' );
        System.assert( !simpleField );
    }

    @isTest
    private static void objectHasSimpleFieldNamed_whenGivenChildRelationship_expectFalse() {
        Boolean simpleField = new sfab_ObjectDescriber()
                                    .objectHasSimpleFieldNamed( 'Account', 'Contacts' );
        System.assert( !simpleField );
    }

    @isTest
    private static void objectHasSimpleFieldNamed_whenGivenInvalidField_expectFalse() {
        Boolean simpleField = new sfab_ObjectDescriber()
                                    .objectHasSimpleFieldNamed( 'Account', 'NotAField' );
        System.assert( !simpleField );
    }

    @isTest
    private static void objectHasSimpleFieldNamed_whenGivenInvalidObject_expectFalse() {
        Boolean simpleField = new sfab_ObjectDescriber()
                                    .objectHasSimpleFieldNamed( 'NotAnObject', 'Id' );
        System.assert( !simpleField );
    }

    @isTest
    private static void objectHasSimpleFieldNamed_whenGivenANullObject_expectFalse() {
        Boolean simpleField = new sfab_ObjectDescriber()
                                    .objectHasSimpleFieldNamed( null, 'Id' );
        System.assert( !simpleField );
    }

    @isTest
    private static void objectHasSimpleFieldNamed_whenGivenANullField_expectFalse() {
        Boolean simpleField = new sfab_ObjectDescriber()
                                    .objectHasSimpleFieldNamed( 'Account', null );
        System.assert( !simpleField );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAValidRelationship_expectReturnTrue() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasParentRelationshipNamed( 'Contact', 'Account' );
        System.assert( hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAPolymorphicRelationship_expectReturnTrue() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasParentRelationshipNamed( 'Task', 'Owner' );
        System.assert( hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAnInvalidRelationship_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasParentRelationshipNamed( 'Contact', 'NotARelationship' );
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenAnInvalidObject_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasParentRelationshipNamed( 'NotAnObject', 'Account' );
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenANullObject_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasParentRelationshipNamed( null, 'Account' );
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void objectHasParentRelationshipNamed_whenGivenANullRelationship_expectReturnFalse() {
        Boolean hasParentRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasParentRelationshipNamed( 'Contact', null );
        System.assert( ! hasParentRelationshipNamed );
    }

    @isTest
    private static void getObjectTypesForParentRelationship_whenGivenAParentRelationshipName_expectObjectItRelatesTo() {
        List<String> targetObjectTypes = new sfab_ObjectDescriber()
                                                .getObjectTypesForParentRelationship( 'Contact', 'Account' );
        System.assertEquals( 1, targetObjectTypes.size() );
        System.assertEquals( 'Account', targetObjectTypes[0] );
    }

    @isTest
    private static void getObjectTypesForParentRelationship_whenGivenAPolymorphicParentRelationshipName_expectAllObjectsItRelatesTo() {
        List<String> targetObjectTypes = new sfab_ObjectDescriber()
                                                .getObjectTypesForParentRelationship( 'Task', 'Owner' );
        System.assertEquals( 2, targetObjectTypes.size() );
        System.assertEquals( 'Group', targetObjectTypes[0] );
        System.assertEquals( 'User', targetObjectTypes[1] );
    }

    @isTest
    private static void getObjectTypesForParentRelationship_whenGivenAnInvalidRelationshipName_expectEmptyList() {
        List<String> targetObjectTypes = new sfab_ObjectDescriber()
                                                .getObjectTypesForParentRelationship( 'Contact', 'AccountId' );
        System.assertEquals( 0, targetObjectTypes.size() );
    }

    @isTest
    private static void getObjectTypesForParentRelationship_whenGivenAnInvalidObjectName_expectEmptyList() {
        List<String> targetObjectTypes = new sfab_ObjectDescriber()
                                                .getObjectTypesForParentRelationship( 'Invalid', 'Account' );
        System.assertEquals( 0, targetObjectTypes.size() );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAValidRelationship_expectAFabObject() {
        sfab_FabricatedSObject fabricatedObject = new sfab_ObjectDescriber()
                                                    .buildFabricatedObjectForRelationship( 'Contact', 'Owner' );
        System.assertEquals( 'User', fabricatedObject.getSobjectName() );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAPolymorphicRelationship_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectDescriber()
                                                        .buildFabricatedObjectForRelationship( 'Task', 'Owner' );
        } catch ( sfab_ObjectDescriber.ParentRelationshipObjectCannotBeAutoCreatedException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship Task.Owner as it is polymorphic and so not possible to automatically ascertain which SObject to use', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAnInvalidRelationship_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectDescriber()
                                                        .buildFabricatedObjectForRelationship( 'Contact', 'Invalid' );
        } catch ( sfab_ObjectDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship Contact.Invalid because the relationship does not exist', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenAnInvalidObject_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectDescriber()
                                                        .buildFabricatedObjectForRelationship( 'Invalid', 'Account' );
        } catch ( sfab_ObjectDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship Invalid.Account because the object type does not exist', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenANullRelationship_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectDescriber()
                                                        .buildFabricatedObjectForRelationship( 'Contact', null );
        } catch ( sfab_ObjectDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship because the relationship name has not been specified', exceptionMessage );
    }

    @isTest
    private static void buildFabricatedObjectForRelationship_whenGivenANullObject_expectAnException() {

        String exceptionMessage;
        try {
            sfab_FabricatedSObject fabricatedObject = new sfab_ObjectDescriber()
                                                        .buildFabricatedObjectForRelationship( null, 'Account' );
        } catch ( sfab_ObjectDescriber.ParentRelationshipDoesNotExistException e ) {
            exceptionMessage = e.getMessage();
        }
        System.assertEquals( 'Cannot automatically create a Fabricated Object for the relationship because the object name has not been specified', exceptionMessage );
    }

    @isTest
    private static void objectHasChildRelationshipNamed_whenGivenAValidRelationship_expectReturnTrue() {
        Boolean hasChildRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasChildRelationshipNamed( 'Account', 'Contacts' );
        System.assert( hasChildRelationshipNamed );
    }

    @isTest
    private static void objectHasChildRelationshipNamed_whenGivenAnInvalidRelationship_expectReturnFalse() {
        Boolean hasChildRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasChildRelationshipNamed( 'Account', 'NotARelationship' );
        System.assert( ! hasChildRelationshipNamed );
    }

    @isTest
    private static void objectHasChildRelationshipNamed_whenGivenAnInvalidObject_expectReturnFalse() {
        Boolean hasChildRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasChildRelationshipNamed( 'NotAnObject', 'Account' );
        System.assert( ! hasChildRelationshipNamed );
    }

    @isTest
    private static void objectHasChildRelationshipNamed_whenGivenANullObject_expectReturnFalse() {
        Boolean hasChildRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasChildRelationshipNamed( null, 'Account' );
        System.assert( ! hasChildRelationshipNamed );
    }

    @isTest
    private static void objectHasChildRelationshipNamed_whenGivenANullRelationship_expectReturnFalse() {
        Boolean hasChildRelationshipNamed = new sfab_ObjectDescriber()
                                                    .objectHasChildRelationshipNamed( 'Contact', null );
        System.assert( ! hasChildRelationshipNamed );
    }

    @isTest
    private static void getObjectTypeForChildRelationship_whenGivenAChildRelationshipName_expectObjectItRelatesTo() {
        String targetObjectType = new sfab_ObjectDescriber()
                                                .getObjectTypeForChildRelationship( 'Account', 'Contacts' );
        System.assertEquals( 'Contact', targetObjectType );
    }

    @isTest
    private static void getObjectTypeForChildRelationship_whenGivenAnInvalidRelationshipName_expectNull() {
        String targetObjectType = new sfab_ObjectDescriber()
                                                .getObjectTypeForChildRelationship( 'Account', 'Contactylike' );
        System.assertEquals( null, targetObjectType );
    }

    @isTest
    private static void getObjectTypeForChildRelationship_whenGivenAnInvalidObjectName_expectNull() {
        String targetObjectType = new sfab_ObjectDescriber()
                                                .getObjectTypeForChildRelationship( 'Invalid', 'Account' );
        System.assertEquals( null, targetObjectType );
    }
}