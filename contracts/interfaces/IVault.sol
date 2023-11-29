// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.20;

interface IZap {
    function deposit_lsd(address lsdAddress, uint256 amount) external;
}

interface IVault {
    function exit(uint256 amount) external;

    function deposit(address lsd, uint256 amount) external;

    function getEthConversionRate(address lsd) external view returns (uint256);

    function unshETHAddress() external view returns (address);
}
