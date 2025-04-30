pragma solidity 0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Donation is Ownable, VRFConsumerBase{
    address payable donationRecipient;
    uint256 public raffleTicketprice;
    uint256 public raffleTicketsSold;
    uint256 public prizePercentage;
    uint256 public prizeToSend;
    uint256 public timeToStart;
    uint256 public timeToLive;




    mapping(uint256 => address) public ticketIdToOwner;
    mapping(address => uint256[]) public ticketOwner;
    

    enum RaffleState { Open, Drawing, Closed, Completed }
    RaffleState public currentState;


    event TicketSold(uint256 raffleTicketsSold,address ticketOwner);





    address constant VRF_COORDINATOR = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // VRF Coordinator
    address constant LINK_TOKEN = 0x779877A7B0D9E8603169DdbD7836e478b4624789; // LINK Token

    // Key Hash and Fee for the VRF request
    // Get these from Chainlink documentation for your testnet and desired security level
    bytes32 internal keyHash;
    uint internal fee;

    // Public variable to store the received random result
    

    // State variable to store the request ID of the last request
    bytes32 public lastRequestId;
    uint public winnerTicketId;
    address public winner;


    // Event to log the randomness request
    event RandomnessRequestSent(bytes32 indexed requestId, uint indexed fee);

    /**
     * @dev Constructor initializes the contract and sets VRF parameters.
     * Requires the addresses of the VRF Coordinator and LINK Token,
     * and the keyHash and fee for the VRF request.
     */
    constructor(uint256 LivingTime)
        Ownable(msg.sender) // Call Ownable's constructor
        VRFConsumerBase(VRF_COORDINATOR, LINK_TOKEN) // Call VRFConsumerBase's constructor
    {
        // Key Hash for the specific network and VRF configuration
        // Get this from Chainlink documentation for your testnet
        keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c; // Example Sepolia Key Hash

        // Fee in LINK tokens required for the VRF request
        // Get this from Chainlink documentation. It's usually 0.1 LINK or similar.
        // LINK token uses 18 decimals.
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        donationRecipient=payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        raffleTicketprice=0.001*10**18;
        prizePercentage=30;
        timeToStart=block.timestamp;
        timeToLive=block.timestamp+LivingTime;
        currentState(RaffleState.Open);

    }


    function raffleState(RaffleState state) public onlyOwner{
        currentState=state;
    }
    
    function requestRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract balance");
        requestId = requestRandomness(keyHash, fee);
        lastRequestId = requestId;
        emit RandomnessRequestSent(requestId, fee);
        return requestId;
    }

    function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
        winnerTicketId = randomness % raffleTicketsSold;
        winner = ticketIdToOwner[winnerTicketId];
        prizeToSend = (raffleTicketsSold * raffleTicketprice) * prizePercentage / 100;
        payable(winner).transfer(prizeToSend);
    }

    function buyTickets(uint numTickets) public payable{
        raffleTimeLimitCheck();
        require(currentState == RaffleState.Open,"Tickets are not up for grabs right now.");
        require(numTickets>0,"The tickets to buy cant be zero.");
        require(msg.value==numTickets*raffleTicketprice,"Send the sufficient funds first");
        


        for(uint256 i=0; i<numTickets; i++) {
            ticketOwner[msg.sender].push(raffleTicketsSold);
            ticketIdToOwner[raffleTicketsSold] = msg.sender;
            raffleTicketsSold++;
        }   

        emit TicketSold(raffleTicketsSold, msg.sender);

    }

    function raffleTimeLimitCheck()public {
        require(currentState == RaffleState.Open, "Raffle is not open");
        if(block.timestamp>=timeToLive){
            raffleState(Drawing);
            requestRandomNumber();
        }
    }
}