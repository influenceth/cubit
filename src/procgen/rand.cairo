use array::ArrayTrait;
use array::array_append;
use array::array_new;
use gas::withdraw_gas_all;
use integer::u256_from_felt252;
use traits::Into;

use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::ONE_u128;

use debug::PrintTrait;


fn derive(seed: felt252, entropy: felt252) -> felt252 {
    let mut input = Default::default();
    input.append(seed);
    input.append(entropy);
    return poseidon::poseidon_hash_span(input.span());
}

// Returns a psuedo-random value between two values based on a seed. The returned
// value is inclusive of the low param and exclusive of the high param (low <= res < high)
fn fixed_between(seed: felt252, low: FixedType, high: FixedType) -> FixedType {
    assert(high > low, 'high !> low');
    let seed_low = u256_from_felt252(seed).low;
    let rem = Fixed::new(seed_low, false) % Fixed::new(ONE_u128, false);
    return rem * (high - low) + low;
}

fn u128_between(seed: felt252, low: u128, high: u128) -> u128 {
    let fixed_res = fixed_between(seed, Fixed::new_unscaled(low, false), Fixed::new_unscaled(high, false));
    return fixed_res.mag / ONE_u128;
}

fn fixed_normal_between(seed: felt252, low: FixedType, high: FixedType) -> FixedType {
    let acc = _fixed_normal_between_loop(seed, low, high, Fixed::new(0_u128, false), 5_u128);
    return acc / Fixed::new_unscaled(5_u128, false);
}

fn u128_normal_between(seed: felt252, low: u128, high: u128) -> u128 {
    let fixed_res = fixed_normal_between(seed, Fixed::new_unscaled(low, false), Fixed::new_unscaled(high, false));
    return fixed_res.mag / ONE_u128;
}

fn _fixed_normal_between_loop(
        seed: felt252, low: FixedType, high: FixedType, acc: FixedType, iter: u128
    ) -> FixedType {
    match withdraw_gas_all(get_builtin_costs()) {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt252>();
            array_append::<felt252>(ref data, 'OOG');
            panic(data);
        },
    }

    if (iter == 0_u128) {
        return acc;
    }

    let iter_seed = derive(seed, iter.into());
    let sample = fixed_between(iter_seed, low, high);
    return _fixed_normal_between_loop(seed, low, high, acc + sample, iter - 1_u128);
}
