use array::ArrayTrait;
use integer::{u128_safe_divmod, u128_as_non_zero, u256_from_felt252};
use traits::Into;

use cubit::types::fixed::{Fixed, FixedTrait, ONE_u128};

fn derive(seed: felt252, entropy: felt252) -> felt252 {
    let mut input = ArrayTrait::new();
    input.append(seed);
    input.append(entropy);
    return poseidon::poseidon_hash_span(input.span());
}

// Returns a psuedo-random value between two values based on a seed. The returned
// value is inclusive of the low param and exclusive of the high param (low <= res < high)
fn fixed_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    assert(high > low, 'high !> low');
    let seed_low = u256_from_felt252(seed).low;
    return FixedTrait::new(seed_low % ONE_u128, false) * (high - low) + low;
}

fn u128_between(seed: felt252, low: u128, high: u128) -> u128 {
    assert(high > low, 'high !> low');
    let seed = u256_from_felt252(seed).low % ONE_u128;
    return seed * (high - low) + low * ONE_u128;
}

fn fixed_normal_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    let acc = _fixed_normal_between_loop(seed, low, high, FixedTrait::new(0, false), 5);
    return acc / FixedTrait::new_unscaled(5, false);
}

fn u128_normal_between(seed: felt252, low: u128, high: u128) -> u128 {
    let res = _u128_normal_between_loop(seed, low, high, 0, 5);
    let (div, rem) = u128_safe_divmod(res, u128_as_non_zero(5));

    // Round around 0.5
    if rem > 9223372036854775808 {
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


fn _u128_normal_between_loop(seed: felt252, low: u128, high: u128, acc: u128, iter: felt252) -> u128 {
    if iter == 0 { return acc; }
    let iter_seed = derive(seed, iter);
    let sample = u128_between(iter_seed, low, high);
    return _u128_normal_between_loop(seed, low, high, acc + sample, iter - 1);
}
// Tests --------------------------------------------------------------------------------------------------------------

use cubit::procgen::rand;
use cubit::test::helpers::assert_precise;
use cubit::types::fixed::FixedPrint;

// TODO: finish tests

#[test]
#[available_gas(40000)]
fn test_derive() {
    let r = rand::derive(1, 2);
}

#[test]
#[available_gas(75000)]
fn test_u128_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u128_between(seed, 1, 10);
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
fn test_u128_normal_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u128_normal_between(seed, 1, 10);
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
