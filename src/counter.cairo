#[starknet::interface]
trait ICounter<T> {
    fn get_counter(self: @T) -> u32;
    fn increase_counter(ref self: T);
}

#[starknet::interface]
trait IKillSwitch<TContractState> {
    fn is_active(self: @TContractState) -> bool;
}



#[starknet::contract]
mod Counter {
    use starknet::{ContractAddress};
    use core::starknet::event::EventEmitter;
    use super::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait, ICounter};

    #[storage]
    struct Storage {
        counter: u32,
        kill_switch: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_value: u32, contract_address: ContractAddress) {
        self.counter.write(init_value);
        self.kill_switch.write(contract_address);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
    }

        #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        #[key]
        counter: u32,
    }

    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState> {
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }
        fn increase_counter(ref self: ContractState) {
            assert!(!(IKillSwitchDispatcher { contract_address: self.kill_switch.read()}).is_active(), "Kill Switch is active");
            self.counter.write(self.counter.read() + 1);
        }
    }
}