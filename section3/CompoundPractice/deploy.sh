# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/CompoundDelegator.s.sol:CompoundDelegator --rpc-url $SEPOLIA_RPC_URL --broadcast --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv --force
# forge script script/CompoundDelegator.s.sol:CompoundDelegator --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY -vvvv --force
