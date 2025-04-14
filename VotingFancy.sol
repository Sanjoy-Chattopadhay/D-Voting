// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 <0.9.0;

/// @title Vote - A simple election voting system on the blockchain
/// @author 
/// @notice Allows voter and candidate registration, voting, and result declaration
contract Vote {

    // --- STRUCTS ---

    /// @notice Stores information related to a voter
    struct Voter {
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voterCandidateId; // ID of the candidate voted by this voter (0 means not voted)
        address voterAddress;
    }

    /// @notice Stores information related to a candidate
    struct Candidate {
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes; // Total votes received by this candidate
    }

    // --- STATE VARIABLES ---

    address electionCommission; // Address of the contract deployer (election commissioner)
    address public winner; // Address of the winning candidate

    uint nextVoterId = 1; // Auto-incrementing ID for new voters
    uint nextCandidateId = 1; // Auto-incrementing ID for new candidates

    uint startTime; // Timestamp for voting start
    uint endTime;   // Timestamp for voting end

    bool stopVoting; // Flag to allow emergency voting halt

    mapping(uint => Voter) voterDetails; // Stores voter data against their IDs
    mapping(uint => Candidate) candidateDetails; // Stores candidate data against their IDs

    // --- MODIFIERS ---

    /// @dev Ensures that voting is active and not stopped
    modifier isVotingOver() {
        require(endTime > block.timestamp && stopVoting != true, "Voting is over.");
        _;
    }

    /// @dev Restricts function access to only the election commissioner
    modifier onlyCommisiioner() {
        require(msg.sender == electionCommission, "You are not in authority"); 
        _;
    }

    // --- CONSTRUCTOR ---

    /// @notice Sets the contract deployer as the election commissioner
    constructor() {
        electionCommission = msg.sender;
    }

    // --- INTERNAL HELPERS ---

    /// @notice Checks if a candidate has already registered
    /// @param _person Address of the candidate
    /// @return True if the candidate is not yet registered
    function candidateVerification(address _person) internal view returns(bool) {
        for(uint i = 1; i < nextCandidateId; i++) {
            if(candidateDetails[i].candidateAddress == _person) return false;
        }
        return true;
    }

    /// @notice Checks if a voter has already registered
    /// @param _person Address of the voter
    /// @return True if the voter has not registered yet
    function voterVerification(address _person) internal view returns(bool) {
        for(uint i = 1; i < nextVoterId; i++) {
            if(voterDetails[i].voterAddress == _person) return true;
        }
        return false;
    }

    // --- CANDIDATE FUNCTIONS ---

    /// @notice Registers a new candidate
    /// @param _name Name of the candidate
    /// @param _party Political party of the candidate
    /// @param _gender Gender of the candidate
    /// @param _age Age of the candidate (must be >= 18)
    function candidateResgister(string calldata _name, string calldata _party, 
                                string calldata _gender, uint _age) external {
        require(_age >= 18, "Age is under 18");
        require(candidateVerification(msg.sender), "You have already registered.");
        require(nextCandidateId < 3, "Candidate Registration Full"); // Allow only 2 candidates

        candidateDetails[nextCandidateId] = Candidate(
            _name, _party, _age, _gender, nextCandidateId, msg.sender, 0
        );
        nextCandidateId++;
    }

    /// @notice Returns the list of registered candidates
    /// @return An array of Candidate structs
    function candidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidateArr = new Candidate[](nextCandidateId - 1);
        for(uint i = 1; i < nextCandidateId; i++) {
            candidateArr[i - 1] = candidateDetails[i];
        }
        return candidateArr;
    }

    // --- VOTER FUNCTIONS ---

    /// @notice Registers a new voter
    /// @param _name Name of the voter
    /// @param _age Age of the voter (must be > 18)
    /// @param _gender Gender of the voter
    function voterRegister(string calldata _name, uint _age, string calldata _gender) public {
        require(_age > 18, "Age is under 18, can't be a voter!");
        require(voterVerification(msg.sender), "Voter Registered already.");

        voterDetails[nextVoterId] = Voter(
            _name, _age, nextVoterId, _gender, 0, msg.sender
        );
        nextVoterId++;
    }

    /// @notice Returns the list of registered voters
    /// @return An array of Voter structs
    function voterList() public view returns(Voter[] memory) {
        Voter[] memory voterArr = new Voter[](nextVoterId - 1);
        for(uint i = 1; i < nextVoterId; i++) {
            voterArr[i - 1] = voterDetails[i];
        }
        return voterArr;
    }

    // --- VOTING LOGIC ---

    /// @notice Sets the voting start time and duration
    /// @param _startTime UNIX timestamp for when voting begins
    /// @param duration Duration of voting in seconds
    function voteTime(uint _startTime, uint duration) external onlyCommisiioner {
        startTime = _startTime;
        endTime = startTime + duration;
    }

    /// @notice Returns the current voting status as a string message
    /// @return Status message indicating voting state
    function votingStatus() public view returns (string memory) {
        if(startTime == 0) {
            return "Voting time has not started yet.";
        } else if(endTime > block.timestamp && stopVoting != true) {
            return "Voting is in progress.";
        } else {
            return "Voting ended!";
        }
    }

    /// @notice Allows the commissioner to stop voting in case of emergency
    function emergency() public onlyCommisiioner {
        stopVoting = true;
    }

    /// @notice Allows a registered voter to vote for a candidate
    /// @param _voterid Voter's ID
    /// @param _candidateId Candidate's ID (must be 1 or 2)
    function vote(uint _voterid, uint _candidateId) external isVotingOver {
        require(voterDetails[_voterid].voterAddress == msg.sender, "You have not registered.");
        require(_candidateId > 0 && _candidateId < 3, "Not a valid candidate");
        require(startTime != 0, "Voting has not started");
        require(nextCandidateId == 3, "Candidates not fully registered");
        require(voterDetails[_voterid].voterCandidateId == 0, "Voter has already voted.");

        voterDetails[_voterid].voterCandidateId = _candidateId;
        candidateDetails[_candidateId].votes++;
    }

    /// @notice Declares the winner after voting is over
    function result() external onlyCommisiioner {
        uint max = 0;
        for(uint i = 1; i < nextCandidateId; i++) {
            if(candidateDetails[i].votes > max) {
                max = candidateDetails[i].votes;
                winner = candidateDetails[i].candidateAddress;
            }
        }
    }
}
