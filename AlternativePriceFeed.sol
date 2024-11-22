// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

import './Interfaces/IAlternativePriceFeed.sol';
import './Interfaces/ITokenManager.sol';

import './Dependencies/LiquityBase.sol';

contract AlternativePriceFeed is Ownable(msg.sender), IAlternativePriceFeed, LiquityBase {
  // --- Cosntants ---

  string public constant NAME = 'AlternativePriceFeed';

  // --- Attributes ---

  mapping(address => FallbackPriceData) public fallbackPrices; // token => price

  // --- Admin Functions ---

  function setFallbackPrices(TokenAmount[] memory tokenPrices) external onlyOwner {
    TokenAmount memory ta;
    FallbackPriceData storage fpd;
    for (uint i = 0; i < tokenPrices.length; i++) {
      ta = tokenPrices[i];
      fpd = fallbackPrices[ta.tokenAddress];
      fpd.price = ta.amount;
      fpd.lastUpdateTime = uint32(block.timestamp);
    }

    emit FallbackPriceChanged(tokenPrices);
  }

  function setFallbackTrustedimespan(address _token, uint32 _trustedTimespan) external onlyOwner {
    fallbackPrices[_token].trustedTimespan = _trustedTimespan;
    emit FallbackTrsutedTimespanChanged(_token, _trustedTimespan);
  }

  // --- View functions ---

  function getPrice(address _tokenAddress) external view override returns (uint price, bool isTrusted) {
    // cache
    FallbackPriceData memory fb = fallbackPrices[_tokenAddress];

    // fallback
    price = fb.price;
    isTrusted = fb.trustedTimespan == 0 ? false : fb.lastUpdateTime + fb.trustedTimespan >= block.timestamp;

    return (price, isTrusted);
  }
}
