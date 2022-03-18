pragma solidity ^0.8.7;

contract TestCagnotte {

    address contractOwner;

    struct Participant {
        address addressParticipant;
        uint nbrTotalDonsDuDonnateur;
        uint balanceDonnations;
    }

    mapping(address => Participant) participants;

    struct Cagnotte {
        address owner;
        string name;
        uint balance;
        uint nbrDeDons;
        uint nbrParticipants;
        //Le but de la cagnotte
        uint goal;
        //Verifier si le but de la cagnotte est atteint ou non
        bool goalAchieved;
        address[] allParticipants;
    }

    uint cagnotteId = 0;
    
    // Chaque cagnotte est représenté par un id
    // Donc chaque cagnotte est unique et chaque cagnotte a un id unique
    mapping(uint => Cagnotte) cagnottes;
    

    constructor() {
        contractOwner = msg.sender;
    }

    // Fonction pour créer une cagnotte
    function addCagnotte(string memory _name, uint _goal) public {
        // La personne ajoutant une cagnotte est le propriétaire de celle ci
        cagnottes[cagnotteId].owner = msg.sender;
        // On vérifie si la cagnotte existe déjà 
        require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked(cagnottes[cagnotteId].name)), 'Cette cagnotte existe deja');
        // Si la cagnotte n'existe pas alors on l'ajoute
        cagnotteId ++;
        cagnottes[cagnotteId].name = _name;
        cagnottes[cagnotteId].owner = msg.sender;
        cagnottes[cagnotteId].balance = 0;
        cagnottes[cagnotteId].nbrParticipants = 0;
        cagnottes[cagnotteId].nbrDeDons = 0;
        require(_goal > 0, 'The goal can\'t be negative');
        cagnottes[cagnotteId].goal = _goal;
        cagnottes[cagnotteId].goalAchieved = false;
    }

    //Fonction pour voir le nom d'une cagnotte
    function getName(uint _cagnotteId) public view returns(string memory) {
        return cagnottes[_cagnotteId].name;
    }

    //Fonction pour voir l'owner d'une cagnotte
    function getOwner(uint _cagnotteId) public view returns(address) {
        return cagnottes[_cagnotteId].owner;
    }

    //Fonction pour voir si le goal d'une cagnotte est atteint
    function getStatutGoal(uint _cagnotteId) public view returns(bool) {
        return cagnottes[_cagnotteId].goalAchieved;
    }

    //Fonction pour changer le goal d'une cagnotte
    function setGoal(uint _cagnotteId, uint _newGoal) public {
        require(msg.sender == cagnottes[_cagnotteId].owner, "Your not the owner of this cagnotte");
        cagnottes[_cagnotteId].goal = _newGoal;
    }

    //Fonction pour voir le montant 'goal' d'une cagnotte
    function getGoal(uint _cagnotteId) public view returns(uint) {
        return cagnottes[_cagnotteId].goal;
    }

    //Fonction pour voir la balance d'une cagnotte
    function getBalance(uint _cagnotteId) public view returns(uint) {
        return cagnottes[_cagnotteId].balance;
    }

    //Fonction pour voir le nombre de dons d'une cagnotte
    function getNbrDeDons(uint _cagnotteId) public view returns(uint) {
        return cagnottes[_cagnotteId].nbrDeDons;
    }

    //Fonction Payable pour qu'un utilisateur fasse un don du montant qu'il souhaite à une cagnotte
    function payCagnotte(uint _cagnotteId) payable public {
        //Le participants doit faire un don d'une valeur supérieur à 0.
        require(msg.value > 0, 'Le montant est insuffisant');
        cagnottes[_cagnotteId].balance += msg.value;
        cagnottes[_cagnotteId].nbrDeDons++;
        participants[msg.sender].addressParticipant = msg.sender;
        participants[msg.sender].nbrTotalDonsDuDonnateur++;
        participants[msg.sender].balanceDonnations = participants[msg.sender].balanceDonnations + msg.value;
        // On ajoute le donateur aux participants
        //On ne stock pas plusieurs fois l'address d'un participant si il fait plusieurs fois des dons sur une même cagnotte
        if (cagnottes[_cagnotteId].allParticipants.length == 0) {
            cagnottes[_cagnotteId].allParticipants.push(msg.sender);
        } else {
            for(uint i = 0 ; i < cagnottes[_cagnotteId].allParticipants.length ; i++) {
                // On parcourt tout le tableau allParticipants
                // Et pour chaque valeur que l'on va rencontrer on check si elle correspond à l'adress que l'on souhaite ajouter
                if (cagnottes[_cagnotteId].allParticipants[i] != msg.sender) {
                   cagnottes[_cagnotteId].allParticipants.push(msg.sender);
                } else {
                    cagnottes[_cagnotteId].allParticipants;
                }
            }
        }
        //On verifie si le but de la cagnotte est atteint
        if (cagnottes[_cagnotteId].balance >= cagnottes[_cagnotteId].goal) {
            cagnottes[_cagnotteId].goalAchieved = true;
        } 
        else {
            cagnottes[_cagnotteId].goalAchieved = false;
        }
    }

    //Verifier la longueur de l'array Allparticipant
    function getLenght(uint _cagnotteId) public view returns(uint) {
        return cagnottes[_cagnotteId].allParticipants.length;
    }

    //Fonction pour voir les participants d'une cagnotte
    function getParticipants(uint _cagnotteId) public view returns(address[] memory) {
        return cagnottes[_cagnotteId].allParticipants;
    }

    //Fonction pour connaitre le nombre de donnation d'un participant
   function getNbrDonnation(address _addressParticipant) public view returns(uint) {
        return participants[_addressParticipant].nbrTotalDonsDuDonnateur;
   }

   //Fonction pour connaitre le montant de donnation d'un participant
   function getBalanceDonnations(address _addressParticipant) public view returns(uint) {
       return participants[_addressParticipant].balanceDonnations;
   }

    //Pour retirer l'argent
    function withdraw(uint _cagnotteId) public payable {    
        require(msg.sender == cagnottes[_cagnotteId].owner);
        (bool success, ) = payable(cagnottes[_cagnotteId].owner).call{value: address(this).balance}("Your not the owner of this cagnotte");
        require(success);
    }
}
