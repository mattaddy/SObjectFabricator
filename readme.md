# SObjectFabricator

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=mattaddy&repo=SObjectFabricator)

An SObject fabrication API to reduce database interactions and dependencies on triggers in Apex unit tests. It includes the ability to fabricate system and formula fields, rollup summaries, and child relationships. Strongly inspired by [Stephen Willcock](https://github.com/stephenwillcock)'s [Dreamforce presentation](https://www.youtube.com/watch?v=dWertK6Legc) on Tests and Testability in Apex.

## Motivation

> How many times do you have to execute a query to know that it works? - Robert C. Martin (Uncle Bob)

Databases and SOQL are slow, so we should mock them out for the majority of our tests. We should be able to drive our SObjects into the state in which the system can be tested.

In addition to queries, how many times do we need to test our triggers to know that they work?

Rather than relying on triggers to populate fields in our unit tests, or the results of a SOQL query to populate relationships, we should manually force our SObjects into the state in which the system can be tested.

## Fabricate Your SObjects

SObjectFabricator provides the ability to set any field value, including system, formula, rollup summaries, and relationships.

### Simple Example

#### Setting fields

Creating an SObject and setting properties on it can be as simple as:

```java
Account accountSobject = (Account)new sfab_FabricatedSObject( Account.class )
                            .set( 'Name'            , 'Account Name' )
                            .set( 'LastModifiedDate', Date.newInstance( 2017, 1, 1 ) )
                            .toSObject();
```

#### Setting Parent Relationships

Creating an SObject with a Lookup or Master / Detail relationship set can be as simple as:

```java
Contact contactSobject = (Contact)new sfab_FabricatedSObject( Contact.class )
                            .set( 'LastName'    , 'PersonName' )
                            .set( 'Account.Name', 'Account Name' )
                            .toSObject();
```

#### Setting Child Relationships

Creating an SObject with a child relationship set can be as simple as:

```java
Account accountSobject = (Account)new sfab_FabricatedSObject( Account.class )
                            .set( 'Name'            , 'Account Name' )
                            .add( 'Contacts', new sfab_FabricatedSObject( Contact.class )
                                                    .set( 'LastName', 'PersonName' ) )
                            .add( 'Contacts', new sfab_FabricatedSObject( Contact.class )
                                                    .set( 'LastName', 'OtherPersonName' ) )
                            .toSObject();
```

### Detailed Examples

There are lots of other options.  With SObjectFabricator, you can:

```java
sfab_FabricatedSObject fabricatedAccount = new sfab_FabricatedSObject( Account.class );

// Set fields using SObjectField references, including those not normally settable:
fabricatedAccount.set( Account.Id, 'Id-1' );
fabricatedAccount.set( Account.LastModifiedDate, Date.newInstance( 2017, 1, 1 ) );

// Set fields using the names of the fields:
fabricatedAccount.set( 'Name', 'The Account Name' );

// Set lookup / master detail relationships explicitly
fabricatedAccount.set( 'Owner', new sfab_FabricatedSObject( User.class ).set( 'Username', 'TheOwner' ) );

// Set lookup / master detail relationships implicitly
fabricatedAccount.set( 'Owner.Alias', 'alias' );

// Set multi-leveled lookup / master detail relationships implicitly
fabricatedAccount.set( 'Owner.Profile.Name', 'System Administrator' );

// Set child relationships in one go
fabricatedAccount.set( 'Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-1' ),
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-2' )
});

// Set child relationships one-by-one
fabricatedAccount.add( 'Opportunities', new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-3' ) );
fabricatedAccount.add( 'Opportunities', new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-4' ) );

// Generate an SObject from that configuration
Account sObjectAccount = (Account)fabricatedAccount.toSObject();

// Account:{LastModifiedDate=2017-01-01 00:00:00, Id=Id-1, Name=The Account Name}
System.debug( sObjectAccount );

// User:{Username=TheOwner, Alias=alias}
System.debug( sObjectAccount.Owner );

// Profile:{Name=System Administrator}
System.debug( sObjectAccount.Owner.Profile );

// (Opportunity:{Id=OppId-1}, Opportunity:{Id=OppId-2}, Opportunity:{Id=OppId-3}, Opportunity:{Id=OppId-4})
System.debug( sObjectAccount.Opportunities );
```

Each of the mechanisms also allow you to navigate through parent structures:

```java
sfab_FabricatedSObject fabricatedContact = new sfab_FabricatedSObject( Contact.class );

fabricatedContact.set( 'Account.Name', 'The Account Name' );

fabricatedContact.set( 'Account.Owner', new sfab_FabricatedSObject( User.class ) );

fabricatedContact.set( 'Account.Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-1' ),
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-2' )
});

fabricatedContact.add( 'Account.Opportunities', new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-1' ) );

Contact sObjectContact = (Contact)fabricatedContact.toSObject();
```

### Fluent API

The set methods form a fluent API, meaning you can condense the configuration along the lines of

```java
Account sObjectAccount = (Account)new sfab_FabricatedSObject( Account.class )
    .set( Account.Id, 'Id-1' )
    .set( Account.LastModifiedDate, Date.newInstance( 2017, 1, 1 ) )
    .set( 'Name', 'The Account Name' )
    .set( 'Owner', new sfab_FabricatedSObject( User.class ).set( 'Username', 'TheOwner' ) )
    .set( 'Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-1' ),
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-2' )
    })
    .add( 'Opportunities', new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-3' ) ) // though, it would be odd to combine set
    .add( 'Opportunities', new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-4' ) ) // and add on a single child relationship
    .toSObject();
```

### Set non-relationship field values in bulk via field references

Field values can be set in bulk, either at construction time, or later (using `set`), by creating a `Map<SObjectField, Object>` of the fields that you wish to set and using that.

```java
Map<SObjectField, Object> accountValues = new Map<SObjectField, Object> {
        Account.Id => 'Id-1',
        Account.LastModifiedDate => Date.newInstance(2017, 1, 1)
};

Account fabricatedViaConstructor = (Account)new sfab_FabricatedSObject(Account.class, accountValues)
                                                    .toSObject();


Account fabricatedViaSet = (Account)new sfab_FabricatedSObject(Account.class)
                                            .set(accountValues)
                                            .toSObject();

```

### Set all field values in bulk via field name references

Field, Parent and Child Relationship values can be set in bulk, either at construction time, or later, by passing a `Map<String,Object>`.

```java
Map<String,Object> contactValues = new Map<String,Object> {
        'Id'                     => 'Id-1',

        'LastModifiedDate'       => Date.newInstance(2017, 1, 1),

        'Account.Name'           => 'The Account Name',

        'Owner'                  => new sfab_FabricatedSObject( User.class )
                                        .set( 'Username', 'The Contact Owner' ),

        'Account.Owner'          => new sfab_FabricatedSObject( User.class )
                                        .set( 'Username', 'The Account Owner' ),

        'Opportunities'          => new List<sfab_FabricatedSObject>{
                                        new sfab_FabricatedSObject( Opportunity.class )
                                            .set( 'Name', 'Contact Opportunity Name' )
                                    },
        'Account.Opportunities'  => new List<sfab_FabricatedSObject>{
                                        new sfab_FabricatedSObject( Opportunity.class )
                                            .set( 'Name', 'Account Opportunity Name' )
                                    }
};

Contact fabricatedViaConstructor = (Contact)new sfab_FabricatedSObject( Contact.class, contactValues )
                                                    .toSObject();

Contact fabricatedViaSet = (Contact)new sfab_FabricatedSObject(Contact.class)
                                            .set( contactValues )
                                            .toSObject();
```

### More explicit API

If you prefer the set methods to be a little more explicit in their intention, you can use more specific versions of the `set` method.

```java
Account sObjectAccount = (Account)new sfab_FabricatedSObject( Account.class )
    .setField( Account.Id, 'Id-1' )
    .setField( Account.LastModifiedDate, Date.newInstance( 2017, 1, 1 ) )
    .setParent( 'Owner', new sfab_FabricatedSObject( User.class ).setField( 'Username', 'TheOwner' ) )
    .setChildren( 'Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject( Opportunity.class ).setField( Opportunity.Id, 'OppId-1' ),
        new sfab_FabricatedSObject( Opportunity.class ).setField( Opportunity.Id, 'OppId-2' ) } )
    .addChild( 'Opportunities', new sfab_FabricatedSObject( Opportunity.class ).setField( 'Id', 'OppId-3') ) // though, it would be odd to combine setChildren
    .addChild( 'Opportunities', new sfab_FabricatedSObject( Opportunity.class ).setField( 'Id', 'OppId-4') ) // and addChild on a single child relationship
    .toSObject();
```