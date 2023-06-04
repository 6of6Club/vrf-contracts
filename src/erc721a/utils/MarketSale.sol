// SPDX-License-Identifier: MIT
// MarketSale Contract v0.0.1
// Creator: RockArt 🪨 AI

pragma solidity ^0.8.13;

import './IMarketSale.sol';

/**
 * @dev Contract of MarketSale.
 * @dev Implementation of the {IMarketSale} interface.
 */
abstract contract MarketSale is IMarketSale {
    address[] private markets;

    /**
     * @dev See {IMarketSale-getMarket}.
     */
    function getMarket(uint256 id) external view returns (address) {
        return markets[id];
    }

    /**
     * @dev See {IMarketSale-getMarket}.
     */
    function addMarket(address[] memory _markets) external {
        for (uint256 i = 0; i < _markets.length; i++) {
            markets.push(_markets[i]);
        }
    }

    /**
     * @dev See {IMarketSale-delMarket}.
     */
    function delMarket(address[] memory _markets) external {
        for (uint256 i = 0; i < markets.length; i++) {
            for (uint256 j = 0; j < _markets.length; j++) {
                address market = _markets[j];
                if (market == markets[i]) {
                    markets[i] = markets[markets.length-1];
                    markets.pop();
                    break;
                }
            }
        }
    }

    /**
     * @dev See {IMarketSale-isSale}.
     */
    function isSale() public view returns (bool sale) {
        for (uint256 i = 0; i < markets.length; i++) {
            if (address(markets[i]).balance > 0) {
                sale = true;
                break;
            }
        }
    }
}