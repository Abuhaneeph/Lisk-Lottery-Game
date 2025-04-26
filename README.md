# Lisk Lottery Game

A simple Lisk-based lottery smart contract where players can register, make guesses, and win prizes.

## Overview

The Lottery Game is a blockchain-based game implemented in Solidity where:

1. Players register by paying a small registration fee (0.02 ETH)
2. Players make up to 2 guesses to match a randomly generated winning number
3. Winners share the prize pool equally
4. The game resets after prizes are distributed

## Contract Features

- Fixed registration fee (0.02 ETH)
- Limited guess attempts per player (2)
- Guessing range between 1-9
- Equal prize distribution among winners
- Game reset functionality

## Contract Structure

### State Variables

- `owner`: Contract deployer address
- `winningNumber`: Randomly generated number players try to guess
- `totalPrize`: Accumulated registration fees
- `gameActive`: Boolean indicating if the game is currently active
- `players`: Mapping of player addresses to their data (attempts, active status)
- `registeredPlayers`: Array of all registered player addresses
- `winners`: Array of addresses that guessed correctly
- `prevWinners`: Array of previous round winners

### Key Functions

- `register()`: Register for the game by paying the fee
- `guessNumber(uint8 _guess)`: Submit a guess
- `distributePrizes()`: Send winnings to winners and reset the game
- `getPrevWinners()`: View previous round winners

## Testing

The contract includes comprehensive test coverage using Forge:

- Basic unit tests verifying core functionality
- Revert tests ensuring proper error handling
- Fuzz tests validating behavior with randomized inputs
 

### Test Cases

- Game initialization
- Player registration
- Guess submission
- Multiple guesses
- Prize distribution
- Error handling for:
  - Double registration
  - Incorrect fees
  - Unregistered players
  - Exceeding max attempts
  - Out-of-range guesses
  - Distributing with no winners

## Implementation Details

### Random Number Generation

The contract uses a simplified random number generation method:

```solidity
function _generateRandomNumber() internal view returns (uint256) {
    return uint256(
        keccak256(
            abi.encodePacked(
                block.timestamp,
                block.prevrandao,
                blockhash(block.number - 1)
            )
        )
    ) % (MAX_GUESS - MIN_GUESS + 1) + MIN_GUESS;
}
```

> **Note**: This implementation is for educational purposes. Production applications should use more secure randomness sources like Chainlink VRF.

## Security Considerations

- The random number generation is not cryptographically secure
- No admin functions to handle edge cases
- No time limits on game rounds

## Development Setup

### Prerequisites

- [Foundry](https://getfoundry.sh/) (for testing)
- Solidity ^0.8.13

### Testing

Run the test suite with:

```bash
forge test
```

### Deployment

Deploy to a local development network or testnet using your preferred deployment tool.

## Future Improvements

- Implement more secure randomness using Chainlink VRF
- Add time limits for game rounds
- Create an admin panel for contract management
- Add more sophisticated prize distribution mechanisms
- Improve gas efficiency for larger player pools
