// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lottery {
    address payable[] public players;
    address public manager;

    constructor () {
        manager = msg.sender;        
    }

    receive() external payable {
        require(msg.value == 0.1 ether, 'Each player must send exact 0.1 ether');

        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager, 'Only manager can see the balance');

        return address(this).balance;
    }

    function random() internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players.length)));
    }

    function pickWinner() public {
        require(msg.sender == manager, 'Only manager can pick winner');
        require (players.length >= 0, 'Must have more than 3 players');

        uint r = random();

        address payable winner;

        uint index = r % players.length;

        winner = players[index];

        winner.transfer(getBalance());

        players = new address payable[](0);
    }
} 