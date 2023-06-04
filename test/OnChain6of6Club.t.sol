// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/OnChain6of6Club.sol";
import "../src/erc721a/IERC721A.sol";

contract OnChain6of6ClubTest is Test {
    OnChain6of6Club public nft;
    address[] markets;

    function setUp() public {
        nft = new OnChain6of6Club();
        nft.mint(22);

        markets.push(address(this));
    }

    function testMint() public {
        nft.mint(22);
        assertEq(nft.totalSupply(), 44);
    }

    function testOwner() public {
        assertEq(nft.ownerOf(11), address(this));
        vm.expectRevert(abi.encodeWithSelector(IERC721A.OwnerQueryForNonexistentToken.selector));
        assertEq(nft.ownerOf(44), address(0));
    }

    function testSale() public {
        nft.transferFrom(address(this), address(this), 11);
        assertEq(nft.ownerOf(11), address(this));

        nft.addMarket(markets);

        vm.prevrandao(bytes32(uint256(5)));
        nft.transferFrom(address(this), address(this), 11);
        assertEq(nft.ownerOf(11), address(this));

        vm.prevrandao(bytes32(uint256(5)));
        nft.transferFrom(address(this), address(this), 11);
        assertEq(nft.ownerOf(11), address(this));

        vm.prevrandao(bytes32(uint256(5)));
        nft.transferFrom(address(this), address(this), 11);
        assertEq(nft.ownerOf(11), address(this));

        vm.prevrandao(bytes32(uint256(5)));
        nft.transferFrom(address(this), address(this), 11);
        assertEq(nft.ownerOf(11), address(this));

        vm.prevrandao(bytes32(uint256(5)));
        nft.transferFrom(address(this), address(this), 11);
        assertEq(nft.ownerOf(11), address(this));

        vm.prevrandao(bytes32(uint256(6)));
        nft.transferFrom(address(this), address(this), 11);
        assertEq(nft.ownerOf(11), address(this));

        console.log(nft.tokenURI(11));
    }
}
