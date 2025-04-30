This repository contains a Solidity smart contract for managing a decentralized donation raffle on the Ethereum blockchain.

**Features:**

Donation Collection: Accepts Ether donations.
Raffle Tickets: Donors receive raffle tickets based on their contribution.
Prize Pool: A configurable percentage of the total donations forms the prize pool.
Secure Winner Selection: Utilizes Chainlink VRF (Verifiable Random Function) to ensure a provably fair and random selection of the raffle winner.
Automated Payout: Automatically transfers the prize amount to the winner's address.
Designated Recipient: The remaining donation amount (after the prize payout) is sent to a predefined recipient address.
Raffle Lifecycle Management: Implements different states (Open, Drawing, Closed, Completed) managed by the contract owner.
Time-Limited: The raffle automatically transitions to the drawing phase after a predefined duration.


**Technologies Used:**

Solidity
OpenZeppelin Contracts (Ownable)
Chainlink VRF (VRFConsumerBase)
