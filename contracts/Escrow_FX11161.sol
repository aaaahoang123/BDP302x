// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.3 <0.9.0;

contract Escrow {
    address payable public buyer;
    address payable public seller;
    address public arbiter;

    mapping(address => uint) totalAmount;

    enum State {
        awate_payment, awate_delivery, complete
    }

    State public state;

    constructor(
        address payable _buyer,
        address payable _sender
    ) {
        arbiter = msg.sender;
        buyer = _buyer;
        seller = _sender;
        state = State.awate_payment;
    }

    modifier instate(State expected_state) {
        require(state == expected_state);
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer || msg.sender == arbiter);
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller || msg.sender == arbiter);
        _;
    }

    function confirm_payment() onlyBuyer instate(State.awate_payment) public payable {
        state = State.awate_delivery;
    }

    function confirm_delivery() onlyBuyer instate(State.awate_delivery) public {
        seller.transfer(address(this).balance);
        state = State.complete;
    }

    function return_payment() onlySeller instate(State.awate_delivery) public {
        buyer.transfer(address(this).balance);
    }
}