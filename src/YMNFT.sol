// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract YMNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, EIP712("YMNFT", "1") {
    uint256 private _nextTokenId;

    // EIP712 typehash for the contract
    bytes32 private constant LIST_TYPEHASH = keccak256("Permit(address to,uint256 tokenId,uint256 deadline)");

    constructor(address initialOwner)
        ERC721("YMNFT", "YMNFT")
        Ownable(initialOwner)
    {}

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function permit(
        address _to,
        uint256 _tokenId,
        uint256 _deadline, 
        bytes calldata _signature
    ) public returns (address) {
        // verify the signature
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            LIST_TYPEHASH,
            _to,
            _tokenId,
            _deadline
        )));
        address signer = ECDSA.recover(digest, _signature);
        require(ownerOf(_tokenId) == signer, "Signer is not the owner of the NFT");
        _approve(_to, _tokenId, address(0));
        return signer;
    }
}
