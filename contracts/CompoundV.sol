pragma solidity ^0.7.3;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './VTokenInterface.sol';
import './VEthInterface.sol';
import './VComptrollerInterface.sol';

contract CompoundV {
  VComptrollerInterface public vComptroller;
  VEthInterface public vEth;

  constructor(
    address _vComptroller,
    address _vEthAddress
  ) {
    vComptroller = VComptrollerInterface(_vComptroller);
    vEth = VEthInterface(_vEthAddress);
  }

  function supply(address vTokenAddress, uint underlyingAmount) internal {
    VTokenInterface vToken = VTokenInterface(vTokenAddress);
    address underlyingAddress = vToken.underlying(); 
    IERC20(underlyingAddress).approve(vTokenAddress, underlyingAmount);
    uint result = vToken.mint(underlyingAmount);
    require(
      result == 0, 
      'vToken#mint() failed. see Compound ErrorReporter.sol for details'
    );
  }

  function supplyEth(uint underlyingAmount) internal {
    vEth.mint{value: underlyingAmount}();
  }

  function redeem(address vTokenAddress, uint underlyingAmount) internal {
    VTokenInterface vToken = VTokenInterface(vTokenAddress);
    uint result = vToken.redeemUnderlying(underlyingAmount);
    require(
      result == 0,
      'vToken#redeemUnderlying() failed. see Compound ErrorReporter.sol for more details'
    );
  }

  function redeemEth(uint underlyingAmount) internal {
    uint result = vEth.redeemUnderlying(underlyingAmount);
    require(
      result == 0,
      'vEth#redeemUnderlying() failed. see Compound ErrorReporter.sol for more details'
    );
  }

  function claimCompV() internal {
    vComptroller.claimCompV(address(this));
  }

  function getCompVAddress() internal view returns(address) {
    return vComptroller.getCompVAddress();
  }

  function getUnderlyingAddress(
    address vTokenAddress
  ) 
    internal 
    view 
    returns(address) 
  {
    return VTokenInterface(vTokenAddress).underlying();
  }

  function getvTokenBalance(address vTokenAddress) public view returns(uint){
    return VTokenInterface(vTokenAddress).balanceOf(address(this));
  }

  function getUnderlyingBalance(address vTokenAddress) public returns(uint){
    return VTokenInterface(vTokenAddress).balanceOfUnderlying(address(this));
  }

  function getUnderlyingEthBalance() public returns(uint){
    return vEth.balanceOfUnderlying(address(this));
  }
}