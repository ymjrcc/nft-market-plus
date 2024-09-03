// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/NFTMarketPlus.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockNFT is ERC721 {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _tokenIdCounter++;
        return tokenId;
    }
}

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
}

contract NFTMarketPlusTest is Test {
    NFTMarketPlus public marketplace;
    MockNFT public nft;
    MockERC20 public token;

    address public seller = address(1);
    address public buyer = address(2);

    function setUp() public {
        token = new MockERC20();
        marketplace = new NFTMarketPlus(address(token));
        nft = new MockNFT();

        // Mint NFT to seller
        vm.prank(seller);
        uint256 tokenId = nft.mint(seller);
        assertEq(tokenId, 0);

        // Give buyer some tokens
        token.transfer(buyer, 1000 * 10**18);
    }

    function testList() public {
        uint256 tokenId = 0;
        uint256 price = 100 * 10**18;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.list(address(nft), tokenId, price);
        vm.stopPrank();

        (address owner, uint256 listedPrice) = marketplace.nftList(address(nft), tokenId);
        assertEq(owner, seller);
        assertEq(listedPrice, price);
        assertEq(nft.ownerOf(tokenId), address(marketplace));
    }

    function testCancel() public {
        uint256 tokenId = 0;
        uint256 price = 100 * 10**18;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.list(address(nft), tokenId, price);
        marketplace.cancel(address(nft), tokenId);
        vm.stopPrank();

        (address owner, uint256 listedPrice) = marketplace.nftList(address(nft), tokenId);
        assertEq(owner, address(0));
        assertEq(listedPrice, 0);
        assertEq(nft.ownerOf(tokenId), seller);
    }

    function testUpdate() public {
        uint256 tokenId = 0;
        uint256 initialPrice = 100 * 10**18;
        uint256 newPrice = 150 * 10**18;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.list(address(nft), tokenId, initialPrice);
        marketplace.update(address(nft), tokenId, newPrice);
        vm.stopPrank();

        (address owner, uint256 listedPrice) = marketplace.nftList(address(nft), tokenId);
        assertEq(owner, seller);
        assertEq(listedPrice, newPrice);
    }

    function testBuy() public {
        uint256 tokenId = 0;
        uint256 price = 100 * 10**18;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.list(address(nft), tokenId, price);
        vm.stopPrank();

        vm.startPrank(buyer);
        token.approve(address(marketplace), price);
        marketplace.buy(address(nft), tokenId);
        vm.stopPrank();

        assertEq(nft.ownerOf(tokenId), buyer);
        assertEq(token.balanceOf(seller), price);
        (address owner, uint256 listedPrice) = marketplace.nftList(address(nft), tokenId);
        assertEq(owner, address(0));
        assertEq(listedPrice, 0);
    }

    function testFailListNotApproved() public {
        uint256 tokenId = 0;
        uint256 price = 100 * 10**18;

        vm.prank(seller);
        marketplace.list(address(nft), tokenId, price);
    }

    function testFailCancelNotOwner() public {
        uint256 tokenId = 0;
        uint256 price = 100 * 10**18;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.list(address(nft), tokenId, price);
        vm.stopPrank();

        vm.prank(buyer);
        marketplace.cancel(address(nft), tokenId);
    }

    function testFailUpdateNotOwner() public {
        uint256 tokenId = 0;
        uint256 price = 100 * 10**18;
        uint256 newPrice = 150 * 10**18;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.list(address(nft), tokenId, price);
        vm.stopPrank();

        vm.prank(buyer);
        marketplace.update(address(nft), tokenId, newPrice);
    }

    function testFailBuyInsufficientBalance() public {
        uint256 tokenId = 0;
        uint256 price = 1000000 * 10**18; // More than buyer's balance

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.list(address(nft), tokenId, price);
        vm.stopPrank();

        vm.startPrank(buyer);
        token.approve(address(marketplace), price);
        marketplace.buy(address(nft), tokenId);
        vm.stopPrank();
    }
}