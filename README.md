# dex_dao
A decentralised exchange controlled by a DAO

The DAO is created with a token address set as the voting token, after creating the DAO, the DEX is constructed with the DAO's address on the chain.
To use the DEX, we must first add some token address' to the DAO, but to do that we need to first deposit our votes.

1- Deposit at least %20 of the votes (voting tokens) to the DAO contract using the _depositVotes function.

2- Create a new token contract, copy its address to the _startVotingProccess function.

3- Vote on the token you proposed.(at least %20 to pass)

4- End voting will be available to be called after 30 seconds of you starting the voting proccess.

5- Go to the DEX contract and call getApprovedTokens function.

6- Your token is now a part of the exchange, but you need market makers,

7- Put some of your tokens to the exchange, call the _marketMakerDeposit function with the desired amount

8- After doing steps 2-7 again for another token contract, you can now swap tokens on the DEX.




The chainlink interface is not used since the contract was never used on the main network, but if you decide to use it on the mainnet, you will need to remove some comments.
Eren Akyıldız -2021
