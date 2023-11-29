// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IWstETH.sol";
import "./interfaces/ISwapRouter.sol";
import "./interfaces/IAavePool.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IVault.sol";

import "hardhat/console.sol";

contract Strategy {
    uint256 public constant PERCENTAGE_FACTOR = 1e4;
    uint256 public constant RECURRING_CALL_LIMIT = 10;
    uint256 public constant INTEREST_RATE_MODE = 2; // variable rate mode
    uint256 public leverageRatio;
    address public swapRouter;
    uint24 public poolFee;
    address public aavePool;
    address WETH;
    address WstETH;
    address zapAddress;
    address vaultAddress;

    address public constant sfrxETHAddress =
        0xac3E018457B222d93114458476f3E3416Abbe38F;
    address public constant rETHAddress =
        0xae78736Cd615f374D3085123A210448E74Fc6393;
    address public constant wstETHAddress =
        0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address public constant cbETHAddress =
        0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;
    address public constant wethAddress =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ankrETHAddress =
        0xE95A203B1a91a908F9B9CE46459d101078c2c3cb;
    address public constant swETHAddress =
        0xf951E335afb289353dc249e82926178EaC7DEd78;
    address[] public LSTs;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor(
        address _asset,
        address _lendingPool,
        address _swapRouter,
        uint24 _poolFee,
        address _vault,
        address _zap
    ) {
        WstETH = _asset;
        aavePool = _lendingPool;
        swapRouter = _swapRouter;
        poolFee = _poolFee;
        vaultAddress = _vault;
        zapAddress = _zap;
        LSTs.push(sfrxETHAddress);
        LSTs.push(rETHAddress);
        LSTs.push(wstETHAddress);
        LSTs.push(cbETHAddress);
        LSTs.push(wethAddress);
        LSTs.push(ankrETHAddress);
        LSTs.push(swETHAddress);
    }

    /// @notice Callback function for flashloan.
    function executeOperation(
        address assetAddress,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        SafeERC20.safeIncreaseAllowance(
            IERC20(assetAddress),
            zapAddress,
            amount
        );
        IZap(zapAddress).deposit_lsd(assetAddress, amount);
        uint256 balance = IERC20(IVault(vaultAddress).unshETHAddress())
            .balanceOf(address(this));
        SafeERC20.safeIncreaseAllowance(
            IERC20(IVault(vaultAddress).unshETHAddress()),
            vaultAddress,
            balance
        );
        IVault(vaultAddress).exit(balance);

        console.log("gotten vaule: ", _getAllLSTsValue());
        console.log(
            "loan vaule  : ",
            IVault(vaultAddress).getEthConversionRate(assetAddress) *
                (amount + premium)
        );
        return true;
    }

    function loan(
        uint256 wstETHAmount
    ) public returns (uint256 repaidETHAmount) {
        console.log("WstETHAmount : ", wstETHAmount);
        IAavePool(aavePool).flashLoanSimple(
            address(this),
            WstETH,
            wstETHAmount,
            abi.encode(wstETHAmount),
            0
        );
    }

    function _getAllLSTsValue() internal view returns (uint256 result) {
        for (uint i; i < LSTs.length; i++) {
            result += (IVault(vaultAddress).getEthConversionRate(LSTs[i]) *
                IERC20(LSTs[i]).balanceOf(address(this)));
        }
    }

    /// @notice receive function to receive eth
    receive() external payable {}
}
