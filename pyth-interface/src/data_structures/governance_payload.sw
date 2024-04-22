library;

use std::bytes::Bytes;

pub struct UpgradeContractPayload {
    new_implementation: Identity,
}

pub struct AuthorizeGovernanceDataSourceTransferPayload {
    claim_vaa: Bytes,
}

pub struct RequestGovernanceDataSourceTransferPayload {
    governance_data_source_index: u32,
}

