// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract bankKYC {

    address admin;

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

    //address[] banksAddress;

    mapping(string => customer) customerData;
    mapping(address => bank) bankData;
    mapping(string => KYC_request) kycRequestData;

    constructor() {
        admin = msg.sender;
    }

    modifier isAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier customerExists(string memory _userName) {
        require(customerData[_userName].bank == address(0), "Customer exists in the bank already.");
        _;
    }

    modifier kycExists(string memory _userName, address _ethAddress) {
        require(kycRequestData[_userName].bankAddress == address(0), "KYC request exists already.");
        _;
    }

    //to add a new bank, by the admin only
    function addBank(
        string memory _bankName,
        address _ethAddress,
        string memory _regNumber
    ) public isAdmin {
        require(bankData[_ethAddress].ethAddress == address(0), "Bank exists and cannot be added again.");
        bankData[_ethAddress] = bank(_bankName, _ethAddress, 0, 0, true, _regNumber);
    }

    //to remove an existing bank, by the admin only
    function removeBank (
        address _ethAddress
    ) public isAdmin {
        require(bankData[_ethAddress].ethAddress != address(0), "Bank does not exist to remove.");
        delete bankData[_ethAddress];
    }

    //to modify an existing bank, by the admin only
    function modifyBank (
        address _ethAddress,
        bool _isAllowedToVote
    ) public isAdmin {
        require(bankData[_ethAddress].ethAddress != address(0), "Bank does not exist to modify.");
        //bankData[_ethAddress].isAllowedToVote = !(bankData[_ethAddress].isAllowedToVote);
        bankData[_ethAddress].isAllowedToVote = _isAllowedToVote;
    }

    //view bank information
    function viewBank (
        address _ethAddress
    ) public view returns(string memory, address, uint256, uint256, bool, string memory) {
        require(bankData[_ethAddress].ethAddress != address(0), "Bank does not exist to view.");
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
        string memory _data,
        address _ethAddress
    ) public customerExists(_userName) {
        customerData[_userName] = customer(_userName, _data, false, 0, 0, _ethAddress);
        addKYCRequest(_userName, _ethAddress, _data);
    }

    //to add a new KYC request for newly added customer & approve KYC status
    function addKYCRequest (
        string memory _kycUserName,
        address _kycEthAddress,
        string memory _kycData
    ) private customerExists(_kycUserName) kycExists(_kycUserName, _kycEthAddress) {
        kycRequestData[_kycUserName] = KYC_request(_kycUserName, _kycEthAddress, _kycData);
        customerData[_kycUserName].kycStatus = true;
        bankData[_kycEthAddress].KYC_count++;
    }

    //to remove an existing KYC request & disapprove KYC status
    //this function assumes a unique customer name.
    //yet to evaluate how this can be updated to check customer name and bank address combination
    function removeKYCRequest (
        string memory _kycUserName,
        address _kycEthAddress
    ) public customerExists(_kycUserName) kycExists(_kycUserName, _kycEthAddress) {
        delete kycRequestData[_kycUserName];
        customerData[_kycUserName].kycStatus = false;
        bankData[_kycEthAddress].KYC_count--;
    }

    //view customer information
    //this function assumes a unique customer name.
    //yet to evaluate how this can be updated to check customer name and bank address combination
    function viewCustomer (
        string memory _customerName
    ) public customerExists(_customerName) view returns (string memory, string memory, bool, uint256, uint256, address) {
        return (
            customerData[_customerName].userName,
            customerData[_customerName].data,
            customerData[_customerName].kycStatus,
            customerData[_customerName].downVotes,
            customerData[_customerName].upVotes,
            customerData[_customerName].bank
        );
    }

}