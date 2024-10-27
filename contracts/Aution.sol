// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Auction {
    
    // Data
    
    // Structure to hold details of Bidder
    struct IBidder {
        uint8 token;
        uint8 deposit;
    }
    
    // Structure to hold details of Rule
    struct IRule {
        uint8 startingPrice;
        uint8 minimumStep;
    }
    
    
    // State Enum to define Auction's state
    enum State { CREATED, STARTED, CLOSING, CLOSED }
    
    State public state = State.CREATED; // State of Auction
    
    uint8 public announcementTimes = 0; // Number of announcements
    uint8 public currentPrice = 0; // Latest price is bid.
    IRule public rule; // Rule of this session
    address public currentWinner; // Current Winner, who bid the highest price.
    address public auctioneer;
    
    uint16 private totalDeposit = 0;
    
    mapping(address => IBidder) public bidders; // Mapping to hold bidders' information
    
    constructor(uint8 _startingPrice, uint8 _minimumStep) {
        
        // Task #1 - Initialize the Smart contract
        // + Initialize Auctioneer with address of smart contract's owner
        // + Set the starting price & minimumStep
        // + Set the current price as the Starting price
        
        
        // ** Start code here. 4 lines approximately. ** /
        auctioneer = msg.sender;
        rule = IRule({startingPrice: _startingPrice, minimumStep: _minimumStep});
        currentPrice = _startingPrice;
        // ** End code here. ** /
    }
    
    
    // Register new Bidder
    function register(address _account, uint8 _token) public onlyAuctioneer stateMustbeCreated { 
        
                
        // Task #2 - Register the bidder
        // + Initialize a Bidder with address and token are given.
        // + Initialize a Bidder's deposit with 0
        
        // ** Start code here. 3 lines approximately. ** /
        IBidder memory bidder = IBidder({ token: _token, deposit: 0 });
        bidders[_account] = bidder;
	   // ** End code here. **/
    }

    
    // Start the session.
    function startSession() public onlyAuctioneer stateMustbeCreated {
        state = State.STARTED;
    }
    

    
    function bid(uint8 _price) public onlyBidder stateMustbeStarted {
        
        // Task #3 - Bid by Bidders
        // + Check the price with currentPirce and minimumStep. Revert if invalid.
        // + Check if the Bidder has enough token to bid. Revert if invalid.
        // + Move token to Deposit.
        
        address bidderAddr = msg.sender;
        IBidder storage currentBidder = bidders[bidderAddr];
        
        // ** Start code here.  ** /

        // Tracking deposit
        require(_price >= currentPrice + rule.minimumStep, "Price must greater than current price and minimum step");
        require(currentBidder.token >= _price, "Bidder do not have enough tokens");
		totalDeposit += _price;
        currentBidder.token -= _price;
        currentBidder.deposit += _price;
        // ** End code here. **/
        

        
        // Update the price and the winner after this bid.
        currentPrice = _price;
        currentWinner = bidderAddr;
        
        // Reset the Annoucements Counter
        announcementTimes = 0;
    }
    
    function announce() public onlyAuctioneer stateMustbeStarted {
        
        // Task #4 - Handle announcement.
        // + When Auctioneer annouce, increase the counter.
        // + When Auctioneer annouced more than 3 times, switch session to Closing state.
        
        // ** Start code here.  ** /
       announcementTimes++;
       if (announcementTimes > 3) {
        state = State.CLOSING;
        totalDeposit -= currentPrice;
       }
        // ** End code here. **/
    }
    
    function getDeposit() public onlyBidder stateMustbeClosing {
        
        // Task #5 - Handle get Deposit.
        // + Allow bidders (except Winner) to withdraw their deposit 
		// + When all bidders' deposit are withdrew, close the session 
        
        // ** Start code here.  ** /
        // HINT: Remember to decrease totalDeposit.
        address bidderAddr = msg.sender;
        IBidder storage currentBidder = bidders[bidderAddr];

        require(currentBidder.deposit > 0, "Only get deposit when deposit greater than 0");
        
        currentBidder.token += currentBidder.deposit;
        totalDeposit -= currentBidder.deposit;
        currentBidder.deposit = 0;
	   
       // ** End code here ** /
       
       if (totalDeposit <= 0) {
           state = State.CLOSED;
       }
    }

    modifier onlyAuctioneer {
        // ** Start code here. 2 lines approximately. **
        require(msg.sender == auctioneer, "Only auctioneer can do this action");
        _;
        //** End code here. **
    }

    modifier onlyBidder {
        require(bidders[msg.sender].token > 0, "Only bidders with remain token can do this action");
        _;
    }

    modifier stateMustbeCreated {
        //   enum State { CREATED, STARTED, CLOSING, CLOSED }
        require(state == State.CREATED, "Current state is not created");
        _;
    }

    modifier stateMustbeStarted {
        require(state == State.STARTED, "Current state is not started");
        _;
    }

    modifier stateMustbeClosing {
        require(state == State.CLOSING, "Current state is not closing");
        _;
    }
     

}




// PART 2 - Using Modifier to:
// - Check if the action (startSession, register, bid, annoucement, getDeposit) can be done in current State.
// - Check if the current user can do the action.

