use option::OptionTrait;

use cubit::types::fixed::{Fixed, FixedTrait, FixedAdd, FixedSub, FixedMul, FixedDiv, ONE_u128};


// CONSTANTS

const PI_u128: u128 = 57952155664616982739_u128;
const HALF_PI_u128: u128 = 28976077832308491370_u128;

// PUBLIC

// Calculates arccos(a) for -1 <= a <= 1 (fixed point)
// arccos(a) = arcsin(sqrt(1 - a^2)) - arctan identity has discontinuity at zero
fn acos(a: Fixed) -> Fixed {
    assert(a.mag <= ONE_u128, 'out of range');
    let asin_arg = (FixedTrait::new(ONE_u128, false) - a * a).sqrt();
    let asin_res = asin(asin_arg);

    if (a.sign) {
        return FixedTrait::new(PI_u128, false) - asin_res;
    } else {
        return asin_res;
    }
}

// Calculates arcsin(a) for -1 <= a <= 1 (fixed point)
// arcsin(a) = arctan(a / sqrt(1 - a^2))
fn asin(a: Fixed) -> Fixed {
    assert(a.mag <= ONE_u128, 'out of range');

    if (a.mag == ONE_u128) {
        return FixedTrait::new(HALF_PI_u128, a.sign);
    }

    let div = (FixedTrait::new(ONE_u128, false) - a * a).sqrt();
    return atan(a / div);
}

// Calculates arctan(a) (fixed point)
// See https://stackoverflow.com/a/50894477 for range adjustments
fn atan(a: Fixed) -> Fixed {
    let mut at = a.abs();
    let mut shift = false;
    let mut invert = false;

    // Invert value when a > 1
    if (at.mag > ONE_u128) {
        at = FixedTrait::new(ONE_u128, false) / at;
        invert = true;
    }

    // Account for lack of precision in polynomaial when a > 0.7
    if (at.mag > 12912720851596686131_u128) {
        let sqrt3_3 = FixedTrait::new(10650232656328343401_u128, false); // sqrt(3) / 3
        at = (at - sqrt3_3) / (FixedTrait::new(ONE_u128, false) + at * sqrt3_3);
        shift = true;
    }

    let t10 = FixedTrait::new(33784601907694228_u128, true);
    let t9 = FixedTrait::new(863077567022907619_u128, true);
    let t8 = FixedTrait::new(3582351446937658863_u128, false);
    let t7 = FixedTrait::new(4833057334070945981_u128, true);
    let t6 = FixedTrait::new(806366139934153963_u128, false);
    let t5 = FixedTrait::new(3505955710573417812_u128, false);
    let t4 = FixedTrait::new(25330242983263508_u128, false);
    let t3 = FixedTrait::new(6150896368532115927_u128, true);
    let t2 = FixedTrait::new(75835542453775_u128, false);
    let t1 = FixedTrait::new(18446743057812048409_u128, false);

    let r10 = t10 * at;
    let r9 = (r10 + t9) * at;
    let r8 = (r9 + t8) * at;
    let r7 = (r8 + t7) * at;
    let r6 = (r7 + t6) * at;
    let r5 = (r6 + t5) * at;
    let r4 = (r5 + t4) * at;
    let r3 = (r4 + t3) * at;
    let r2 = (r3 + t2) * at;
    let mut res = (r2 + t1) * at;

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = res + FixedTrait::new(9658692610769497123_u128, false); // pi / 6
    }

    if (invert) {
        res = res - FixedTrait::new(HALF_PI_u128, false);
    }

    return FixedTrait::new(res.mag, a.sign);
}

// Calculates cos(a) with a in radians (fixed point)
fn cos(a: Fixed) -> Fixed {
    return sin(FixedTrait::new(HALF_PI_u128, false) - a);
}

fn sin(a: Fixed) -> Fixed {
    let a1_u128 = a.mag % (2_u128 * PI_u128);
    let whole_rem = a1_u128 / PI_u128;
    let a2 = Fixed { mag: a1_u128 % PI_u128, sign: false };
    let mut partial_sign = false;

    if (whole_rem == 1_u128) {
        partial_sign = true;
    }

    let acc = Fixed { mag: ONE_u128, sign: false };
    let loop_res = a2 * _sin_loop(a2, 7_u128, acc);
    let res_sign = a.sign ^ partial_sign;
    return Fixed { mag: loop_res.mag, sign: res_sign };
}

// Calculates tan(a) with a in radians (fixed point)
fn tan(a: Fixed) -> Fixed {
    let sinx = sin(a);
    let cosx = cos(a);
    assert(cosx.mag != 0_u128, 'tan undefined');
    return sinx / cosx;
}

// Helper function to calculate Taylor series for sin
fn _sin_loop(a: Fixed, i: u128, acc: Fixed) -> Fixed {
    let div_u128 = (2_u128 * i + 2_u128) * (2_u128 * i + 3_u128);
    let term = a * a * acc / FixedTrait::new_unscaled(div_u128, false);
    let new_acc = FixedTrait::new(ONE_u128, false) - term;

    if (i == 0_u128) {
        return new_acc;
    }

    return _sin_loop(a, i - 1_u128, new_acc);
}

// Tests --------------------------------------------------------------------------------------------------------------

use traits::Into;

use cubit::test::helpers::assert_precise;
use cubit::types::fixed::{ONE, FixedInto, FixedPartialEq, FixedPrint};

