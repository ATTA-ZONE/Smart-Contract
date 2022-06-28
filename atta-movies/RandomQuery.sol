// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract QueryRandom {

     uint256 public blockStart;

    constructor(uint256 _blockStart){
        blockStart = _blockStart;
    }

    function randomNumber(uint256 blockNumber) public view virtual returns (uint256) {
        uint256 randomResult = uint256(keccak256(abi.encodePacked(uint256(1000), blockhash(blockStart + blockNumber))));
        return randomResult;
    }

   
}