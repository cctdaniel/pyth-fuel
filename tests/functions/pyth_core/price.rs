use crate::utils::interface::{
    pyth_core::{price, update_fee, update_price_feeds},
    pyth_init::constructor,
};

use crate::utils::setup::setup_environment;
use fuels::types::Bytes;
use pyth_sdk::{
    constants::{
        DEFAULT_SINGLE_UPDATE_FEE, TEST_ACCUMULATOR_ETH_USD_PRICE_FEED,
        TEST_ACCUMULATOR_USDC_USD_PRICE_FEED, TEST_BATCH_ETH_USD_PRICE_FEED,
        TEST_BATCH_USDC_USD_PRICE_FEED, TEST_EXTENDED_TIME_PERIOD,
    },
    pyth_utils::{
        default_data_sources, default_price_feed_ids, guardian_set_upgrade_3_vaa_bytes,
        test_accumulator_update_data_bytes, test_batch_update_data_bytes,
    },
};
mod success {

    use super::*;

    #[tokio::test]
    async fn gets_price_for_batch_update() {
        let (_oracle_contract_id, deployer) = setup_environment().await.unwrap();

        constructor(
            &deployer.instance,
            default_data_sources(),
            DEFAULT_SINGLE_UPDATE_FEE,
            TEST_EXTENDED_TIME_PERIOD, //As the contract checks against the current timestamp, this allows unit testing with old but real price updates
            Bytes(guardian_set_upgrade_3_vaa_bytes()),
        )
        .await;

        let fee = update_fee(&deployer.instance, test_batch_update_data_bytes())
            .await
            .value;

        update_price_feeds(&deployer.instance, fee, test_batch_update_data_bytes()).await;

        let eth_usd_price = price(&deployer.instance, default_price_feed_ids()[0])
            .await
            .value;
        let usdc_usd_price = price(&deployer.instance, default_price_feed_ids()[1])
            .await
            .value;

        assert_eq!(
            (eth_usd_price.price as f64) * 10f64.powf(-(eth_usd_price.exponent as f64)),
            (TEST_BATCH_ETH_USD_PRICE_FEED.price.price as f64)
                * 10f64.powf(-(TEST_BATCH_ETH_USD_PRICE_FEED.price.exponent as f64)),
        );
        assert_eq!(
            (usdc_usd_price.price as f64) * 10f64.powf(-(usdc_usd_price.exponent as f64)),
            (TEST_BATCH_USDC_USD_PRICE_FEED.price.price as f64)
                * 10f64.powf(-(TEST_BATCH_USDC_USD_PRICE_FEED.price.exponent as f64)),
        );
    }

    #[tokio::test]
    async fn gets_price_for_accumulator_update() {
        let (_oracle_contract_id, deployer) = setup_environment().await.unwrap();

        constructor(
            &deployer.instance,
            default_data_sources(),
            DEFAULT_SINGLE_UPDATE_FEE,
            TEST_EXTENDED_TIME_PERIOD, //As the contract checks against the current timestamp, this allows unit testing with old but real price updates
            Bytes(guardian_set_upgrade_3_vaa_bytes()),
        )
        .await;

        let fee = update_fee(&deployer.instance, test_accumulator_update_data_bytes())
            .await
            .value;

        update_price_feeds(
            &deployer.instance,
            fee,
            test_accumulator_update_data_bytes(),
        )
        .await;

        let eth_usd_price = price(&deployer.instance, default_price_feed_ids()[0])
            .await
            .value;
        let usdc_usd_price = price(&deployer.instance, default_price_feed_ids()[1])
            .await
            .value;

        assert_eq!(
            (eth_usd_price.price as f64) * 10f64.powf(-(eth_usd_price.exponent as f64)),
            (TEST_ACCUMULATOR_ETH_USD_PRICE_FEED.price.price as f64)
                * 10f64.powf(-(TEST_ACCUMULATOR_ETH_USD_PRICE_FEED.price.exponent as f64)),
        );
        assert_eq!(
            (usdc_usd_price.price as f64) * 10f64.powf(-(usdc_usd_price.exponent as f64)),
            (TEST_ACCUMULATOR_USDC_USD_PRICE_FEED.price.price as f64)
                * 10f64.powf(-(TEST_ACCUMULATOR_USDC_USD_PRICE_FEED.price.exponent as f64)),
        );
    }
}