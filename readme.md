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

```java
FabricatedSObject fabricatedAccount = new FabricatedSObject(Account.class);
fabricatedAccount.setField(Account.Id, 'Id-1');
fabricatedAccount.setField(Account.LastModifiedDate, Date.newInstance(2017, 1, 1));

fabricatedAccount.setChildren('Opportunities', new List<FabricatedSObject> {
        new FabricatedSObject(Opportunity.class).setField(Opportunity.Id, 'OppId-1'),
        new FabricatedSObject(Opportunity.class).setField(Opportunity.Id, 'OppId-2')
});

Account acct = (Account)new SObjectFabricator().fabricate(fabricatedAccount);

// Account:{LastModifiedDate=2017-01-01 00:00:00, Id=Id-1}
System.debug(acct);

// (Opportunity:{Id=OppId-1}, Opportunity:{Id=OppId-2})
System.debug(acct.Opportunities);

FabricatedSObject fabricatedOpportunity = new FabricatedSObject(Opportunity.class);
fabricatedOpportunity.setField(Opportunity.Id, 'OppId-3');
fabricatedOpportunity.setParent('Account', fabricatedAccount);

Opportunity opp = (Opportunity)new SObjectFabricator().fabricate(fabricatedOpportunity);

// Opportunity:{Id=OppId-2}
System.debug(opp);

// Account:{LastModifiedDate=2017-01-01 00:00:00, Id=Id-1}
System.debug(opp.Account);
```

## Improvements
* Instances of FabricatedSObjectStub are being constructed in too many test classes. Find a way to reduce the amount of times we're calling new on that class.
