use array::ArrayTrait;
use integer::u256_from_felt252;
use traits::Into;

use cubit::types::fixed::{Fixed, FixedTrait, ONE_u128};

fn derive(seed: felt252, entropy: felt252) -> felt252 {
    let mut input = Default::default();
    input.append(seed);
    input.append(entropy);
    return poseidon::poseidon_hash_span(input.span());
}

// Returns a psuedo-random value between two values based on a seed. The returned
// value is inclusive of the low param and exclusive of the high param (low <= res < high)
fn fixed_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    assert(high > low, 'high !> low');
    let seed_low = u256_from_felt252(seed).low;
    let rem = FixedTrait::new(seed_low, false) % FixedTrait::new(ONE_u128, false);
    return rem * (high - low) + low;
}

fn u128_between(seed: felt252, low: u128, high: u128) -> u128 {
    let fixed_res = fixed_between(seed, FixedTrait::new_unscaled(low, false), FixedTrait::new_unscaled(high, false));
    return fixed_res.mag / ONE_u128;
}

fn fixed_normal_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    let acc = _fixed_normal_between_loop(seed, low, high, FixedTrait::new(0_u128, false), 5_u128);
    return acc / FixedTrait::new_unscaled(5_u128, false);
}

fn u128_normal_between(seed: felt252, low: u128, high: u128) -> u128 {
    let fixed_res = fixed_normal_between(
        seed, FixedTrait::new_unscaled(low, false),
        FixedTrait::new_unscaled(high, false)
    );

    return fixed_res.mag / ONE_u128;
}

fn _fixed_normal_between_loop(seed: felt252, low: Fixed, high: Fixed, acc: Fixed, iter: u128) -> Fixed {
    if (iter == 0_u128) { return acc; }
    let iter_seed = derive(seed, iter.into());
    let sample = fixed_between(iter_seed, low, high);
    return _fixed_normal_between_loop(seed, low, high, acc + sample, iter - 1_u128);
}

// Tests --------------------------------------------------------------------------------------------------------------

use cubit::procgen::rand;
use cubit::test::helpers::assert_precise;
use cubit::types::fixed::FixedPrint;

// TODO: finish tests

#[test]
#[available_gas(10000000)]
fn test_derive() {
    let r = rand::derive(1, 2);
}

#[test]
#[available_gas(10000000)]
fn test_u128_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u128_between(seed, 1_u128, 10_u128);
}

#[test]
#[available_gas(10000000)]
fn test_fixed_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::fixed_between(
        seed,
        FixedTrait::new_unscaled(1_u128, false),
        FixedTrait::new_unscaled(10_u128, false)
    );
}

#[test]
#[available_gas(10000000)]
fn test_u128_normal_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u128_normal_between(seed, 1_u128, 10_u128);
}

#[test]
#[available_gas(10000000)]
fn test_fixed_normal_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::fixed_normal_between(
        seed,
        FixedTrait::new_unscaled(1_u128, false),
        FixedTrait::new_unscaled(10_u128, false)
    );
}
