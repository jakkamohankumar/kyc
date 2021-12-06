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

    function addBank(
        string memory _bankName,
        address _ethAddress,
        string memory _regNumber
    ) public isAdmin {
        require(bankData[_ethAddress].ethAddress == address(0), "Bank exists and cannot be added again.");
        bankData[_ethAddress] = bank(_bankName, _ethAddress, 0, 0, true, _regNumber);
        //banksAddress.push(_ethAddress);
    }

    function removeBank (
        //string memory _bankName,
        address _ethAddress
        //string memory _regNumber
    ) public isAdmin {
        require(bankData[_ethAddress].ethAddress != address(0), "Bank does not exist to remove.");
        delete bankData[_ethAddress];
    }

    function modifyBank (
        address _ethAddress
    ) public isAdmin {
        require(bankData[_ethAddress].ethAddress != address(0), "Bank does not exist to modify.");
        bankData[_ethAddress].isAllowedToVote = !(bankData[_ethAddress].isAllowedToVote);
    }

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

}