#[test]
#[available_gas(100000000)]
fn test_acos() {
    let a = FixedTrait::new(ONE_u128, false);
    assert(acos(a).into() == 0, 'invalid one');

    let a = FixedTrait::new(ONE_u128 / 2_u128, false);
    assert(acos(a).into() == 19317385211018935530, 'invalid half'); // 1.0471975506263043

    let a = FixedTrait::new(0_u128, false);
    assert(acos(a).into() == 28976077832308491370, 'invalid zero'); // PI / 2

    let a = FixedTrait::new(ONE_u128 / 2_u128, true);
    assert(acos(a).into() == 38634770453598047209, 'invalid neg half'); // 2.094395102963489

    let a = FixedTrait::new(ONE_u128, true);
    assert(acos(a).into() == 57952155664616982739, 'invalid neg one'); // PI
}

#[test]
#[should_panic]
#[available_gas(100000000)]
fn test_acos_fail() {
    let a = FixedTrait::new(2_u128 * ONE_u128, true);
    acos(a);
}

#[test]
#[available_gas(100000000)]
fn test_atan() {
    let a = FixedTrait::new(2_u128 * ONE_u128, false);
    assert_precise(atan(a), 20423289048683266000, 'invalid two', Option::None(()));

    let a = FixedTrait::new(ONE_u128, false);
    assert_precise(atan(a), 14488038916154245000, 'invalid one', Option::None(()));

    let a = FixedTrait::new(ONE_u128 / 2_u128, false);
    assert_precise(atan(a), 8552788783625223000, 'invalid half', Option::None(()));

    let a = FixedTrait::new(0_u128, false);
    assert(atan(a).into() == 0, 'invalid zero');

    let a = FixedTrait::new(ONE_u128 / 2_u128, true);
    assert_precise(atan(a), -8552788783625223000, 'invalid neg half', Option::None(()));

    let a = FixedTrait::new(ONE_u128, true);
    assert_precise(atan(a), -14488038916154245000, 'invalid neg one', Option::None(()));

    let a = FixedTrait::new(2_u128 * ONE_u128, true);
    assert_precise(atan(a), -20423289048683266000, 'invalid neg two', Option::None(()));
}

#[test]
#[available_gas(100000000)]
fn test_asin() {
    let a = FixedTrait::new(ONE_u128, false);
    assert(asin(a).into() == 28976077832308491370, 'invalid one'); // PI / 2

    let a = FixedTrait::new(ONE_u128 / 2_u128, false);
    assert(asin(a).into() == 9658692617570005102, 'invalid half');

    let a = FixedTrait::new(0_u128, false);
    assert(asin(a).into() == 0, 'invalid zero');

    let a = FixedTrait::new(ONE_u128 / 2_u128, true);
    assert(asin(a).into() == -9658692617570005102, 'invalid neg half');

    let a = FixedTrait::new(ONE_u128, true);
    assert(asin(a).into() == -28976077832308491370, 'invalid neg one'); // -PI / 2
}

#[test]
#[should_panic]
#[available_gas(100000000)]
fn test_asin_fail() {
    let a = FixedTrait::new(2_u128 * ONE_u128, false);
    asin(a);
}

#[test]
#[available_gas(100000000)]
fn test_cos() {
    let a = FixedTrait::new(HALF_PI_u128, false);
    assert(cos(a).into() == 0, 'invalid half pi');

    let a = FixedTrait::new(HALF_PI_u128 / 2_u128, false);
    assert_precise(
        cos(a), 13043817825332783000, 'invalid quarter pi', Option::None(())
    ); // 0.7071067811865475

    let a = FixedTrait::new(PI_u128, false);
    assert_precise(cos(a), -18446744073709552000, 'invalid pi', Option::None(()));

    let a = FixedTrait::new(HALF_PI_u128, true);
    assert(cos(a).into() == -1, 'invalid neg half pi'); // -0.000...

    let a = FixedTrait::new_unscaled(17_u128, false);
    assert_precise(
        cos(a), -5075867675505434000, 'invalid 17', Option::None(())
    ); // -0.2751631780463348

    let a = FixedTrait::new_unscaled(17_u128, true);
    assert_precise(
        cos(a), -5075867675505434000, 'invalid -17', Option::None(())
    ); // -0.2751631780463348
}

#[test]
#[available_gas(100000000)]
fn test_sin() {
    let a = FixedTrait::new(HALF_PI_u128, false);
    assert_precise(sin(a), ONE, 'invalid half pi', Option::None(()));

    let a = FixedTrait::new(HALF_PI_u128 / 2_u128, false);
    assert_precise(
        sin(a), 13043817825332781000, 'invalid quarter pi', Option::None(())
    ); // 0.7071067811865475

    let a = FixedTrait::new(PI_u128, false);
    assert(sin(a).into() == 0, 'invalid pi');

    let a = FixedTrait::new(HALF_PI_u128, true);
    assert_precise(
        sin(a), -ONE, 'invalid neg half pi', Option::None(())
    ); // 0.9999999999939766

    let a = FixedTrait::new_unscaled(17_u128, false);
    assert_precise(
        sin(a), -17734653485808441000, 'invalid 17', Option::None(())
    ); // -0.9613974918793389

    let a = FixedTrait::new_unscaled(17_u128, true);
    assert_precise(
        sin(a), 17734653485808441000, 'invalid -17', Option::None(())
    ); // 0.9613974918793389
}

#[test]
#[available_gas(100000000)]
fn test_tan() {
    let a = FixedTrait::new(HALF_PI_u128 / 2_u128, false);
    assert(tan(a).into() == ONE, 'invalid quarter pi');

    let a = FixedTrait::new(PI_u128, false);
    assert(tan(a).into() == 0, 'invalid pi');

    let a = FixedTrait::new_unscaled(17_u128, false);
    assert_precise(
        tan(a), 64451367727204090000, 'invalid 17', Option::None(())
    ); // 3.493917677159002

    let a = FixedTrait::new_unscaled(17_u128, true);
    assert_precise(
        tan(a), -64451367727204090000, 'invalid -17', Option::None(())
    ); // -3.493917677159002
}