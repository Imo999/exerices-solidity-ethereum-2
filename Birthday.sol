// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract Birthday {
    //Appel du contrat OpenZeppelin
    using Address for address payable;

    /*
    // ############################### Variables ################################
    */
    mapping(address => bool) private _participants;
    uint256 private _jackpot;
    address private _birthdayAddress;
    uint256 private _birthdayDate;
    uint256 private _commonExpense;

    /*
    // ############################### Event ################################
    */
    event Contribution(
        address indexed birthdayAddress_,
        address participants_,
        uint256
    );

    /*
    // ############################### Constructor ################################
    */

    constructor(
        address birthdayAddress_,
        uint256 day,
        uint256 month,
        uint256 year
    ) {
        _birthdayDate = _atomicClock(day, month, year);
        _birthdayAddress = birthdayAddress_;
    }

    /*
    // ############################### Modifier ################################
    */

    //Prévision : Seulement le propriétaire des futur cagnottes
    modifier onlyBirthdayAddress() {
        require(
            msg.sender == _birthdayAddress,
            "Birthday: You don't the Owner of this Jackpot."
        );
        _;
    }
    //Prévision : Débloquage des futur cagnottes
    modifier unlockJackpot() {
        require(
            block.timestamp >= _birthdayDate,
            "Birthday: The jackpot will be unlocked on your birthday"
        );
        _;
    }
    //Prévision : Cagnotte vide des futur cagnottes
    modifier emptyJackpot() {
        require(
            block.timestamp >= _birthdayDate,
            "Birthday: Money pot empty - Sorry"
        );
        _;
    }

    //
    receive() external payable {
        _deposit(msg.value);
    }

    /*
    // ############################### Fonction ################################
    */

    //Fonction
    function offer() external payable {
        _deposit(msg.value);
    }

    // Fonction pour récupérer le jackpot
    function getJackpot()
        public
        onlyBirthdayAddress
        unlockJackpot
        emptyJackpot
    {
        _jackpot = 0;
        payable(msg.sender).sendValue(address(this).balance);
    }

    // Fonction dépot
    function _deposit(uint256 amount) private {
        if (_participants[msg.sender] == false) {
            _commonExpense++;
            _participants[msg.sender] == true;
        }
        _jackpot += amount;
        emit Contribution(_birthdayAddress, msg.sender, amount);
    }

    // Fonction pour calculer le temps qu'il reste
    function _atomicClock(
        uint256 day,
        uint256 month,
        uint256 year
    ) private pure returns (uint256) {
        require(
            day <= 31 && month <= 12 && year > 1850,
            "Please respect the date entry"
        );
        return ((86400 *
            (day - 1) +
            (2629743 * (month - 1) + (year - 1850) * 31556926)) + 36000);
    }

    /*
    // ############################### Affichage ################################
    */

    // Show Birthday address
    function ShowBirthdayAddress() public view returns (address) {
        return _birthdayAddress;
    }

    // Show cagnotte (Jackpot)
    function ShowJackpot() public view returns (uint256) {
        return _jackpot;
    }

    // Show Nombre de participants_
    function ShowParticipants() public view returns (uint256) {
        return _commonExpense;
    }
}
