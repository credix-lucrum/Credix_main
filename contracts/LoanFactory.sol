// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Credix - Peer-to-Peer Microlending Core
 * @notice Main contract for loan creation and management
 * @dev Key Features:
 * - USSD-accessible loan requests
 * - SIM lock collateral system
 * - Celo cUSD stablecoin integration
 */
contract LoanFactory {
    // Loan status tracker
    enum LoanStatus { PENDING, ACTIVE, REPAID, DEFAULTED }
    
    // Loan data structure
    struct Loan {
        address borrower;
        uint256 amount; // in cUSD (1e18 decimals)
        uint256 interestRate; // APR (5% = 500)
        uint256 dueDate;
        LoanStatus status;
        string phoneNumber; // For SIM collateral
    }
    
    Loan[] public loans;
    
    // Events for frontend tracking
    event LoanCreated(uint256 indexed loanId, address indexed borrower);
    event LoanFunded(uint256 indexed loanId, address indexed lender);
    
    /**
     * @notice Create a new microloan request
     * @param amount Loan amount in cUSD
     * @param termDays Loan duration in days (30 = 1 month)
     * @param phone Borrower's phone for collateral (e.g. "+254712345678")
     */
    function createLoan(
        uint256 amount,
        uint256 termDays,
        string calldata phone
    ) external returns (uint256 loanId) {
        require(amount >= 5 ether, "Minimum loan: 5 cUSD");
        require(termDays <= 180, "Max term: 6 months");
        
        loans.push(Loan({
            borrower: msg.sender,
            amount: amount,
            interestRate: getInterestRate(msg.sender, amount),
            dueDate: block.timestamp + (termDays * 1 days),
            status: LoanStatus.PENDING,
            phoneNumber: phone
        }));
        
        emit LoanCreated(loans.length - 1, msg.sender);
        return loans.length - 1;
    }
    
    /**
     * @notice Internal function to calculate dynamic interest rates
     * @dev Stub for credit scoring integration
     */
    function getInterestRate(address borrower, uint256 amount) 
        internal 
        pure 
        returns (uint256) 
    {
        // Base 5% + 1% per $100 (simplified for initial commit)
        return 500 + (amount / 100 ether) * 100;
    }
}
