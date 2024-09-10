// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

interface IToken is IERC20, IERC20Permit {}

contract NFTMarketPlus {
    
    struct Order {
        address owner;
        uint256 price;
    }

    // NFTAddress => tokenId => Order
    mapping(address => mapping(uint256 => Order)) public nftList;

    IToken token;

    constructor(address _token) {
        token = IToken(_token);
    }

    function _list(address _seller, address _nftAddr, uint256 _tokenId, uint256 _price) internal {
        IERC721 _nft = IERC721(_nftAddr);
        require(
          _nft.getApproved(_tokenId) == address(this) || _nft.isApprovedForAll(_seller, address(this)), 
          "Not approved"
        );
        require(_price > 0, "The price must be greater than 0");
        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = _seller;
        _order.price = _price;
        _nft.transferFrom(_seller, address(this), _tokenId);
        emit List(_seller, _nftAddr, _tokenId, _price);
    }

    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        _list(msg.sender, _nftAddr, _tokenId, _price);
    }

    function cancel(address _nftAddr, uint256 _tokenId) public {
        Order memory _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not the owner");
        IERC721 _nft = IERC721(_nftAddr);
        _nft.transferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];
        emit Cancel(msg.sender, _nftAddr, _tokenId);
    }

    function update(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not the owner");
        require(_price > 0, "The price must be greater than 0");
        _order.price = _price;
        emit Update(msg.sender, _nftAddr, _tokenId, _price);
    }

    function buy(address _nftAddr, uint256 _tokenId) public {
        Order memory _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0, "The price must be greater than 0");
        require(token.allowance(msg.sender, address(this)) >= _order.price, "No enough allowance");
        require(token.balanceOf(msg.sender) >= _order.price, "No enough balance");
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "NFT is not on sell");
        delete nftList[_nftAddr][_tokenId];
        _nft.transferFrom(address(this), msg.sender, _tokenId);
        token.transferFrom(msg.sender, _order.owner, _order.price);
        emit Buy(msg.sender, _nftAddr, _tokenId, _order.price);
    }

    function permitBuy(address _nftAddr, uint256 _tokenId, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        token.permit(
          msg.sender, 
          address(this), 
          nftList[_nftAddr][_tokenId].price,
          deadline,
          v, r, s
        );
        buy(_nftAddr, _tokenId);
    }

    // List an NFT
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    // Cancel the listing
    event Cancel(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId
    );
    // Update the listing
    event Update(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    // Buy an NFT
    event Buy(
        address indexed buyer,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
}