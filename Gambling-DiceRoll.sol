//https://ropsten.etherscan.io/address/0xb95bbe8ee98a21b5ef7778ec1bb5910ea843f8f7#code

/**
 *Submitted for verification at Etherscan.io on 2017-03-02
*/

pragma solidity ^0.4.9;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract DiceRoll is owned {
	uint public minBet = 10 finney;
	uint public maxBet = 2 ether;
	uint private countRolls = 0;
	uint private totalEthSended = 0;
    mapping (address => uint) public totalRollsByUser;
    enum GameState {
		InProgress,
		PlayerWon,
		PlayerLose
	}
	
	event logAdr(
        address str
    );
	event logStr(
        string str
    );
	event log8(
        uint8 value
    );
	event log32(
        uint32 value
    );
	event log256(
        uint value
    );
	event logClassic(
        string str,
        uint8 value
    );
	event logState(
        string str,
        GameState state
    );
	event logCheck(
        uint value1,
        string sign,
        uint value2
    );
	
	struct Game {
		address player;
		uint bet;
		uint chance;
		GameState state;
		uint8 seed;
	}

	mapping (address => Game) public games;
	
	modifier gameIsNotInProgress() {
		if (gameInProgress(games[msg.sender])) {
			throw;
		}
		_;
	}
	
	modifier betValueIsOk() {
		if (msg.value < minBet || msg.value > maxBet) {
			throw; // incorrect bet
		}
		_;
	}
	
	function gameInProgress(Game game)
		constant
		private
		returns (bool)
	{
		if (game.player == 0) {
			return false;
		}
		if (game.state == GameState.InProgress) {
			return true;
		} else {
			return false;
		}
	}
	
	// starts a new game
	function roll(uint value) 
	    public 
	    payable 
	    gameIsNotInProgress
	    betValueIsOk 
	{
		if (gameInProgress(games[msg.sender])) {
			throw;
		}
		
		uint chance = value;
        totalRollsByUser[msg.sender]++;
        
		Game memory game = Game({
			player: msg.sender,
			bet: msg.value,
			chance: chance,
			state: GameState.InProgress,
			seed: 3,
		});
        
		games[msg.sender] = game;
		countRolls ++;
		
		uint rnd = randomGen(msg.sender);
		uint bet = msg.value;
		uint payout = bet*((10000-100)/value);
        uint profit = payout - bet;
        logAdr(msg.sender);
        log256(payout);
        log256(profit);
        log256(bet);
        log256(chance);
		
		if(rnd > value){
		    log8(0);
		    games[msg.sender].state = GameState.PlayerLose;
        } else {
            log8(1);
            
		    games[msg.sender].state = GameState.PlayerWon;
		    if(msg.sender.send(payout)) {
	            totalEthSended += payout;
	        } else {
	            logStr("Money is not send.");
	        }
        }
        
        logCheck(rnd, ">", value);
        logState("state:", games[msg.sender].state);
	}
	
	function randomGen(address player) public returns (uint) {
		uint b = block.number;
		uint timestamp = block.timestamp;
		return uint(uint256(keccak256(block.blockhash(b), player, timestamp)) % 10000);
	}
	
	function getCount() public constant returns (uint) {
		return totalRollsByUser[msg.sender];
	}
	
	function getState() public constant returns (GameState) {
		Game memory game = games[msg.sender];

		if (game.player == 0) {
			// game doesn't exist
			throw;
		}

		return game.state;
	}
	
	function getGameChance() public constant returns (uint) {
		Game memory game = games[msg.sender];
        
		if (game.player == 0) {
			// game doesn't exist
			throw;
		}

		return game.chance;
	}
	
	function getTotalRollMade() public constant returns (uint) {
		return countRolls;
	}
	
	function getTotalEthSended() public constant returns (uint) {
		return totalEthSended;
	}
}