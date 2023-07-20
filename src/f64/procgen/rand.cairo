use array::ArrayTrait;
use integer::{u64_safe_divmod, u64_as_non_zero, u256_from_felt252};
use option::OptionTrait;
use traits::{Into, TryInto};

use cubit::f64::types::fixed::{Fixed, FixedTrait, ONE};

fn derive(seed: felt252, entropy: felt252) -> felt252 {
    let mut input = ArrayTrait::new();
    input.append(seed);
    input.append(entropy);
    return poseidon::poseidon_hash_span(input.span());
}

// Returns a psuedo-random value between two values based on a seed. The returned
// value is inclusive of the low param and exclusive of the high param (low <= res < high)
fn fixed_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    let range = high - low; // will revert if high < low
    let seed_low = u256_from_felt252(seed).low % ONE.into();
    return FixedTrait::new(seed_low.try_into().unwrap(), false) * range + low;
}

fn u64_between(seed: felt252, low: u64, high: u64) -> u64 {
    let range = high - low; // will revert if high < low
    let seed_low = u256_from_felt252(seed).low % ONE.into();
    return seed_low.try_into().unwrap() * range + low * ONE;
}

fn fixed_normal_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    let acc = _fixed_normal_between_loop(seed, low, high, FixedTrait::ZERO(), 5);
    return acc / FixedTrait::new_unscaled(5, false);
}

fn u64_normal_between(seed: felt252, low: u64, high: u64) -> u64 {
    let res = _u64_normal_between_loop(seed, low, high, 0, 5);
    let (div, rem) = u64_safe_divmod(res, u64_as_non_zero(5));

    // Round around 0.5
    if rem > 2147483648 {
        return div + 1;
    } else {
        return div;
    }
}

fn _fixed_normal_between_loop(seed: felt252, low: Fixed, high: Fixed, acc: Fixed, iter: felt252) -> Fixed {
    if (iter == 0) { return acc; }
    let iter_seed = derive(seed, iter);
    let sample = fixed_between(iter_seed, low, high);
    return _fixed_normal_between_loop(seed, low, high, acc + sample, iter - 1);
}


fn _u64_normal_between_loop(seed: felt252, low: u64, high: u64, acc: u64, iter: felt252) -> u64 {
    if iter == 0 { return acc; }
    let iter_seed = derive(seed, iter);
    let sample = u64_between(iter_seed, low, high);
    return _u64_normal_between_loop(seed, low, high, acc + sample, iter - 1);
}
// Tests --------------------------------------------------------------------------------------------------------------

use debug::PrintTrait;

use cubit::f64::procgen::rand;
use cubit::f64::test::helpers::assert_precise;
use cubit::f64::types::fixed::FixedPrint;

// TODO: finish tests

#[test]
#[available_gas(40000)]
fn test_derive() {
    let r = rand::derive(1, 2);
}

#[test]
#[available_gas(75000)]
fn test_u64_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u64_between(seed, 1, 10);
}

#[test]
#[available_gas(250000)]
fn test_fixed_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::fixed_between(
        seed,
        FixedTrait::new_unscaled(1, false),
        FixedTrait::new_unscaled(10, false)
    );
}

#[test]
#[available_gas(500000)]
fn test_u64_normal_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u64_normal_between(seed, 1, 10);
}

#[test]
#[available_gas(1000000)]
fn test_fixed_normal_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::fixed_normal_between(
        seed,
        FixedTrait::new_unscaled(1, false),
        FixedTrait::new_unscaled(10, false)
    );
}
