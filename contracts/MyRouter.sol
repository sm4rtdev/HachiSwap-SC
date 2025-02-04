// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import './Router2.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract MyRouter is Router2, Ownable {
    address payable public devWallet;
    uint256 public fee; // Change to a variable to allow updates

    constructor(
        address _factory,
        address _weth,
        address payable _devWallet
    ) Router2(_factory, _weth) {
        devWallet = _devWallet;
        fee = 0.001 ether; // Set initial fee
    }

    // Function to change the developer wallet
    function setDevWallet(address payable _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    // Function to change the fee
    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function swapExactETHForTokens(
        uint amountOutMin,
        route[] calldata routes,
        address to,
        uint deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(msg.value >= fee, 'Insufficient ETH sent for fee');
        uint amountIn = msg.value - fee; // Deduct the fee
        devWallet.transfer(fee); // Transfer the fee to the dev wallet

        require(routes[0].from == address(weth), 'Router: INVALID_PATH');
        amounts = getAmountsOut(amountIn, routes);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            'Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        weth.deposit{value: amountIn}();
        assert(
            weth.transfer(
                pairFor(routes[0].from, routes[0].to, routes[0].stable),
                amounts[0]
            )
        );
        _swap(amounts, routes, to);
    }

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        route[] calldata routes,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        amounts = getAmountsOut(amountIn, routes);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            'Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        _safeTransferFrom(
            routes[0].from,
            msg.sender,
            pairFor(routes[0].from, routes[0].to, routes[0].stable),
            amounts[0]
        );
        _swap(amounts, routes, address(this));
        uint amountOut = IERC20(address(weth)).balanceOf(address(this));
        require(
            amountOut >= amountOutMin,
            'Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        devWallet.transfer(fee); // Transfer the fee to the dev wallet
        weth.withdraw(amountOut);
        _safeTransferETH(to, amountOut);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        route[] calldata routes,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        amounts = getAmountsOut(amountIn, routes);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            'Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
        _safeTransferFrom(
            routes[0].from,
            msg.sender,
            pairFor(routes[0].from, routes[0].to, routes[0].stable),
            amounts[0]
        );
        _swap(amounts, routes, to);
        devWallet.transfer(fee); // Transfer the fee to the dev wallet
    }
}
