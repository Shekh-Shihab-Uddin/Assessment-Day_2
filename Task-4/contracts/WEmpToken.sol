// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract WEmp is ERC20, Ownable {
    constructor(address initialOwner)
        ERC20("WrappedEmpressToken", "WEMP")
        Ownable(initialOwner)
    {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address _account,uint256 amount) public {
        _burn(_account, amount);
    }
}