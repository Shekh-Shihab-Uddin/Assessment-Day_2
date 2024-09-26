// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./EmpToken.sol";
import "./WEmpToken.sol";

contract Bridge {
    Emp public empToken;
    WEmp public wempToken;

    constructor(address _empTokenAddress, address _wempTokenAddress) {
        empToken = Emp(_empTokenAddress);
        wempToken = WEmp(_wempTokenAddress);
    }

    function swapEmptoWemp(uint256 amount) public {
        // Ensure BLS token is approved for transfer
        require(empToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        // Transfer EMP tokens to this contract
        empToken.transferFrom(msg.sender, address(this), amount);
        //send Wrapped token to user wallet
        wempToken.mint(msg.sender, amount);
    }

    function swapWempToEmp(uint256 amount) public {
        // Ensure sufficient stBLS balance
        require(wempToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
        // Burn stBLS tokens
        wempToken.burn(msg.sender, amount);
        // Transfer BLS tokens back to the staker
        empToken.transfer(msg.sender, amount);
    }
}
