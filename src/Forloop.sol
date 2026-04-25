// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract ForLoop {
    // Re-defining the Account struct from your previous contract
    struct Account {
        string name;
        uint256 accountBalance;
        address accountAddress;
        bool isActive;
    }

    // Dynamic array of accounts
    Account[] public accounts;

    // Function to add multiple accounts using a for loop
    function addMultipleAccounts(string[] memory names, address[] memory addresses) public {
        require(names.length == addresses.length, "Length mismatch");

        for (uint256 i = 0; i < names.length; i++) {
            accounts.push(Account({name: names[i], accountBalance: 0, accountAddress: addresses[i], isActive: true}));
        }
    }

    // Helper function to get total accounts
    function getAccountsCount() public view returns (uint256) {
        return accounts.length;
    }
}
