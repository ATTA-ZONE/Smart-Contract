// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Minter {
     function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// PopcornClaimer must be Manager of Popcorn
contract PopcornClaimer is Ownable {
    IERC20Minter popcornToken;
    address public treasury;
    mapping(address => uint256) public availableUnclaimedToken;

    event Release(address indexed user, uint256 value);
    event Claimed(address indexed user, uint256 value);
    constructor (address _popcornToken, address _treasury) {
        popcornToken = IERC20Minter(_popcornToken);
        treasury = _treasury;
    }

    function batchRelease(address[] calldata users, uint256[] calldata amounts) external onlyOwner {
        require(users.length == amounts.length, "users and amounts array length must match.");
        for (uint256 i = 0; i < users.length; ++i) {
            
            // Be aware of overflow, we trust contract manager so do not check
            availableUnclaimedToken[users[i]] += amounts[i];
            emit Release(users[i], amounts[i]);
        }
    }

    function claim(address user) external {
        if (availableUnclaimedToken[user] > 0) {
           // popcornToken.mint(user, availableUnclaimedToken[user]);
            popcornToken.transferFrom(treasury, user, availableUnclaimedToken[user]);
            emit Claimed(user, availableUnclaimedToken[user]);
            availableUnclaimedToken[user] = 0;
        }
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }
}