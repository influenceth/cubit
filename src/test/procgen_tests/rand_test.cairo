use debug::PrintTrait;

use cubit::test::helpers::assert_precise;

use cubit::procgen::rand;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedPrint;


#[test]
#[available_gas(10000000)]
fn test_derive() {
    let r = rand::derive(1, 2);
    // r.print();
}

#[test]
#[available_gas(10000000)]
fn test_u128_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u128_between(seed, 1_u128, 10_u128);
    // r.print();
}

#[test]
#[available_gas(10000000)]
fn test_fixed_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::fixed_between(seed, Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(10_u128, false));
    // r.print();
}

#[test]
#[available_gas(10000000)]
fn test_u128_normal_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::u128_normal_between(seed, 1_u128, 10_u128);
    // r.print();
}

#[test]
#[available_gas(10000000)]
fn test_fixed_normal_between() {
    let seed = rand::derive(432352, 701023);
    let r = rand::fixed_normal_between(seed, Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(10_u128, false));
    // r.print();
}