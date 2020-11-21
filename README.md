<p align="center">
  <img width="450px" src="https://imgur.com/WjnPfQB.png">
</p>

<h1 align="center">GraphBanking API</h1>

<p align="center">
  <a href="https://graph-banking.herokuapp.com/"><img alt"Deploy status" src="https://img.shields.io/github/deployments/felipelincoln/graph-banking/graph-banking?label=deploy"></a>
  <a href="https://felipelincoln.github.io/graph-banking"><img alt="Docs status" src="https://img.shields.io/github/deployments/felipelincoln/graph-banking/github-pages?label=docs"></a>
  <a href="https://github.com/felipelincoln/graph-banking/actions"><img alt="Build status" src="https://img.shields.io/github/workflow/status/felipelincoln/graph-banking/CI"></a>
  <a href="https://coveralls.io/github/felipelincoln/graph-banking?branch=master"><img alt="Coverage status" src="https://coveralls.io/repos/github/felipelincoln/graph-banking/badge.svg?branch=master&kill_cache=1"></a>
</p>

<p align="center">A simple banking app implemented with GraphQL.</p>


## Introduction
This app exposes a few GraphQL endpoints to manipulate a sandbox database that simulates a bank. It is possible to open a new account, fetch account information and make currency transactions between two accounts.  
> The documentation for these features can be found here. [GraphBanking#summary](https://felipelincoln.github.io/graph-banking/GraphBanking.html#summary)

## Consuming the API.
* **Using IDEs**: If you are using some GraphQL IDE like Apollo, you can hit the endpoint https://graph-banking.herokuapp.com/ and start querying.
* **Using the built-in interface**: We provide an interface so you can hit the ground running, it is available at https://graph-banking.herokuapp.com/graphiql/

Since this is deployed to a Heroku free plan, the server may take some time to wakeup :sleeping:.

## Usage Examples
Creating an account using the `openAccount` mutation

```graphql
mutation {
  openAccount(currentBalance: 45.5){
    uuid
    currentBalance
  }
}
```
yields the following `.json` response.
```json
{
  "data": {
    "openAccount": {
      "currentBalance": 45.5,
      "uuid": "b135e3c2-3e95-47ea-b781-fcebd487dc2e"
    }
  }
}
```
Using the `account` query on some previously created account `4533be1c-ebc1-4bfa-aab7-643084e58b44`

```graphql
{
  account(uuid: "4533be1c-ebc1-4bfa-aab7-643084e58b44"){
    uuid
    currentBalance
  }
}
```
it is possible to retrieve the current balance.
```json
{
  "data": {
    "account": {
      "currentBalance": 0,
      "uuid": "4533be1c-ebc1-4bfa-aab7-643084e58b44"
    }
  }
}
```
Having two `uuid` it is possible to transfer money between them using the `transferMoney` mutation.
```graphql
mutation {
  transferMoney(
    sender: "b135e3c2-3e95-47ea-b781-fcebd487dc2e"
    address: "4533be1c-ebc1-4bfa-aab7-643084e58b44"
    amount: 32
  ) {
    address
    amount
    uuid
    when
  }
}
```
And the response is the transaction information.
```json
{
  "data": {
    "transferMoney": {
      "address": "4533be1c-ebc1-4bfa-aab7-643084e58b44",
      "amount": 32,
      "uuid": "17fad487-f31b-42c7-8658-9eee447ae4ce",
      "when": "2020-11-21 08:52:45Z"
    }
  }
}
```
