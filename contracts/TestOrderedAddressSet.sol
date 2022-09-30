// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./OrderedAddressSet.sol";
using OrderedAddressSet for OrderedAddressSet.Set;

contract TestOrderedAddressSet {
  OrderedAddressSet.Set public test;

  function insert(address key, uint atIndex) external {
    test.insert(key, atIndex);
  }

  function remove(uint atIndex) external {
    test.remove(atIndex);
  }

  function count() external view returns(uint) {
    return test.count();
  }

  function exists(address key) external view returns(bool) {
    return test.exists(key);
  }

  function keyAtIndex(uint index) external view returns(address) {
    return test.keyAtIndex(index);
  }

  function searchKey(address key) external view returns(uint) {
    return test.searchKey(key);
  }
}
