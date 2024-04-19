library;

use std::{bytes::Bytes, hash::Hash};
use ::errors::PythError;

struct GovernanceInstruction {
    magic: u32,
    module: GovernanceModule,
    action: u8,
    target_chain_id: u16,
    payload: Bytes,
}

enum GovernanceModule {
    Executor: (), // 0
    Target: (), // 1
    EvmExecutor: (), // 2
    StacksTarget: (), // 3
}


enum GovernanceAction {
    UpgradeContract: (), // 0
    AuthorizeGovernanceDataSourceTransfer: (), // 1
    SetDataSources: (), // 2
    SetFee: (), // 3
    SetValidPeriod: (), // 4
    RequestGovernanceDataSourceTransfer: (), // 5
    SetWormholeAddress: (), // 6
}


const MAGIC: u32 = 0x5054474d;

const MODULE: GovernanceModule = GovernanceModule::Target;

impl GovernanceInstruction {
    pub fn new(magic: u32,
                module: GovernanceModule,
                action: u8,
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

        let mod_number = u8::from_be_bytes([
            encoded_instruction.get(index).unwrap(),
        ]);
        let module = match mod_number {
            0 => GovernanceModule::Executor,
            1 => GovernanceModule::Target,
            2 => GovernanceModule::EvmExecutor,
            3 => GovernanceModule::StacksTarget,
            _ => return Err(PythError::InvalidGovernanceModule),
        };
        require(module == GovernanceModule::Target, PythError::InvalidGovernanceTarget);
        // addtionally skip minor_version(2 bytes) as unused
        index += 1;

        let action_number = u8::from_be_bytes([
            encoded_instruction.get(index).unwrap(),
        ]);
        let governance_action = match action_number {
            0 => GovernanceAction::UpgradeContract,
            1 => GovernanceAction::AuthorizeGovernanceDataSourceTransfer,
            2 => GovernanceAction::SetDataSources,
            3 => GovernanceAction::SetFee,
            4 => GovernanceAction::SetValidPeriod,
            5 => GovernanceAction::RequestGovernanceDataSourceTransfer,
            6 => GovernanceAction::SetWormholeAddress,
            _ => return Err(PythError::InvalidGovernanceAction),
        };
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
            action_number,
            target_chain_id,
            payload,
        )
    }
}

pub fn parse_governance_instruction(encoded_payload: Bytes) {
    let mut index = 0;
    let magic = u32::from_be_bytes([
        encoded_payload.get(index).unwrap(),
        encoded_payload.get(index + 1).unwrap(),
        encoded_payload.get(index + 2).unwrap(),
        encoded_payload.get(index + 3).unwrap(),
    ]);
    require(magic == MAGIC, PythError::InvalidMagic);
    index += 4;
}