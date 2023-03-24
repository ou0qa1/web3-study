// SPDX-License-Identifier: UNLICENSED
// Sample from: DeFiHack - Phoenix_exp.sol
// For study only

pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../interface.sol";

// Just Change to Mainnet
contract ContractTest is Test {
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    SHITCOIN MYTOKEN;
    Uni_Router_V2 Router = Uni_Router_V2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function setUp() public{
        cheats.createSelectFork("https://mainnet.infura.io/v3/API");
        vm.label(address(USDC), "USDC");
        vm.label(address(WETH), "WETH");
        vm.label(address(Router), "Router");
    }

    function testExploit() public {
        deal(address(WETH), address(this), 7 * 1e15);
        MYTOKEN = new SHITCOIN();
        MYTOKEN.mint(1_500_000 * 1e18);
        MYTOKEN.approve(address(Router), type(uint256).max);
        WETH.approve(address(Router), type(uint256).max);
        Router.addLiquidity(address(MYTOKEN), address(WETH), 7 * 1e15, 7 * 1e15, 0, 0, address(this), block.timestamp);

        emit log_named_decimal_uint(
            "Balance", MYTOKEN.balanceOf(address(this)), MYTOKEN.decimals()
        );
    }

}

/* ################# */
/* Create New Token */
contract SHITCOIN {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "SHIT COIN";
    string public symbol = "SHIT";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address recipient, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint256 amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint256 amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
