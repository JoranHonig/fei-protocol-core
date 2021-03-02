pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../external/SafeMathCopy.sol";
import "./IFeiRouter.sol";

/// @title A Uniswap Router for FEI/ETH swaps
/// @author Fei Protocol
contract FeiRouter is IFeiRouter {
    using SafeMathCopy for uint256;

    // solhint-disable-next-line var-name-mixedcase
    IWETH public immutable WETH;

    // solhint-disable-next-line var-name-mixedcase
    IUniswapV2Pair public immutable PAIR;

    constructor(
        address pair,
        address weth
    ) public {
        PAIR = IUniswapV2Pair(pair);
        WETH = IWETH(weth);
    }

    modifier ensure(uint256 deadline) {
        // solhint-disable-next-line not-rely-on-time
        require(deadline >= block.timestamp, "FeiRouter: Expired");
        _;
    }

    receive() external payable {
        assert(msg.sender == address(WETH)); // only accept ETH via fallback from the WETH contract
    }

    /// @notice buy FEI for ETH with some protections
    /// @param minReward minimum mint reward for purchasing
    /// @param amountOutMin minimum FEI received
    /// @param to address to send FEI
    /// @param deadline block timestamp after which trade is invalid
    function buyFei(
        uint256 minReward,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external payable override ensure(deadline) returns (uint256 amountOut) {

        (uint256 reservesETH, uint256 reservesOther, bool isETH0) = _getReserves();

        uint256 amountIn = msg.value;
        amountOut = UniswapV2Library.getAmountOut(
            amountIn,
            reservesETH,
            reservesOther
        );
        
        require(
            amountOut >= amountOutMin,
            "FeiRouter: Insufficient output amount"
        );
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(address(PAIR), amountIn));

        address fei = isETH0 ? PAIR.token1() : PAIR.token0();
        uint256 feiBalanceBefore = IERC20(fei).balanceOf(to);

        (uint256 amount0Out, uint256 amount1Out) =
            isETH0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
        PAIR.swap(amount0Out, amount1Out, to, new bytes(0));

        uint256 feiBalanceAfter = IERC20(fei).balanceOf(to);
        uint256 reward = feiBalanceAfter.sub(feiBalanceBefore).sub(amountOut);
        require(reward >= minReward, "FeiRouter: Not enough reward");

        return amountOut;
    }

    /// @notice sell FEI for ETH with some protections
    /// @param maxPenalty maximum fei burn for purchasing
    /// @param amountIn amount of FEI to sell
    /// @param amountOutMin minimum ETH received
    /// @param to address to send ETH
    /// @param deadline block timestamp after which trade is invalid
    function sellFei(
        uint256 maxPenalty,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external override ensure(deadline) returns (uint256 amountOut) {
        (uint256 reservesETH, uint256 reservesOther, bool isETH0) =
            _getReserves();

        address fei = isETH0 ? PAIR.token1() : PAIR.token0();

        IERC20(fei).transferFrom(msg.sender, address(PAIR), amountIn);

        uint256 effectiveAmountIn = IERC20(fei).balanceOf(address(PAIR)).sub(reservesOther);

        if (effectiveAmountIn < amountIn) {
            uint256 penalty = amountIn - effectiveAmountIn;
            require(penalty <= maxPenalty, "FeiRouter: Penalty too high");
        }

        amountOut = UniswapV2Library.getAmountOut(
            effectiveAmountIn,
            reservesOther,
            reservesETH
        );
        require(
            amountOut >= amountOutMin,
            "FeiRouter: Insufficient output amount"
        );

        (uint256 amount0Out, uint256 amount1Out) =
            isETH0 ? (amountOut, uint256(0)) : (uint256(0), amountOut);

        PAIR.swap(amount0Out, amount1Out, address(this), new bytes(0));

        IWETH(WETH).withdraw(amountOut);

        TransferHelper.safeTransferETH(to, amountOut);
        return amountOut;
    }

    function _getReserves()
        internal
        view
        returns (
            uint256 reservesETH,
            uint256 reservesOther,
            bool isETH0
        )
    {
        (uint256 reserves0, uint256 reserves1, ) = PAIR.getReserves();
        isETH0 = PAIR.token0() == address(WETH);
        return
            isETH0
                ? (reserves0, reserves1, isETH0)
                : (reserves1, reserves0, isETH0);
    }
}
