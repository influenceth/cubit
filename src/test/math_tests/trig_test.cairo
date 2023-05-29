use debug::PrintTrait;
use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;

use cubit::types::fixed::ONE;
use cubit::types::fixed::ONE_u128;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedInto;
use cubit::types::fixed::FixedPartialEq;
use cubit::types::fixed::FixedPrint;

use cubit::math::trig::HALF_PI_u128;
use cubit::math::trig::PI_u128;
use cubit::math::trig;

#[test]
#[available_gas(100000000)]
fn test_acos() {
    let a = Fixed::new(ONE_u128, false);
    assert(trig::acos(a).into() == 0, 'invalid one');

    let a = Fixed::new(ONE_u128 / 2_u128, false);
    assert(trig::acos(a).into() == 19317385211018935530, 'invalid half'); // 1.0471975506263043

    let a = Fixed::new(0_u128, false);
    assert(trig::acos(a).into() == 28976077832308491370, 'invalid zero'); // PI / 2

    let a = Fixed::new(ONE_u128 / 2_u128, true);
    assert(trig::acos(a).into() == 38634770453598047209, 'invalid neg half'); // 2.094395102963489

    let a = Fixed::new(ONE_u128, true);
    assert(trig::acos(a).into() == 57952155664616982739, 'invalid neg one'); // PI
}

#[test]
#[should_panic]
#[available_gas(100000000)]
fn test_acos_fail() {
    let a = Fixed::new(2_u128 * ONE_u128, true);
    trig::acos(a);
}

#[test]
#[available_gas(100000000)]
fn test_atan() {
    let a = Fixed::new(2_u128 * ONE_u128, false);
    assert_precise(trig::atan(a), 20423289048683266000, 'invalid two', Option::None(()));

    let a = Fixed::new(ONE_u128, false);
    assert_precise(trig::atan(a), 14488038916154245000, 'invalid one', Option::None(()));

    let a = Fixed::new(ONE_u128 / 2_u128, false);
    assert_precise(trig::atan(a), 8552788783625223000, 'invalid half', Option::None(()));

    let a = Fixed::new(0_u128, false);
    assert(trig::atan(a).into() == 0, 'invalid zero');

    let a = Fixed::new(ONE_u128 / 2_u128, true);
    assert_precise(trig::atan(a), -8552788783625223000, 'invalid neg half', Option::None(()));

    let a = Fixed::new(ONE_u128, true);
    assert_precise(trig::atan(a), -14488038916154245000, 'invalid neg one', Option::None(()));

    let a = Fixed::new(2_u128 * ONE_u128, true);
    assert_precise(trig::atan(a), -20423289048683266000, 'invalid neg two', Option::None(()));
}

#[test]
#[available_gas(100000000)]
fn test_asin() {
    let a = Fixed::new(ONE_u128, false);
    assert(trig::asin(a).into() == 28976077832308491370, 'invalid one'); // PI / 2

    let a = Fixed::new(ONE_u128 / 2_u128, false);
    assert(trig::asin(a).into() == 9658692617570005102, 'invalid half');

    let a = Fixed::new(0_u128, false);
    assert(trig::asin(a).into() == 0, 'invalid zero');

    let a = Fixed::new(ONE_u128 / 2_u128, true);
    assert(trig::asin(a).into() == -9658692617570005102, 'invalid neg half');

    let a = Fixed::new(ONE_u128, true);
    assert(trig::asin(a).into() == -28976077832308491370, 'invalid neg one'); // -PI / 2
}

#[test]
#[should_panic]
#[available_gas(100000000)]
fn test_asin_fail() {
    let a = Fixed::new(2_u128 * ONE_u128, false);
    trig::asin(a);
}

#[test]
#[available_gas(100000000)]
fn test_cos() {
    let a = Fixed::new(HALF_PI_u128, false);
    assert(trig::cos(a).into() == 0, 'invalid half pi');

    let a = Fixed::new(HALF_PI_u128 / 2_u128, false);
    assert_precise(
        trig::cos(a), 13043817825332783000, 'invalid quarter pi', Option::None(())
    ); // 0.7071067811865475

    let a = Fixed::new(PI_u128, false);
    assert_precise(trig::cos(a), -18446744073709552000, 'invalid pi', Option::None(()));

    let a = Fixed::new(HALF_PI_u128, true);
    assert(trig::cos(a).into() == -1, 'invalid neg half pi'); // -0.000...

    let a = Fixed::new_unscaled(17_u128, false);
    assert_precise(
        trig::cos(a), -5075867675505434000, 'invalid 17', Option::None(())
    ); // -0.2751631780463348

    let a = Fixed::new_unscaled(17_u128, true);
    assert_precise(
        trig::cos(a), -5075867675505434000, 'invalid -17', Option::None(())
    ); // -0.2751631780463348
}

#[test]
#[available_gas(100000000)]
fn test_sin() {
    let a = Fixed::new(HALF_PI_u128, false);
    assert_precise(trig::sin(a), ONE, 'invalid half pi', Option::None(()));

    let a = Fixed::new(HALF_PI_u128 / 2_u128, false);
    assert_precise(
        trig::sin(a), 13043817825332781000, 'invalid quarter pi', Option::None(())
    ); // 0.7071067811865475

    let a = Fixed::new(PI_u128, false);
    assert(trig::sin(a).into() == 0, 'invalid pi');

    let a = Fixed::new(HALF_PI_u128, true);
    assert_precise(
        trig::sin(a), -ONE, 'invalid neg half pi', Option::None(())
    ); // 0.9999999999939766

    let a = Fixed::new_unscaled(17_u128, false);
    assert_precise(
        trig::sin(a), -17734653485808441000, 'invalid 17', Option::None(())
    ); // -0.9613974918793389

    let a = Fixed::new_unscaled(17_u128, true);
    assert_precise(
        trig::sin(a), 17734653485808441000, 'invalid -17', Option::None(())
    ); // 0.9613974918793389
}

#[test]
#[available_gas(100000000)]
fn test_tan() {
    let a = Fixed::new(HALF_PI_u128 / 2_u128, false);
    assert(trig::tan(a).into() == ONE, 'invalid quarter pi');

    let a = Fixed::new(PI_u128, false);
    assert(trig::tan(a).into() == 0, 'invalid pi');

    let a = Fixed::new_unscaled(17_u128, false);
    assert_precise(
        trig::tan(a), 64451367727204090000, 'invalid 17', Option::None(())
    ); // 3.493917677159002

    let a = Fixed::new_unscaled(17_u128, true);
    assert_precise(
        trig::tan(a), -64451367727204090000, 'invalid -17', Option::None(())
    ); // -3.493917677159002
}
