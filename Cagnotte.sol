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


    address contractOwner;

    struct Participant {
        address participantAddress;
        uint amount;
    }
    
    mapping(address => Participant) participants;

    struct Cagnotte {
        bool exist;
        address cagnotteOwner;
        string name;
        uint balance;
        uint nbrParticipants;
        uint goal;
        bool isClosed;
        Participant[] _Participants;
    }
    

    uint cagnotteId = 0;
    
    mapping(uint => Cagnotte) cagnottes;
    

    constructor() ERC721("Cagnotte NFT", "Cagnotte") {
        contractOwner = msg.sender;
        cagnotteId++;
    }

    // Fonction pour créer une cagnotte
    function mintCagnotte(string memory _name, uint _goal) external {
        require(_goal > 0, 'The goal can\'t be negative');
        cagnottes[cagnotteId].exist = true;
        cagnottes[cagnotteId].cagnotteOwner = msg.sender;
        cagnottes[cagnotteId].name = _name;
        cagnottes[cagnotteId].balance = 0;
        cagnottes[cagnotteId].nbrParticipants = 0;
        cagnottes[cagnotteId].goal = _goal;
        cagnottes[cagnotteId].isClosed = false;  
        _safeMint(msg.sender, cagnotteId);
    }

    // Fonction pour avoir les details d'une cagnotte
    function getDetails(uint _cagnotteId) public view returns(string memory, uint, uint, uint, bool, Participant[] memory) {
        return (cagnottes[_cagnotteId].name, cagnottes[_cagnotteId].balance, cagnottes[_cagnotteId].nbrParticipants, cagnottes[_cagnotteId].goal, cagnottes[_cagnotteId].isClosed, cagnottes[_cagnotteId]._Participants);
    }
    
    //Fonction Payable pour qu'un utilisateur fasse un don du montant qu'il souhaite à une cagnotte
    function payCagnotte(uint _cagnotteId) payable public {
        //On vérifie que la cagnotte existe
        //require(keccak256(abi.encodePacked(cagnottes[_cagnotteId].name)) == keccak256(abi.encodePacked(cagnottes[cagnotteId].name)), 'This cagnotte no exist');
        require(cagnottes[_cagnotteId].exist == true, "Cagnotte does not exist");
        //On vérifie que la cagnotte n'est pas terminé
        require(cagnottes[_cagnotteId].isClosed == false, 'La cagnotte est termine');
        //Le participants doit faire un don d'une valeur supérieur à 0.
        require(msg.value > 0, 'Le montant est insuffisant');
        cagnottes[_cagnotteId].balance += msg.value;
        // On ajoute le donateur aux participants
        //On ne stock pas plusieurs fois l'address d'un participant si il fait plusieurs fois des dons sur une même cagnotte
        //cagnottes[_cagnotteId].participants.push(msg.sender);

        Participant memory thisParticipant = Participant(msg.sender, msg.value);
        cagnottes[_cagnotteId]._Participants.push(thisParticipant);
    }

    //Pour burn un NFT
    function burn(uint _cagnotteId) public virtual override {
        _burn(_cagnotteId);
        cagnottes[_cagnotteId].exist = false;
    }

    //Pour retirer l'argent
    function withdraw(uint _cagnotteId) public payable {    
        (bool success, ) = payable(cagnottes[_cagnotteId].cagnotteOwner).call{value: address(this).balance}("Your not the owner of this cagnotte");
        require(success);
        cagnottes[_cagnotteId].balance = 0;
        cagnottes[cagnotteId].isClosed = true;
    }


    //Fonction pour changer le goal d'une cagnotte
    function setGoal(uint _cagnotteId, uint _newGoal) public {
        cagnottes[_cagnotteId].goal = _newGoal;
    }


    //Fonction pour voir le nom d'une cagnotte
    function getName(uint _cagnotteId) internal view returns(string memory) {
        return cagnottes[_cagnotteId].name;
    }


    //Fonction pour voir le montant 'goal' d'une cagnotte
    function getGoal(uint _cagnotteId) internal view returns(uint) {
        return cagnottes[_cagnotteId].goal;
    }

    //Fonction pour voir la balance d'une cagnotte
    function getBalance(uint _cagnotteId) internal view returns(uint) {
        return cagnottes[_cagnotteId].balance;
    }

    //Fonction pour voir si une cagnotte est fermé
    function isClosed(uint _cagnotteId) internal view returns(bool) {
        return cagnottes[_cagnotteId].isClosed;
    }


    //Verifier la longueur de l'array Allparticipant
    function getNbrParticipants(uint _cagnotteId) internal view returns(uint) {
        return cagnottes[_cagnotteId]._Participants.length;
    }

    //Fonction pour voir les participants d'une cagnotte
    function getParticipants(uint _cagnotteId) internal view returns(Participant[] memory) {
        return cagnottes[_cagnotteId]._Participants;
    }
}
