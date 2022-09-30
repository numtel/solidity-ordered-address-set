// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @notice Key sets with enumeration and delete. Uses mappings for random
 * and existence checks and bytes for enumeration. Key uniqueness is enforced.
 * @dev Sets are ordered, no operations reorder keys. All operations have a
 * fixed gas cost at any scale, O(1), except searchKey()
 * author: numtel <ben (at) latenightsketches.com>
 * adapted from https://github.com/rob-Hitchens/SetTypes
 */
library OrderedAddressSet {
  struct Set {
      mapping(address => bool) keyPointers;
      bytes keyList;
  }
  /**
   * @notice insert a key.
   * @dev duplicate keys are not permitted.
   * @param self storage pointer to a Set.
   * @param key value to insert.
   * @param atIndex location to place this key
   */
  function insert(Set storage self, address key, uint atIndex) internal {
      require(!exists(self, key), "OrderedAddressSet: key already exists in the set.");
      require(atIndex <= count(self), "OrderedAddressSet: out of bounds");
      self.keyPointers[key] = true;
      self.keyList =
        concat(
          concat(slice(self.keyList, 0, atIndex * 20), abi.encodePacked(key)),
          slice(self.keyList, atIndex * 20, self.keyList.length - (atIndex * 20))
        );
  }

  /**
   * @notice remove a key.
   * @dev key to remove must exist.
   * @param self storage pointer to a Set.
   * @param atIndex item to remove.
   */
  function remove(Set storage self, uint atIndex) internal {
      require(atIndex * 20 < self.keyList.length, "OrderedAddressSet: out of bounds");
      delete self.keyPointers[keyAtIndex(self, atIndex)];
      if(atIndex == 0) {
        self.keyList = slice(self.keyList, 20, self.keyList.length - 20);
      } else if(atIndex == count(self) - 1) {
        self.keyList = slice(self.keyList, 0, self.keyList.length - 20);
      } else {
        self.keyList =
          concat(
            slice(self.keyList, 0, atIndex * 20),
            slice(self.keyList, (atIndex + 1) * 20, self.keyList.length - ((atIndex + 1) * 20))
          );
      }
  }

  /**
   * @notice count the keys.
   * @param self storage pointer to a Set.
   */
  function count(Set storage self) internal view returns(uint) {
      return(self.keyList.length / 20);
  }

  /**
   * @notice check if a key is in the Set.
   * @param self storage pointer to a Set.
   * @param key value to check.
   * @return bool true: Set member, false: not a Set member.
   */
  function exists(Set storage self, address key) internal view returns(bool) {
      if(self.keyList.length == 0) return false;
      return self.keyPointers[key] == true;
  }

  /**
   * @notice fetch a key by row (enumerate).
   * @param self storage pointer to a Set.
   * @param index row to enumerate. Must be < count() - 1.
   */
  function keyAtIndex(Set storage self, uint index) internal view returns(address) {
    return toAddress(self.keyList, index * 20);
  }

  /**
   * @notice scan for a key, return its index.
   * @param self storage pointer to a Set.
   * @param key value to find.
   */
  function searchKey(Set storage self, address key) internal view returns(uint) {
    require(exists(self, key));
    uint total = count(self);
    for(uint i = 0; i < total; i++) {
      if(keyAtIndex(self, i) == key) {
        return i;
      }
    }
    // Will never happen but shut up the compiler warning
    return type(uint).max;
  }

  /**
   * Solidity Bytes Arrays Utils
   * author Gonçalo Sá <goncalo.sa (at) consensys.net>
   *
   * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity. (Selected functions for this library: toAddress, concat, and slice)
   */
  function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
      require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
      address tempAddress;

      assembly {
          tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
      }

      return tempAddress;
  }

  function concat(
      bytes memory _preBytes,
      bytes memory _postBytes
  )
      internal
      pure
      returns (bytes memory)
  {
      bytes memory tempBytes;

      assembly {
          // Get a location of some free memory and store it in tempBytes as
          // Solidity does for memory variables.
          tempBytes := mload(0x40)

          // Store the length of the first bytes array at the beginning of
          // the memory for tempBytes.
          let length := mload(_preBytes)
          mstore(tempBytes, length)

          // Maintain a memory counter for the current write location in the
          // temp bytes array by adding the 32 bytes for the array length to
          // the starting location.
          let mc := add(tempBytes, 0x20)
          // Stop copying when the memory counter reaches the length of the
          // first bytes array.
          let end := add(mc, length)

          for {
              // Initialize a copy counter to the start of the _preBytes data,
              // 32 bytes into its memory.
              let cc := add(_preBytes, 0x20)
          } lt(mc, end) {
              // Increase both counters by 32 bytes each iteration.
              mc := add(mc, 0x20)
              cc := add(cc, 0x20)
          } {
              // Write the _preBytes data into the tempBytes memory 32 bytes
              // at a time.
              mstore(mc, mload(cc))
          }

          // Add the length of _postBytes to the current length of tempBytes
          // and store it as the new length in the first 32 bytes of the
          // tempBytes memory.
          length := mload(_postBytes)
          mstore(tempBytes, add(length, mload(tempBytes)))

          // Move the memory counter back from a multiple of 0x20 to the
          // actual end of the _preBytes data.
          mc := end
          // Stop copying when the memory counter reaches the new combined
          // length of the arrays.
          end := add(mc, length)

          for {
              let cc := add(_postBytes, 0x20)
          } lt(mc, end) {
              mc := add(mc, 0x20)
              cc := add(cc, 0x20)
          } {
              mstore(mc, mload(cc))
          }

          // Update the free-memory pointer by padding our last write location
          // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
          // next 32 byte block, then round down to the nearest multiple of
          // 32. If the sum of the length of the two arrays is zero then add
          // one before rounding down to leave a blank 32 bytes (the length block with 0).
          mstore(0x40, and(
            add(add(end, iszero(add(length, mload(_preBytes)))), 31),
            not(31) // Round down to the nearest 32 bytes.
          ))
      }

      return tempBytes;
  }

  function slice(
      bytes memory _bytes,
      uint256 _start,
      uint256 _length
  )
      internal
      pure
      returns (bytes memory)
  {
      require(_length + 31 >= _length, "slice_overflow");
      require(_bytes.length >= _start + _length, "slice_outOfBounds");

      bytes memory tempBytes;

      assembly {
          switch iszero(_length)
          case 0 {
              // Get a location of some free memory and store it in tempBytes as
              // Solidity does for memory variables.
              tempBytes := mload(0x40)

              // The first word of the slice result is potentially a partial
              // word read from the original array. To read it, we calculate
              // the length of that partial word and start copying that many
              // bytes into the array. The first word we copy will start with
              // data we don't care about, but the last `lengthmod` bytes will
              // land at the beginning of the contents of the new array. When
              // we're done copying, we overwrite the full first word with
              // the actual length of the slice.
              let lengthmod := and(_length, 31)

              // The multiplication in the next line is necessary
              // because when slicing multiples of 32 bytes (lengthmod == 0)
              // the following copy loop was copying the origin's length
              // and then ending prematurely not copying everything it should.
              let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
              let end := add(mc, _length)

              for {
                  // The multiplication in the next line has the same exact purpose
                  // as the one above.
                  let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
              } lt(mc, end) {
                  mc := add(mc, 0x20)
                  cc := add(cc, 0x20)
              } {
                  mstore(mc, mload(cc))
              }

              mstore(tempBytes, _length)

              //update free-memory pointer
              //allocating the array padded to 32 bytes like the compiler does now
              mstore(0x40, and(add(mc, 31), not(31)))
          }
          //if we want a zero-length slice let's just return a zero-length array
          default {
              tempBytes := mload(0x40)
              //zero out the 32 bytes slice we are about to return
              //we need to do it because Solidity does not garbage collect
              mstore(tempBytes, 0)

              mstore(0x40, add(tempBytes, 0x20))
          }
      }

      return tempBytes;
  }
}
