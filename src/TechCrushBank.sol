// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract TechCrushBank {
    error FEEIsLow(uint256 _userFee);

    address public immutable bankOwner;
    uint256 public constant FEE = 1e16;
    uint256 public totalFee;

    struct Account {
        string name;
        uint256 accountBalance;
        address accountAddress;
        bool accountStatus;
    }

    uint256 public totalAmountInBank;

    mapping(address => Account) public accounts;

    constructor(address _owner) {
        bankOwner = _owner;
    }

    //  FIXED OWNER CHECK
    modifier onlyBankOwner() {
        require(msg.sender == bankOwner, "Not bank owner");
        _;
    }

    // CREATE ACCOUNT
    function createAccount(string memory _name) public payable onlyBankOwner {
        if (msg.value < FEE) {
            revert FEEIsLow(msg.value);
        }

        totalFee += msg.value;

        accounts[msg.sender] = Account({
            name: _name,
            accountBalance: 0,
            accountAddress: msg.sender,
            accountStatus: true
        });
    }

    // DEPOSIT
    function userDeposit() public payable {
        require(msg.value > 0, "must send > 0");
        require(accounts[msg.sender].accountStatus, "No account");

        accounts[msg.sender].accountBalance += msg.value;
        totalAmountInBank += msg.value;
    }

    // WITHDRAW
    function userWithdraw(uint256 amount) public {
        require(accounts[msg.sender].accountStatus, "No account");
        require(accounts[msg.sender].accountBalance >= amount, "Insufficient");

        accounts[msg.sender].accountBalance -= amount;
        totalAmountInBank -= amount;

        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "Withdraw failed");
    }

    // TRANSFER
    function transferToUsers(address user, uint256 amount) public {
        require(accounts[msg.sender].accountStatus, "No sender");
        require(accounts[user].accountStatus, "No receiver");

        require(accounts[msg.sender].accountBalance >= amount, "Insufficient");

        accounts[msg.sender].accountBalance -= amount;
        accounts[user].accountBalance += amount;
    }

    // CLOSE ACCOUNT
    function closeAccount() public {
        uint256 amount = accounts[msg.sender].accountBalance;

        userWithdraw(amount);

        delete accounts[msg.sender];
    }
}
