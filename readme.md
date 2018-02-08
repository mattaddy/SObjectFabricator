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

### Detailed example

```java
sfab_FabricatedSObject fabricatedAccount = new sfab_FabricatedSObject(Account.class);
fabricatedAccount.setField(Account.Id, '001000000000001');
fabricatedAccount.setField(Account.LastModifiedDate, Date.newInstance(2017, 1, 1));

fabricatedAccount.setChildren('Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject(Opportunity.class).setField(Opportunity.Id, '001000000000001'),
        new sfab_FabricatedSObject(Opportunity.class).setField(Opportunity.Id, '001000000000002')
});

Account acct = (Account) fabricatedAccount.toSObject();

// Account:{LastModifiedDate=2017-01-01 00:00:00, Id=001000000000001}
System.debug(acct);

// (Opportunity:{Id=001000000000001}, Opportunity:{Id=001000000000002})
System.debug(acct.Opportunities);

sfab_FabricatedSObject fabricatedOpportunity = new sfab_FabricatedSObject(Opportunity.class);
fabricatedOpportunity.setField(Opportunity.Id, '001000000000003');
fabricatedOpportunity.setParent('Account', fabricatedAccount);

Opportunity opp = (Opportunity) fabricatedOpportunity.toSObject();

// Opportunity:{Id=001000000000003}
System.debug(opp);

// Account:{LastModifiedDate=2017-01-01 00:00:00, Id=001000000000003}
System.debug(opp.Account);
```

### Set non-relationship field values in bulk

```java
Map<SObjectField, Object> accountValues = new Map<SObjectField, Object> {
        Account.Id => '001000000000001',
        Account.LastModifiedDate => Date.newInstance(2017, 1, 1)
};

Account fabricatedAccount = (Account)new sfab_FabricatedSObject(Account.class, accountValues).toSObject();
```

### Fluent API

The example above is a bit verbose. We can simplify it by leveraging the fluent API provided by sfab_FabricatedSObject.

```java
Account acct = (Account)new sfab_FabricatedSObject(Account.class)
    .setField(Account.Id, '001000000000001')
    .setField(Account.LastModifiedDate, Date.newInstance(2017, 1, 1))
    .setChildren('Opportunities', new List<sfab_FabricatedSObject> {
        new sfab_FabricatedSObject(Opportunity.class).setField(Opportunity.Id, '001000000000001'), 
        new sfab_FabricatedSObject(Opportunity.class).setField(Opportunity.Id, '001000000000002')
    }).toSObject();
```

### You can use Id generators, too

Since the record's `Id` is passed as a string, it is possible to use a generator class, like the one featured in [Financial Force's Apex Mocks library](https://github.com/financialforcedev/fflib-apex-mocks/blob/master/src/classes/fflib_IDGenerator.cls):

For example, to create an opportunity with a given number of products, without actually creating the product records:

```java
Opportunity opportunity_a = (Opportunity) new sfab_FabricatedSObject(Opportunity.class)
    .setField(Opportunity.Id, IDGenerator.generate(Opportunity.SObjectType))
    .setField(Opportunity.TotalOpportunityQuantity, 1)
    .toSObject();
// Opportunity:{TotalOpportunityQuantity=1.0, Id=006000000000001}
System.debug(opportunity_a);
```

Since the field is generated from the number of `OpportunityLineItem` records related to the opportunity, that field would be 1 or more only if we inserted the opportunity record to the database and after that inserted an line item.
