# SObjectFabricator

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=mattaddy&repo=SObjectFabricator)

An SObject fabrication API to reduce database interactions and dependencies on triggers in Apex unit tests. Includes the ability to fabricate system and formula fields, rollup summaries, and child relationships. Strongly inspired by [Stephen Willcock](https://github.com/stephenwillcock)'s [Dreamforce presentation](https://www.youtube.com/watch?v=dWertK6Legc) on Tests and Testability in Apex.

## Motivation

> How many times do you have to execute a query to know that it works? - Robert C. Martin (Uncle Bob)

Databases and SOQL are slow, so we should mock them out for the majority of our tests. We should be able to drive our SObjects into the state in which the system can be tested.

In addition to queries, how many times do we need to test our triggers to know that they work?

Rather than relying on triggers to populate fields in our unit tests, or the results of a SOQL query to populate relationships, we should manually force our SObjects into the state in which the system can be tested.

## Fabricate Your SObjects

SObjectFabricator provides the ability to set any field value, including system, formula, rollup summaries, and relationships.

### Simple Example

Creating an SObject and setting properties on it can be as simple as:

```java
Account account = (Account)new sfab_FabricatedSObject( Account.class )
                            .set( 'Name'            , 'Account Name' )
                            .set( 'LastModifiedDate', Date.newInstance( 2017, 1, 1 ) )
                            .toSObject();
```

### Detailed Example

Although, not all fabrications are as simple as that.

With SObjectFabricator, you can:

```java
sfab_FabricatedSObject fabricatedAccount = new sfab_FabricatedSObject( Account.class );

// Set fields using SObjectField references, including those not normally settable:
fabricatedAccount.set( Account.Id, 'Id-1' );
fabricatedAccount.set( Account.LastModifiedDate, Date.newInstance( 2017, 1, 1 ) );

// Set fields using the names of the fields:
fabricatedAccount.set( 'Name', 'The Account Name' );

// Set lookup / master detail relationships
fabricatedAccount.set( 'Owner', new sfab_FabricatedSObject( User.class ).set( 'Username', 'TheOwner' ) );

// Set child relationships
fabricatedAccount.set( 'Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-1' ),
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-2' )
});

// Generate an SObject from that configuration
Account sObjectAccount = (Account)fabricatedAccount.toSObject();

// Account:{LastModifiedDate=2017-01-01 00:00:00, Id=Id-1, Name=The Account Name}
System.debug( sObjectAccount );

// User:{Username=TheOwner}
System.debug( sObjectAccount.Owner );

// (Opportunity:{Id=OppId-1}, Opportunity:{Id=OppId-2})
System.debug( sObjectAccount.Opportunities );
```

### Fluent API

The set methods form a fluent API, meaning you can condense the above configuration into:

```java
Account sObjectAccount = (Account)new sfab_FabricatedSObject( Account.class )
    .set( Account.Id, 'Id-1' )
    .set( Account.LastModifiedDate, Date.newInstance( 2017, 1, 1 ) )
    .set( 'Name', 'The Account Name' )
    .set( 'Owner', new sfab_FabricatedSObject( User.class ).set( 'Username', 'TheOwner' ) )
    .set( 'Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-1'),
        new sfab_FabricatedSObject( Opportunity.class ).set( 'Id', 'OppId-2')
    }).toSObject();
```

### Set non-relationship field values in bulk

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

### Set all field values in bulk

Field, Parent and Child Relationship values can be set in bulk, either at construction time, or later, by passing a `Map<String,Object>`.

```java
Map<String, Object> accountValues = new Map<String, Object> {
        'Id'                => 'Id-1',
        'LastModifiedDate'  => Date.newInstance(2017, 1, 1),
        'Contacts'          =>  new List<sfab_FabricatedSObject>{
                                    new sfab_FabricatedSObject( Contact.class )
                                        .set( 'Name', 'ContactName' )
                                },
        'Owner'              =>  new sfab_FabricatedSObject( User.class )
                                    .set( 'Username', 'The user' )
};

Account fabricatedViaConstructor = (Account)new sfab_FabricatedSObject(Account.class, accountValues)
                                                    .toSObject();


Account fabricatedViaSet = (Account)new sfab_FabricatedSObject(Account.class)
                                            .set(accountValues)
                                            .toSObject();
```

### More explicit API

If you prefer the set methods to be a little more explicit in their intention, you can use more specific versions of the `set` method.

```java
Account acct = (Account)new sfab_FabricatedSObject(Account.class)
    .setField(Account.Id, 'Id-1')
    .setField(Account.LastModifiedDate, Date.newInstance(2017, 1, 1))
    .setChildren('Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject(Opportunity.class).setField(Opportunity.Id, 'OppId-1'),
        new sfab_FabricatedSObject(Opportunity.class).setField(Opportunity.Id, 'OppId-2')
    }).toSObject();
```