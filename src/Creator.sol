// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Reclaim} from "./Reclaim/Reclaim.sol";
import {Claims} from "./Reclaim/Claims.sol";
import {Addresses} from "./Reclaim/Addresses.sol";

contract Creator is ERC721URIStorage, Ownable {
    address public reclaimAddress;
    address public constant ownerAddress = 0x9443CF20fc0C1578c12792D8E80cA92DD4CEcc24;

    event Minted(address indexed to, uint256 indexed tokenId, string uri);
    event Burned(address indexed to, uint256 indexed tokenId);

    constructor() ERC721("Creator Hub Proof", "CHP") Ownable(msg.sender) {
        reclaimAddress = Addresses.ETHEREUM_SEPOLIA;
    }

    function mintAccount(Reclaim.Proof memory proof, string memory tokenURI) public {
        Reclaim(reclaimAddress).verifyProof(proof);

        require(proof.signedClaim.claim.owner == ownerAddress, "Owner is not valid!");

        string memory videoId = Claims.extractFieldFromContext(proof.claimInfo.context, '"channelId":"');
        uint256 tokenId = uint256(keccak256(abi.encodePacked(videoId)));

        processAccount(tokenId, tokenURI);

        emit Minted(msg.sender, tokenId, tokenURI);
    }

    function checkExist(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function processAccount(uint256 tokenId, string memory tokenURI) public {
        if (checkExist(tokenId)) {
            require(_ownerOf(tokenId) == msg.sender, "Already minted by another address!");

            _burn(tokenId);
            emit Burned(msg.sender, tokenId);
        }
        mintNFT(tokenId, tokenURI);
    }

    function mintNFT(uint256 tokenId, string memory tokenURI) public {
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }
}
