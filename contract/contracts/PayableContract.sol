// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract PayableHilowContract {
    function sendFunds() external payable returns (bool) {
        return true;
    }
}
