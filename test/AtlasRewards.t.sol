// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {TestBase} from "./TestBase.sol";
import {AtlasRewards} from "../src/AtlasRewards.sol";

contract AtlasRewardsTest is TestBase {
    AtlasRewards pool;

    function setUp() public {
        pool = new AtlasRewards();
        vm.deal(address(pool), 3 ether);
    }

    function testAllocationAndClaim() public {
        pool.allocate(address(this), 2 ether);
        pool.claim();
        require(pool.claimable(address(this)) == 0 && pool.totalAllocated() == 0, "accounting");
        require(address(pool).balance == 1 ether, "payout");
    }

    function testCannotOverAllocate() public {
        (bool ok,) = address(pool).call(abi.encodeCall(pool.allocate, (address(this), 4 ether)));
        require(!ok && pool.totalAllocated() == 0, "backing");
    }

    function testCannotSweepAllocatedRewards() public {
        pool.allocate(address(this), 2 ether);
        (bool ok,) = address(pool).call(abi.encodeCall(pool.sweepSurplus, (payable(address(this)), 2 ether)));
        require(!ok, "reserve protection");
        pool.sweepSurplus(payable(address(this)), 1 ether);
        require(address(pool).balance == pool.totalAllocated(), "solvency");
    }

    function testStrangerCannotAllocateOrSweep() public {
        vm.prank(address(0xBEEF));
        (bool allocated,) = address(pool).call(abi.encodeCall(pool.allocate, (address(0xBEEF), 1 ether)));
        vm.prank(address(0xBEEF));
        (bool swept,) = address(pool).call(abi.encodeCall(pool.sweepSurplus, (payable(address(0xBEEF)), 1 ether)));
        require(!allocated && !swept, "authorization");
    }
}
