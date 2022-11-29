// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AutoWithdraw is ERC721, AccessControl {
    using Counters for Counters.Counter;
    using Strings for uint256;

    event Mint(uint256 tokenId);
    event NewURI(string oldURI, string newURI);

    Counters.Counter internal nextId;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public price = 0.001 ether;
    address payable financeWallet;
    string public baseUri = "https://bafkreic6xug4ia6n2ogb5b5vfmjmrvjuhypii6cek4uwaf7wi4mgyupse4.ipfs.nftstorage.link";

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant FINANCE_ROLE = keccak256("FINANCE_ROLE");

    constructor() payable ERC721("Example Auto Withdrawl", "AUTO") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(FINANCE_ROLE, msg.sender);

        // should definitely set to a different address after deployment (or modify to pass in as argument)
        financeWallet = payable(msg.sender);
    }
        
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // MODIFIERS

    modifier isCorrectPayment(uint256 _quantity) {
        require(msg.value == (price * _quantity), "Incorrect Payment Sent");
        _;
    }

    modifier isAvailable(uint256 _quantity) {
        require(nextId.current() + _quantity <= MAX_SUPPLY, "Not enough tokens left for quantity");
        _;
    }

    // PUBLIC

    function mint(address _to, uint256 _quantity) 
        external  
        payable
        isCorrectPayment(_quantity)
        isAvailable(_quantity) 
    {
        mintInternal(_to, _quantity);
    }


    // INTERNAL

    function mintInternal(address _to, uint256 _quantity) internal {
        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = nextId.current();
            nextId.increment();

            _safeMint(_to, tokenId);

            emit Mint(tokenId);
        }

        // automatically withdraw all contract funds to `financeWallet`
        financeWallet.transfer(address(this).balance);
    }   

    // ADMIN

    function setPrice(uint256 _newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        price = _newPrice;
    }

    function setUri(string calldata _newUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit NewURI(baseUri, _newUri);
        baseUri = _newUri;
    }

    function setFinanceWallet(address payable _wallet) external onlyRole(FINANCE_ROLE) {
        financeWallet = payable(_wallet);
    }

    function withdraw() public onlyRole(FINANCE_ROLE) {
        financeWallet.transfer(address(this).balance);
    }

    /**
     * The admin role can add additional wallets to the FINANCE_ROLE. 
     * It doesn't make a ton of sense in this sample because all funds are auto withdrawn upon minting.
     * But if that were not the case it might make sense to have more than one wallet that can call
     * the withdraw function. Once again, in this case it doesn't make sense because the withdraw 
     * simply transfers to the financeWallet. 
     */
    function grantFinanceRole(address _wallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(FINANCE_ROLE, _wallet);
    }

    // VIEW

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // same uri for all NFTs, logic looks wrong but is intended to use the _tokenId
        // argument to avoid compiler warnings about it not being used
        return
            bytes(baseUri).length > 0
                ? baseUri // this will always be the intended return
                : string(abi.encodePacked(baseUri, _tokenId.toString(), ".json")); 
    }
}