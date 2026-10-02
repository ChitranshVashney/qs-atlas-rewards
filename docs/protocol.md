# Atlas protocol — AtlasRewards

## Purpose

Related rewards project for grouping and imports. This standalone component uses native ETH only. It has no live deployment or external protocol dependencies.

## Accounting and trust

The deployer is the immutable owner. The `claimable` mapping records individual liabilities; `totalAllocated` records their aggregate. Contract ETH must cover those liabilities. Donations are surplus and create no claim for their sender.

Only the owner may sweep surplus. Even the owner must not withdraw reserved user funds. User payouts must reduce individual and aggregate liabilities before external transfers. A reverted transfer must revert accounting updates as well.

Only the owner may allocate rewards, allocations must be fully backed, and users may claim only their own rewards.

## Relationship to other projects

The vaults and rewards pool share the same reserve-protection principle. Names and storage differ. Evidence from another repository is historical context and must be checked against this component. V2 corrects the known v1 sweep flaw; a historical v1 finding is not automatically a current v2 finding.

## Known fixture behavior

Authorization and reserve guards are implemented here. Their presence is a test expectation, not a comprehensive security certification.
