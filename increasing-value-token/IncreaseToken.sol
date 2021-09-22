pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract IncreaseToken is ERC20 {
    
    //dai is the only token which can use for buying this token,
    //maybe this could be a mapping for supporting different tokens
    address daiAddress = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; //polygon/matic token address
    
    /**
     * @dev Constructor for setting name and symbol.
     */
    constructor() public ERC20("IncreaseCoin", "UP") {}
    
    //modifier for expecting dai token
    modifier onlyDai(address token) {
        require(token == daiAddress, "We only accept dai token for purchasing our token");
        _;
    }

    //modifier for expecting the own token
    modifier onlyContractToken(address token) {
        require(token == address(this), "You only can swap our token back to dai");
        _;
    }

    //buy the IncreaseToken with dai
    //fee for the contract will reduce the real value but increasing the token value
    function buyContractToken(address token, uint256 amount) onlyDai(token) public payable {
        // swap stable dai into contract token
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 tokenAmount = SafeMath.div(amount, calculateTokenPrice());
        _mint(msg.sender, tokenAmount);
    }

    //sell the IncreaseToken for dai
    //fee for the contract will reduce the real value but increasing the token value
    function sellContractToken(address token, uint256 amount) onlyContractToken(token) public payable {
        // swap contract into stable dai
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 tokenAmount = SafeMath.div(amount, calculateTokenPrice());
        IERC20(token).transferFrom(address(this), msg.sender, tokenAmount);
    }

    //get the dai token which are hold by this contract
    function getDaiBalance() public view returns (uint256) {
        return ERC20(daiAddress).balanceOf(address(this));
    }
    
    //calculate the token price based on the locked dai tokens
    function calculateTokenPrice() public view returns (uint256) {
        uint256 realValue = getDaiBalance();
        uint256 existingTokens = totalSupply();
        uint256 currentPrice = realValue / existingTokens;
        uint256 priceWithFees = SafeMath.ceil(currentPrice, 10); //10 is 0.1%? because 100 is 1%?
        return priceWithFees;
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
}
