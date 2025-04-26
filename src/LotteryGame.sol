// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title LotteryGame
 * @dev A simple Ethereum-based lottery game where players register, make guesses and win prizes
 */
contract LotteryGame {
    // Constants for game rules
    uint256 public constant REGISTRATION_FEE = 0.02 ether;
    uint256 public constant MAX_ATTEMPTS = 2;
    uint256 public constant MIN_GUESS = 1;
    uint256 public constant MAX_GUESS = 9;
    
    // Struct to keep track of player information
    struct Player {
        uint8 attempts;      // Number of guessing attempts made
        bool active;         // Whether player is currently active
    }
    
    // State variables
    address public owner;
    uint256 private winningNumber;
    uint256 public totalPrize;
    bool public gameActive;
    
    // Data structures to track players and winners
    mapping(address => Player) public players;
    address[] public registeredPlayers;
    address[] public winners;
    address[] public prevWinners;
    
    // Events
    event PlayerRegistered(address indexed player);
    event GuessSubmitted(address indexed player, uint8 guess);
    event WinnerAdded(address indexed winner);
    event PrizesDistributed(uint256 prizePerWinner, uint256 winnersCount);
    event GameReset();
    
    // Constructor
    constructor() {
        owner = msg.sender;
        gameActive = true;
        winningNumber = _generateRandomNumber();
    }
    
    /**
     * @dev Allows a player to register for the game by paying exactly REGISTRATION_FEE
     */
    function register() external payable {
        require(gameActive, "Game is not active");
        require(msg.value == REGISTRATION_FEE, "Registration fee must be exactly 0.02 ETH");
        require(!players[msg.sender].active, "Player already registered");
        
        // Add player to the game
        players[msg.sender] = Player({
            attempts: 0,
            active: true
        });
        
        registeredPlayers.push(msg.sender);
        totalPrize += msg.value;
        
        emit PlayerRegistered(msg.sender);
    }
    
    /**
     * @dev Allows a registered player to make a guess
     * @param _guess The number guessed by the player (1-9)
     */
    function guessNumber(uint8 _guess) external {
        require(gameActive, "Game is not active");
        require(players[msg.sender].active, "Player not registered");
        require(players[msg.sender].attempts < MAX_ATTEMPTS, "Maximum attempts reached");
        require(_guess >= MIN_GUESS && _guess <= MAX_GUESS, "Guess must be between 1 and 9");
        
        // Increment attempts
        players[msg.sender].attempts += 1;
        
        emit GuessSubmitted(msg.sender, _guess);
        
        // Check if the guess is correct
        if (_guess == winningNumber) {
            winners.push(msg.sender);
            emit WinnerAdded(msg.sender);
        }
    }
    
    /**
     * @dev Distributes prizes to winners and resets the game
     * @return Number of winners who received prizes
     */
    function distributePrizes() external returns (uint256) {
        require(gameActive, "Game is not active");
        require(winners.length > 0, "No winners to distribute prizes to");
        
        uint256 prizePerWinner = totalPrize / winners.length;
        uint256 winnersCount = winners.length;
        
        // Store current winners for history
        prevWinners = winners;
        
        // Distribute prizes to winners
        for (uint256 i = 0; i < winnersCount; i++) {
            address winner = winners[i];
            payable(winner).transfer(prizePerWinner);
        }
        
        emit PrizesDistributed(prizePerWinner, winnersCount);
        
        // Reset game state
        _resetGame();
        
        return winnersCount;
    }
    
    /**
     * @dev Returns the list of previous round winners
     * @return Array of previous winner addresses
     */
    function getPrevWinners() external view returns (address[] memory) {
        return prevWinners;
    }
    
    /**
     * @dev Generates a random number between MIN_GUESS and MAX_GUESS
     * Note: This is a simplified implementation and not secure for production
     * @return A pseudo-random number
     */
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
    
    /**
     * @dev Resets the game state for a new round
     */
    function _resetGame() internal {
        // Reset game state variables
        gameActive = true;
        totalPrize = 0;
        winningNumber = _generateRandomNumber();
        
        // Clear player data
        for (uint256 i = 0; i < registeredPlayers.length; i++) {
            delete players[registeredPlayers[i]];
        }
        
        // Clear arrays
        delete registeredPlayers;
        delete winners;
        
        emit GameReset();
    }
}