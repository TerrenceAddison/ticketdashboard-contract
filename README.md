## Introduction

This project consists of 2 repositories, 1 for the frontend and the other is for the backend. This repository contains the contract side of the project. For frontend side you can check it [here](https://github.com/TerrenceAddison/ticketdashboard-ui).

Our project is an app for buying, trading(coming soon), selling(coming soon) tickets to any events one may host. The tickets are sold in the form of NFTs which can be any type you want totally customizable(coming soon) as per buyers choice. Users can host their events, participate in an event or just trade cool NFTs which were once an entry ticket to "Taylor's Swift Reputation tour". Build your collection, engage in a new way to sell and attract your audience using the power of web3.

This project is using Thirdweb's track 1 and polygon.


## Technologies Used
 * thirdweb release
 * thirdweb's ERC721 base contract
 * thirdweb Typescript SDK for frontend(refer [here](https://github.com/TerrenceAddison/ticketdashboard-ui))
 * Polygon


## Links

## Backend Description

Our project consist of 2 contracts `Event.sol` and `EventCreator.sol`. The `EventCreator` contract will allow you to create your own `Event` contract in which people will interact with to purchase tickets to your `Event`. 

`Event` consists of the details of the event that we need:
* EventDate
* PurchaseStartDate
* PurchaseEndDate
* ticketPrice
* eventName

These are the details we need to know to be able to create a complete contract. Tickets will only be mintable(cause ticket will be NFT) between the 2 purchase dates. 

To make it convenient for users, we also use chainlink's pricefeed for price conversion. Instead of calculating in the native currency(MATIC in our case), we can sell tickets in USD price. (MATIC/USD)

`EventCreator` is our contract for creating events. Users who wants to create events will interact with this contract to deploy their own `Event`. Other users are now able to purchase tickets to the event through that contract. To keep track of all events that has been deployed our `EventCreator` contract has mapping s_events. Storing all created events can get expensive, but we are taking advantage of polygon's scalability and cheap gas fee to ensure gas will not affect users.

We also have Coming Soon features due to the time limitation:
* customizable NFT
* trading / selling feature for NFT tickets.


## Commands

Run:
```bash
yarn install
```
to install all packages needed to compile the contract and make changes to the contract.

Run:
```bash
npx thirdweb release
```
to deploy it via thirdweb.



