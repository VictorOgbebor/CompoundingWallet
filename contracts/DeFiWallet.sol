pragma solidity ^0.7.3;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './CompoundV.sol';

contract Wallet is CompoundV {
  address public admin;

  constructor(
    address _vComptroller, 
    address _vEthAddress
  ) CompoundV(_vComptroller, _vEthAddress) {
    admin = msg.sender;
  }

  function deposit(
    address vTokenAddress, 
    uint underlyingAmount
  ) 
    onlyAdmin()
    external 
  {
    address underlyingAddress = getUnderlyingAddress(vTokenAddress);
    IERC20(underlyingAddress).transferFrom(msg.sender, address(this), underlyingAmount);
    supply(vTokenAddress, underlyingAmount);
  }

  function withdraw(
    address vTokenAddress, 
    uint underlyingAmount,
    address recipient
  ) 
    onlyAdmin()
    external  
  {
    require(
      getUnderlyingBalance(vTokenAddress) >= underlyingAmount, 
      'balance too low'
    );
    claimCompV();
    redeem(vTokenAddress, underlyingAmount);

    address underlyingAddress = getUnderlyingAddress(vTokenAddress); 
    IERC20(underlyingAddress).transfer(recipient, underlyingAmount);

    address compVAddress = getCompVAddress(); 
    IERC20 vCompToken = IERC20(compVAddress);
    uint compVAmount = vCompToken.balanceOf(address(this));
    vCompToken.transfer(recipient, compVAmount);
  }

  function withdrawEth(
    uint underlyingAmount,
    address payable recipient
  ) 
    onlyAdmin()
    external  
  {
    require(
      getUnderlyingEthBalance() >= underlyingAmount, 
      'balance too low'
    );
    claimCompV();
    redeemEth(underlyingAmount);

    recipient.transfer(underlyingAmount);

    address compVAddress = getCompVAddress(); 
    IERC20 vCompToken = IERC20(compVAddress);
    uint compVAmount = vCompToken.balanceOf(address(this));
    vCompToken.transfer(recipient, compVAmount);
  }

  receive() external payable {
    supplyEth(msg.value);
  }

  modifier onlyAdmin() {
    require(msg.sender == admin, 'only admin');
    _;
  }
}