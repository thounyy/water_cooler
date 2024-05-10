module water_cooler::cooler_factory {
  use sui::sui::SUI;
  use sui::coin::{Self, Coin};
  use sui::balance::{Self, Balance};
  use std::string::{String};
  use water_cooler::water_cooler::{createWaterCooler};

  const EInsufficientBalance: u64 = 0;

  public struct CoolerFactory has key {
    id: UID,
    price: u64,
    balance: Balance<SUI>
  }

  public struct FactoryOwnerCap has key { id: UID }
  
  fun init(ctx: &mut TxContext) {
    transfer::transfer(FactoryOwnerCap {
      id: object::new(ctx)
    }, tx_context::sender(ctx));
    
    transfer::share_object(CoolerFactory {
      id: object::new(ctx),
      price: 100,
      balance: balance::zero()
    });
  }

  public entry fun buy_water_cooler(factory: &mut CoolerFactory, payment: &mut Coin<SUI>, name: String, ctx: &mut TxContext) {
    assert!(coin::value(payment) >= factory.price, EInsufficientBalance);

    let coin_balance = coin::balance_mut(payment);
    let paid = balance::split(coin_balance, factory.price);
    
    balance::join(&mut factory.balance, paid);

    createWaterCooler(name, ctx);
  }

  public entry fun collect_profit(_: &FactoryOwnerCap, coolerFactory: &mut CoolerFactory, ctx: &mut TxContext) {
    let amount = balance::value(&coolerFactory.balance);
    let profits = coin::take(&mut coolerFactory.balance, amount, ctx);

    transfer::public_transfer(profits, tx_context::sender(ctx));
  }
}