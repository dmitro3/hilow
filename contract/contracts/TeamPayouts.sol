//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "./PayableContract.sol";

contract HilowCommissionsPayout is PaymentSplitter, PayableHilowContract {
    constructor(address[] memory _addresses, uint256[] memory _shares)
        PaymentSplitter(_addresses, _shares)
    {}

    receive() external payable override {}

    fallback() external payable {}

    function tip() public payable {}
}

// ["0xEB41A1304BDF757D660C6685Fd063E827892585b", "0x963d1821b0C1cA2787F9E273dF1e501007e74A47"]
// [60, 40]

contract HilowSupporterNFTRoyaltyPayout is
    PaymentSplitter,
    PayableHilowContract
{
    constructor(address[] memory _addresses, uint256[] memory _shares)
        PaymentSplitter(_addresses, _shares)
    {}

    receive() external payable override {}

    fallback() external payable {}

    function tip() public payable {}
}
