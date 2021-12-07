// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract bankKYC {

    address admin;
    uint256 banksCount = 0;

    struct customer {
        string userName;
        string data;
        bool kycStatus;
        uint256 downVotes;
        uint256 upVotes;
        address bank;
    }

    struct bank {
        string name;
        address ethAddress;
        uint256 complaintsReported;
        uint256 KYC_count;
        bool isAllowedToVote;
        string regNumber;
    }

    struct KYC_request {
        string customerName;
        address bankAddress;
        string customerData;
    }

    mapping(string => customer) customerData;
    mapping(address => bank) bankData;
    mapping(string => KYC_request) kycRequestData;

    constructor() {
        admin = msg.sender;
    }

    /*
        There are quite a few modifiers implemented in this contract.
        Please advise if this is acceptable per recommended Solidity coding standards, with respect to performance and/or gas consumption.
    */

    modifier isAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier bankDoesNotExist(address _ethAddress) {
        require(bankData[_ethAddress].ethAddress == address(0), "Bank exists already.");
        _;
    }

    modifier bankExist(address _ethAddress) {
        require(bankData[_ethAddress].ethAddress != address(0), "Bank does not exist.");
        _;
    }

    modifier isAllowedToVote(address _ethAddress) {
        require(bankData[_ethAddress].isAllowedToVote == true, "Bank is not allowed to vote.");
        _;
    }

    modifier customerNotExist(string memory _userName) {
        require(customerData[_userName].bank == address(0), "Customer exists already.");
        _;
    }

    modifier customerExist(string memory _userName) {
        require(customerData[_userName].bank != address(0), "Customer does not exist.");
        _;
    }

    modifier kycNotExists(string memory _userName) {
        require(kycRequestData[_userName].bankAddress == address(0), "KYC request exists already.");
        _;
    }

    /*
        Please advise how the below modifier can be modified to check the KYC request existance for a specific bank (msg.sender).
    */
    modifier kycExists(string memory _userName) {
        require(kycRequestData[_userName].bankAddress != address(0), "KYC request does not exist.");
        _;
    }

    modifier performDownVote(string memory _customerName) {
        require(customerData[_customerName].downVotes > 0, "Customer's KYC is already invalidated");
        _;
    }

    modifier bankVersusVotes(string memory _customerName) {
        require(customerData[_customerName].upVotes + customerData[_customerName].downVotes <= banksCount, "Customer's upvotes & downvotes together cannot exceed total number of banks");
        _;
    }

    modifier kycStatusTrue(string memory _customerName) {
        require(customerData[_customerName].kycStatus == true, "Customer KYC status is already invalidated.");
        _;
    }

    //to add a new bank, by the admin only
    function addBank(
        string memory _bankName,
        address _ethAddress,
        string memory _regNumber
    ) public isAdmin bankDoesNotExist(_ethAddress) {
        bankData[_ethAddress] = bank(_bankName, _ethAddress, 0, 0, true, _regNumber);
        banksCount++;
    }

    //to remove an existing bank, by the admin only
    function removeBank (
        address _ethAddress
    ) public isAdmin bankExist(_ethAddress) {
        delete bankData[_ethAddress];
        banksCount--;
    }

    //to modify an existing bank, by the admin only
    function modifyBank (
        address _ethAddress,
        bool _isAllowedToVote
    ) public isAdmin bankExist(_ethAddress) {
        bankData[_ethAddress].isAllowedToVote = _isAllowedToVote;
    }

    //view bank information
    function viewBank (
        address _ethAddress
    ) public bankExist(_ethAddress) view returns(string memory, address, uint256, uint256, bool, string memory) {
        return (
            bankData[_ethAddress].name, 
            bankData[_ethAddress].ethAddress, 
            bankData[_ethAddress].complaintsReported,
            bankData[_ethAddress].KYC_count,
            bankData[_ethAddress].isAllowedToVote,
            bankData[_ethAddress].regNumber
        );
    }

    //to add a new customer for a bank
    function addCustomer (
        string memory _userName,
        string memory _data
    ) public customerNotExist(_userName) {
        //customerData[_userName] = customer(_userName, keccak256(abi.encodePacked(_data)), false, 0, 0, msg.sender);
        customerData[_userName] = customer(_userName, _data, false, 0, 0, msg.sender);
    }

    //to add a new KYC request for newly added customer & approve KYC status
    function addKYCRequest (
        string memory _kycUserName,
        string memory _kycData
    ) public customerNotExist(_kycUserName) kycNotExists(_kycUserName) {
        //kycRequestData[_kycUserName] = KYC_request(_kycUserName, msg.sender, keccak256(abi.encodePacked(tempVar)));
        kycRequestData[_kycUserName] = KYC_request(_kycUserName, msg.sender, _kycData);
        /*
            it was not clear from requirement on when to set KYC status to true for a customer.
            so, assumed that the bank that initiated KYC request is also approving it always and hence set the KYC status to true.
            Please advise.
        */
        customerData[_kycUserName].kycStatus = true;
        //customerData[_kycUserName].upVotes++;
        bankData[msg.sender].KYC_count++;
    }

    //to remove an existing KYC request & disapprove KYC status
    //this function assumes a unique customer name.
    //yet to evaluate how this can be updated to check customer name and bank address combination
    function removeKYCRequest (
        string memory _kycUserName
    ) public customerExist(_kycUserName) kycExists(_kycUserName) {
        delete kycRequestData[_kycUserName];
        customerData[_kycUserName].kycStatus = false;
        customerData[_kycUserName].upVotes = 0;
        customerData[_kycUserName].downVotes = 0;
        bankData[msg.sender].KYC_count--;
    }

    //view customer information
    //this function assumes a unique customer name.
    //yet to evaluate how this can be updated to check customer name and bank address combination
    function viewCustomer (
        string memory _customerName
    ) public customerExist(_customerName) view returns (string memory, string memory, bool, uint256, uint256, address) {
        return (
            customerData[_customerName].userName,
            customerData[_customerName].data,
            customerData[_customerName].kycStatus,
            customerData[_customerName].downVotes,
            customerData[_customerName].upVotes,
            customerData[_customerName].bank
        );
    }

    //view bank information
    function viewBankDetails (
        address _ethAddress
    ) public bankExist(_ethAddress) view returns (string memory, address, uint256, uint256, bool, string memory) {
        return (
            bankData[_ethAddress].name,
            bankData[_ethAddress].ethAddress,
            bankData[_ethAddress].complaintsReported,
            bankData[_ethAddress].KYC_count,
            bankData[_ethAddress].isAllowedToVote,
            bankData[_ethAddress].regNumber
        );
    }

    //get bank complaints
    function getBankComplaints (
        address _ethAddress
    ) public bankExist(_ethAddress) view returns (uint256) {
        return bankData[_ethAddress].complaintsReported;
    }

    //report a bank
    /*
        The input parameter 'bank name' is recommended in the requirement, but is not used in the functionality.
        Please advise if this function / parameter is valid and is as expected.
    */
    function reportBank (
        address _ethAddress,
        string memory _bankName
    ) public bankExist(_ethAddress) {
        bankData[_ethAddress].complaintsReported++;
        if (bankData[_ethAddress].complaintsReported > banksCount/3) {
            bankData[_ethAddress].isAllowedToVote = false;
        }       
    }

    //modify customer data
    function modifyCustomer (
        string memory _customerName,
        string memory _data
    ) public customerExist(_customerName) {
        customerData[_customerName].data = _data;
        customerData[_customerName].kycStatus = false;
        customerData[_customerName].downVotes = 0;
        customerData[_customerName].upVotes = 0;
    }

    //upvote a customer's KYC
    function upVoteCustomerKYC (
        string memory _customerName
    ) public customerExist(_customerName) isAllowedToVote(msg.sender) kycStatusTrue(_customerName) bankVersusVotes(_customerName) {
        customerData[_customerName].upVotes++;
        updateKYCStatus(_customerName);       
    }

    //downvote a customer's KYC
    function downVoteCustomeKYC(
        string memory _customerName
    ) public customerExist(_customerName) isAllowedToVote(msg.sender) kycStatusTrue(_customerName) performDownVote(_customerName) bankVersusVotes(_customerName) {
        customerData[_customerName].downVotes++;
        updateKYCStatus(_customerName);
    } 

    function updateKYCStatus(
        string memory _customerName
    ) private {
        /*
            it was not clear from requirement,
                if the total number of banks should be considered or 
                if the total number of banks that are allowed to vote should be considered or
                if the total number of banks partifipated in voting should be considered
            so, the total number of banks is used here. Please advise.
        */
        if (customerData[_customerName].upVotes > customerData[_customerName].downVotes && customerData[_customerName].downVotes < (banksCount/3)) {
            customerData[_customerName].kycStatus = true;
        } else {
            customerData[_customerName].kycStatus = false;
        }
    }     

}