library;

/// Error log for a Pyth oracle revert.
pub enum PythError {
    FeesCanOnlyBePaidInTheBaseAsset: (),
    GuardianSetNotFound: (),
    InsufficientFee: (),
    InvalidArgument: (),
    InvalidUpdateData: (),
    InvalidUpdateDataSource: (),
    InvalidUpgradeModule: (),
    NewGuardianSetIsEmpty: (),
    NewGuardianSetIndexIsInvalid: (),
    /// Emitted when a Price's `publish_time` is stale.
    OutdatedPrice: (),
    /// Emitted when a PriceFeed could not be retrieved.
    PriceFeedNotFound: (),
    PriceFeedNotFoundWithinRange: (),
    WormholeGovernanceActionNotFound: (),
}

pub enum WormholeError{
    VmVersionIncompatible: (),
    GuardianSetNotFound: (),
    InvalidGuardianSet: (),
    GuardianSetHasExpired: (),
    SignersLengthIrretrievable: (),
    GuardianIndexIrretrievable: (),
    SignatureVIrretrievable: (),
    SignatureIndicesNotAscending: (),
    VMSignatureInvalid: (),
    GuardianSetKeyIrretrievable: (),
    NoQuorum: (),
    VMConsistencyLevelIrretrievable: (),
}