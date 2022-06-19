//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract HilowCommissionsPayout is PaymentSplitter {
    constructor(address[] memory _addresses, uint256[] memory _shares)
        PaymentSplitter(_addresses, _shares)
    {}

    function tip() public payable {}
}

contract HilowSupporterNFTRoyaltyPayout is PaymentSplitter {
    constructor(address[] memory _addresses, uint256[] memory _shares)
        PaymentSplitter(_addresses, _shares)
    {}

    function tip() public payable {}
}
