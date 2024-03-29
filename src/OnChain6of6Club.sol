// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC721A, ERC721A} from "./erc721a/ERC721A.sol";
import {ERC721AQueryable} from "./erc721a/extensions/ERC721AQueryable.sol";
import {ERC721ABurnable} from "./erc721a/extensions/ERC721ABurnable.sol";
// import {ERC721AURI6of6Club} from "./erc721a/extensions/ERC721AURI6of6Club.sol"; // EVM Prevrandao
import {ERC721AURI6of6Club} from "./erc721a/extensions/ERC721AURI6of6ClubChainlink.sol"; // Chainlink VRF
import {OperatorFilterer} from "./OperatorFilterer.sol";
import {Ownable} from "./openzeppelin-contracts/access/Ownable.sol";
import {SafeMath} from "./openzeppelin-contracts/utils/math/SafeMath.sol";
import {IERC2981, ERC2981} from "./openzeppelin-contracts/token/common/ERC2981.sol";

/**
 * @title  OnChain6of6Club
 * @notice On-Chain 6of6 Club NFT
 */
contract OnChain6of6Club is
    ERC721AQueryable,
    ERC721ABurnable,
    ERC721AURI6of6Club,
    OperatorFilterer,
    // Ownable, // EVM Prevrandao
    ERC2981 
{ 
    using SafeMath for uint256;   
    
    event BatchMetadataUpdate(uint256 fromTokenId, uint256 toTokenId);

    bool public operatorFilteringEnabled;
    uint256 public tokenCount;
    uint256 public constant MAX_SUPPLY = 2 ** 16 - 1;
    uint256 public constant MAX_PER_MINT = 2 ** 6;

    constructor() ERC721A("6of6 Club", "SIX") {
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;

        // Set royalty receiver to the contract creator,
        // at 9.5% (default denominator is 10000).
        _setDefaultRoyalty(msg.sender, 950);
    }

    function mint(uint256 quantity) external { 
        require(
            tokenCount.add(quantity) <= MAX_SUPPLY,
            "You are minting too many"
        );
        require(
            quantity > 0 && quantity <= MAX_PER_MINT,
            "You are minting too many"
        );
        tokenCount += quantity;
        _mint(msg.sender, quantity);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(IERC721A, ERC721A, ERC721AURI6of6Club) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override(ERC721A, ERC721AURI6of6Club) {
        emit BatchMetadataUpdate(startTokenId, startTokenId + quantity);
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }


    function setApprovalForAll(address operator, bool approved)
        public
        override(IERC721A, ERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        payable
        override(IERC721A, ERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    /**
     * @dev Both safeTransferFrom functions in ERC721A call this function
     * so we don't need to override them.
     */
    function transferFrom(address from, address to, uint256 tokenId)
        public
        payable
        override(IERC721A, ERC721A)
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC721A, ERC721A, ERC2981)
        returns (bool)
    {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        // - IERC4906: 0x49064906
        return interfaceId == bytes4(0x49064906) || ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setOperatorFilteringEnabled(bool value) public onlyOwner {
        operatorFilteringEnabled = value;
    }

    function _operatorFilteringEnabled() internal view override returns (bool) {
        return operatorFilteringEnabled;
    }

    function _isPriorityOperator(address operator) internal pure override returns (bool) {
        // OpenSea Seaport Conduit:
        // https://etherscan.io/address/0x1E0049783F008A0085193E00003D00cd54003c71
        // https://goerli.etherscan.io/address/0x1E0049783F008A0085193E00003D00cd54003c71
        return operator == address(0x1E0049783F008A0085193E00003D00cd54003c71);
    }
}
