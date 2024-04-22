library;

use ::errors::PythError;
use ::data_structures::{data_source::*, price::*, wormhole_light::{StorageGuardianSet, WormholeVM}};
use pyth_interface::data_structures::{data_source::DataSource, price::{PriceFeed, PriceFeedId}, upgrade_contract_payload::UpgradeContractPayload};
use std::{bytes::Bytes, hash::Hash};

pub struct GovernanceInstruction {
    magic: u32,
    module: GovernanceModule,
    action: GovernanceAction,
    target_chain_id: u16,
    payload: Bytes,
}

enum GovernanceModule {
    Executor: (), // 0
    Target: (), // 1
    EvmExecutor: (), // 2
    StacksTarget: (), // 3
    Invalid: (),
}

pub enum GovernanceAction {
    UpgradeContract: (), // 0
    AuthorizeGovernanceDataSourceTransfer: (), // 1
    SetDataSources: (), // 2
    SetFee: (), // 3
    SetValidPeriod: (), // 4
    RequestGovernanceDataSourceTransfer: (), // 5
    SetWormholeAddress: (), // 6
    Invalid: (),
}

const MAGIC: u32 = 0x5054474d;

impl GovernanceInstruction {
    pub fn new(magic: u32,
                module: GovernanceModule,
                action: GovernanceAction,
                target_chain_id: u16,
                payload: Bytes
                ) -> Self {
        Self { magic, module, action, target_chain_id, payload }
    }

    pub fn parse_governance_instruction(encoded_instruction: Bytes) -> Self {
        let mut index = 0;
        let magic = u32::from_be_bytes([
            encoded_instruction.get(index).unwrap(),
            encoded_instruction.get(index + 1).unwrap(),
            encoded_instruction.get(index + 2).unwrap(),
            encoded_instruction.get(index + 3).unwrap(),
        ]);
        require(magic == MAGIC, PythError::InvalidMagic);
        index += 4;

        let mod_number = encoded_instruction.get(index).unwrap();
        let module = match mod_number {
            0 => GovernanceModule::Executor,
            1 => GovernanceModule::Target,
            2 => GovernanceModule::EvmExecutor,
            3 => GovernanceModule::StacksTarget,
            _ => GovernanceModule::Invalid,
        };
        require(match module {
            GovernanceModule::Target => true,
            _ => false,
        }, PythError::InvalidGovernanceTarget);
        // addtionally skip minor_version(2 bytes) as unused
        index += 1;

        let action_number = encoded_instruction.get(index).unwrap();
        let governance_action = match action_number {
            0 => GovernanceAction::UpgradeContract,
            1 => GovernanceAction::AuthorizeGovernanceDataSourceTransfer,
            2 => GovernanceAction::SetDataSources,
            3 => GovernanceAction::SetFee,
            4 => GovernanceAction::SetValidPeriod,
            5 => GovernanceAction::RequestGovernanceDataSourceTransfer,
            6 => GovernanceAction::SetWormholeAddress,
            _ => GovernanceAction::Invalid,
        };
        require(match governance_action {
            GovernanceAction::Invalid => false,
            _ => true,
        }, PythError::InvalidGovernanceAction);
        index += 1;

        let target_chain_id = u16::from_be_bytes([
            encoded_instruction.get(index).unwrap(),
            encoded_instruction.get(index + 1).unwrap(),
        ]);
        index += 2;

        let (_, payload) = encoded_instruction.split_at(encoded_instruction.len() - index);

        GovernanceInstruction::new(
            magic,
            module,
            governance_action,
            target_chain_id,
            payload,
        )
    }

    pub fn parse_upgrade_contract_payload(encoded_payload: Bytes) -> UpgradeContractPayload {
        let mut index = 0;
        let b256_encoded_payload: b256 = encoded_payload.into();
        let uc = UpgradeContractPayload {
            new_implementation: Identity::Address(Address::from(b256_encoded_payload)),
        };
        index += 20;
        require(index == encoded_payload.len(), PythError::InvalidGovernanceMessage);
        uc
    }
}
