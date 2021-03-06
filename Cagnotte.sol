pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestCagnotte is ERC721Enumerable, ERC721Burnable, Ownable {

    // Résolution d'un conflit
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    struct Participant {
        address participantAddress;
        uint amount;
    }

    //Pour increment l'id des NFTs(cagnotte)
    using Counters for Counters.Counter;

    //Id du prochain NFT à minté(cagnotte)
    Counters.Counter private _nftIdCounter;

    struct Cagnotte {
        string name;
        uint balance;
        uint nbrParticipants;
        uint goal;
        bool isClosed;
        Participant[] _Participants;
    }

    mapping(uint => Cagnotte) cagnottes;

    constructor() ERC721("Cagnotte NFT", "Cagnotte") {
        transferOwnership(msg.sender);
        _nftIdCounter.increment();
    }

    // Fonction pour créer une cagnotte
    function mintCagnotte(string memory _name, uint _goal) external {
        require(_goal > 0, 'The goal can\'t be negative');
        cagnottes[_nftIdCounter.current()].name = _name;
        cagnottes[_nftIdCounter.current()].balance = 0;
        cagnottes[_nftIdCounter.current()].nbrParticipants = 0;
        cagnottes[_nftIdCounter.current()].goal = _goal;
        cagnottes[_nftIdCounter.current()].isClosed = false;
        _safeMint(msg.sender, _nftIdCounter.current());
        _nftIdCounter.increment();
    }

    //Pour que seul le propriétaire d'une cagnotte puisse faire certaines actions
    modifier isOwner(uint _nftId) {
        require(msg.sender == ownerOf(_nftId), "Not the owner");
        _;
    }

    // Fonction pour avoir les details d'une cagnotte
    function getDetails(uint _nftId) public view returns(string memory, uint, uint, uint, bool, uint, Participant[] memory) {
        return (cagnottes[_nftId].name, cagnottes[_nftId].balance, cagnottes[_nftId].nbrParticipants, cagnottes[_nftId].goal, cagnottes[_nftId].isClosed, cagnottes[_nftId]._Participants.length, cagnottes[_nftId]._Participants);
    }

    //Fonction Payable pour qu'un utilisateur fasse un don du montant qu'il souhaite à une cagnotte
    function payCagnotte(uint _nftId) payable public {
        //On vérifie que la cagnotte existe
        require(_exists(_nftId) == true);
        //On vérifie que la cagnotte n'est pas terminé
        require(cagnottes[_nftId].isClosed == false, 'La cagnotte est termine');
        //Le participants doit faire un don d'une valeur supérieur à 0.
        require(msg.value > 0, 'Le montant est insuffisant');
        cagnottes[_nftId].balance += msg.value;
        // On ajoute le donateur aux participants
        Participant memory thisParticipant = Participant(msg.sender, msg.value);
        cagnottes[_nftId]._Participants.push(thisParticipant);
    }

    //Pour retirer l'argent
    function withdraw(uint _nftId) public payable {
        (bool success, ) = payable(ownerOf(_nftId)).call{value: cagnottes[_nftId].balance}("Your not the owner of this cagnotte");
        require(success);
        cagnottes[_nftId].balance = 0;
        cagnottes[_nftId].isClosed = true;
        uint tokenId = _nftId;
        burn(tokenId);
    }

    //Fonction pour changer le goal d'une cagnotte
    function setGoal(uint _nftId, uint _newGoal) public isOwner(_nftId) {
        cagnottes[_nftId].goal = _newGoal;
    }
}
