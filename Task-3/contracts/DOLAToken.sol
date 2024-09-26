// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract DOLA is ERC20, Ownable, ERC20Permit{

    // Price feed for the ROI token
    AggregatorV3Interface public priceFeed;

    // Address of the collateral token (BDOLA)
    ERC20 public collateralToken;
    
    // Mapping to track user collateral
    mapping(address => uint256) public collateralBalances;
    
    // Collateralization ratio (100 means 100%)
    uint256 public collateralizationRatio = 100;

    // Events for logging
    event Minted(address indexed user, uint256 amount);
    event Burned(address indexed user, uint256 amount);
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // Constructor with token name and symbol
    constructor(address _initialOwner, address _collateralToken, address _priceFeedAddress)
        Ownable(_initialOwner)
        ERC20("DOLAToken", "DOLA") // Pass the name and symbol to ERC20 constructor
        ERC20Permit("DOLAToken")
        {
            collateralToken = ERC20(_collateralToken);
            priceFeed = AggregatorV3Interface(_priceFeedAddress);
        }
    function getROIPrice() internal view returns (int){
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function mint(uint256 amount) external {
  
        require(amount > 0, "Amount must be greater than 0");
        // Get the current price of the collateral token
        // uint256 ROIPrice = uint256(getROIPrice());
        uint256 ROIPrice = 2;

        // console.log(ROIPrice);
        // uint256 ROIPrice = 1;
        
        //deviation = ROI price-DOLA price
        int deviation = 0;
        uint256 fee = amount*5/100;

        // Adjust collateralization ratio based on price data
        uint256 currentCollateralizationRatio = ROIPrice * collateralizationRatio;
        require(collateralBalances[msg.sender] * currentCollateralizationRatio / 100 >= amount, "Insufficient collateral");
        
        // Calculate the adjusted fee based on the deviation
        if (deviation > 0) {
            fee = fee + uint256(deviation)*uint256(deviation)/100; 
        } else if (deviation < 0) {
            fee = fee - uint256(-deviation)*uint256(-deviation)/100;
        }

        // Mint new DOLA tokens
        _mint(msg.sender, amount-fee);
        emit Minted(msg.sender, amount-fee);
    }

    function burn(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient DOLA balance");
        // Burn DOLA tokens
        _burn(msg.sender, amount);
        emit Burned(msg.sender, amount);
    }

    function depositCollateral(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        // Transfer collateral tokens from user to this contract
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralBalances[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdrawCollateral(uint256 amount) external {
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");
        
        // Check that the user has enough collateral remaining after withdrawal
        require((collateralBalances[msg.sender] - amount) * collateralizationRatio / 100 >= totalSupply(), "Not enough collateral remaining");

        collateralBalances[msg.sender] -= amount;
        collateralToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getCollateralBalance(address user) external view returns (uint256) {
        return collateralBalances[user];
    }
}
