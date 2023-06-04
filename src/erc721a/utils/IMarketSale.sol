// SPDX-License-Identifier: MIT
// IMarketSale Contract v0.0.1
// Creator: RockArt 🪨 AI

pragma solidity ^0.8.13;

/**
 * @dev Interface of MarketSale.
 */
interface IMarketSale {
    /**
     * @dev Returns the address of the marketplace where the sale is tracked.
     */
    function getMarket(uint256 id) external view returns (address);

    /**
     * @dev Adding a new marketplace address to track the sale.
     */
    function addMarket(address[] memory markets) external;

    /**
     * @dev Removing the marketplace from sales tracking.
     */
    function delMarket(address[] memory markets) external;

    /**
     * @dev Returns a logical value, 
     * `true` if the NFT is sale and 
     * `false` if it is a transfer.
     */
    function isSale() external view returns (bool sale);
}