use debug::PrintTrait;
use integer::{u128_safe_divmod, u128_as_non_zero};
use option::OptionTrait;

use cubit::math::lut;
use cubit::types::fixed::{Fixed, FixedTrait, FixedAdd, FixedSub, FixedMul, FixedDiv, ONE_u128};

// CONSTANTS

const PI_u128: u128 = 57952155664616982739_u128;
const HALF_PI_u128: u128 = 28976077832308491370;

// PUBLIC

// Calculates arccos(a) for -1 <= a <= 1 (fixed point)
// arccos(a) = arcsin(sqrt(1 - a^2)) - arctan identity has discontinuity at zero
fn acos(a: Fixed) -> Fixed {
    assert(a.mag <= ONE_u128, 'out of range');
    let asin_arg = (FixedTrait::one() - a * a).sqrt();
    let asin_res = asin(asin_arg);

    if (a.sign) {
        return FixedTrait::new(PI_u128, false) - asin_res;
    } else {
        return asin_res;
    }
}

fn acos_fast(a: Fixed) -> Fixed {
    assert(a.mag <= ONE_u128, 'out of range');
    let asin_arg = (FixedTrait::one() - a * a).sqrt();
    let asin_res = asin_fast(asin_arg);

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

    let div = (FixedTrait::one() - a * a).sqrt();
    return atan(a / div);
}

fn asin_fast(a: Fixed) -> Fixed {
    assert(a.mag <= ONE_u128, 'out of range');

    if (a.mag == ONE_u128) {
        return FixedTrait::new(HALF_PI_u128, a.sign);
    }

    let div = (FixedTrait::one() - a * a).sqrt();
    return atan_fast(a / div);
}

// Calculates arctan(a) (fixed point)
// See https://stackoverflow.com/a/50894477 for range adjustments
fn atan(a: Fixed) -> Fixed {
    let mut at = a.abs();
    let mut shift = false;
    let mut invert = false;

    // Invert value when a > 1
    if (at.mag > ONE_u128) {
        at = FixedTrait::one() / at;
        invert = true;
    }

    // Account for lack of precision in polynomaial when a > 0.7
    if (at.mag > 12912720851596686131) {
        let sqrt3_3 = FixedTrait::new(10650232656328343401, false); // sqrt(3) / 3
        at = (at - sqrt3_3) / (FixedTrait::one() + at * sqrt3_3);
        shift = true;
    }

    let r10 = FixedTrait::new(33784601907694228, true) * at;
    let r9 = (r10 + FixedTrait::new(863077567022907619, true)) * at;
    let r8 = (r9 + FixedTrait::new(3582351446937658863, false)) * at;
    let r7 = (r8 + FixedTrait::new(4833057334070945981, true)) * at;
    let r6 = (r7 + FixedTrait::new(806366139934153963, false)) * at;
    let r5 = (r6 + FixedTrait::new(3505955710573417812, false)) * at;
    let r4 = (r5 + FixedTrait::new(25330242983263508, false)) * at;
    let r3 = (r4 + FixedTrait::new(6150896368532115927, true)) * at;
    let r2 = (r3 + FixedTrait::new(75835542453775, false)) * at;
    let mut res = (r2 + FixedTrait::new(18446743057812048409, false)) * at;

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = res + FixedTrait::new(9658692610769497123, false); // pi / 6
    }

    if (invert) {
        res = res - FixedTrait::new(HALF_PI_u128, false);
    }

    return FixedTrait::new(res.mag, a.sign);
}

fn atan_fast(a: Fixed) -> Fixed {
    let mut at = a.abs();
    let mut shift = false;
    let mut invert = false;

    // Invert value when a > 1
    if (at.mag > ONE_u128) {
        at = FixedTrait::one() / at;
        invert = true;
    }

    // Account for lack of precision in polynomaial when a > 0.7
    if (at.mag > 12912720851596686131) {
        let sqrt3_3 = FixedTrait::new(10650232656328343401, false); // sqrt(3) / 3
        at = (at - sqrt3_3) / (FixedTrait::one() + at * sqrt3_3);
        shift = true;
    }

    let (start, low, high) = lut::atan(at.mag);
    let partial_step = FixedTrait::new(at.mag - start, false)
        / FixedTrait::new(129127208515966848, false);
    let mut res = partial_step * FixedTrait::new(high - low, false) + FixedTrait::new(low, false);

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = res + FixedTrait::new(9658692610769497123, false); // pi / 6
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

fn cos_fast(a: Fixed) -> Fixed {
    return sin_fast(FixedTrait::new(HALF_PI_u128, false) - a);
}

fn sin(a: Fixed) -> Fixed {
    let a1_u128 = a.mag % (2 * PI_u128);
    let (whole_rem, partial_rem) = u128_safe_divmod(a1_u128, u128_as_non_zero(PI_u128));
    let a2 = FixedTrait::new(partial_rem, false);
    let partial_sign = whole_rem == 1;

    let loop_res = a2 * _sin_loop(a2, 7, FixedTrait::one());
    return FixedTrait::new(loop_res.mag, a.sign ^ partial_sign && loop_res.mag != 0);
}

fn sin_fast(a: Fixed) -> Fixed {
    let a1_u128 = a.mag % (2 * PI_u128);
    let (whole_rem, mut partial_rem) = u128_safe_divmod(a1_u128, u128_as_non_zero(PI_u128));
    let partial_sign = whole_rem == 1;

    if partial_rem >= HALF_PI_u128 {
        partial_rem = PI_u128 - partial_rem;
    }

    let (start, low, high) = lut::sin(partial_rem);
    let partial_step = FixedTrait::new(partial_rem - start, false)
        / FixedTrait::new(113187804032455040, false);
    let res = partial_step * (FixedTrait::new(high, false) - FixedTrait::new(low, false))
        + FixedTrait::new(low, false);

    return FixedTrait::new(res.mag, a.sign ^ partial_sign && res.mag != 0);
}

// Calculates tan(a) with a in radians (fixed point)
fn tan(a: Fixed) -> Fixed {
    let sinx = sin(a);
    let cosx = cos(a);
    assert(cosx.mag != 0, 'tan undefined');
    return sinx / cosx;
}

fn tan_fast(a: Fixed) -> Fixed {
    let sinx = sin_fast(a);
    let cosx = cos_fast(a);
    assert(cosx.mag != 0, 'tan undefined');
    return sinx / cosx;
}

// Helper function to calculate Taylor series for sin
fn _sin_loop(a: Fixed, i: u128, acc: Fixed) -> Fixed {
    let div_u128 = (2 * i + 2) * (2 * i + 3);
    let term = a * a * acc / FixedTrait::new_unscaled(div_u128, false);
    let new_acc = FixedTrait::one() - term;

    if (i == 0) {
        return new_acc;
    }

    return _sin_loop(a, i - 1, new_acc);
}

// Tests
// --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use traits::Into;

    use cubit::test::helpers::{assert_precise, assert_relative};
    use cubit::types::fixed::{ONE, FixedInto, FixedPartialEq, FixedPrint};

    use super::{FixedTrait};

    #[test]
    #[available_gas(3000000)]
    fn test_acos() {
        let a = FixedTrait::one();
        assert(acos(a).into() == 0, 'invalid one');

        let a = FixedTrait::new(ONE_u128 / 2, false);
        assert(acos(a).into() == 19317385211018935530, 'invalid half'); // 1.0471975506263043

        let a = FixedTrait::zero();
        assert(acos(a).into() == 28976077832308491370, 'invalid zero'); // PI / 2

        let a = FixedTrait::new(ONE_u128 / 2, true);
        assert(acos(a).into() == 38634770453598047209, 'invalid neg half'); // 2.094395102963489

        let a = FixedTrait::new(ONE_u128, true);
        assert(acos(a).into() == 57952155664616982739, 'invalid neg one'); // PI
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000)]
    fn test_acos_fail() {
        let a = FixedTrait::new(2 * ONE_u128, true);
        acos(a);
    }

    #[test]
    #[available_gas(1400000)]
    fn test_atan_fast() {
        let error = Option::Some(184467440737095);

        let a = FixedTrait::new(2 * ONE_u128, false);
        assert_relative(atan_fast(a), 20423289048683266000, 'invalid two', error);

        let a = FixedTrait::one();
        assert_relative(atan_fast(a), 14488038916154245000, 'invalid one', error);

        let a = FixedTrait::new(ONE_u128 / 2, false);
        assert_relative(atan_fast(a), 8552788783625223000, 'invalid half', error);

        let a = FixedTrait::zero();
        assert(atan_fast(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE_u128 / 2, true);
        assert_relative(atan_fast(a), -8552788783625223000, 'invalid neg half', error);

        let a = FixedTrait::new(ONE_u128, true);
        assert_relative(atan_fast(a), -14488038916154245000, 'invalid neg one', error);

        let a = FixedTrait::new(2 * ONE_u128, true);
        assert_relative(atan_fast(a), -20423289048683266000, 'invalid neg two', error);
    }

    #[test]
    #[available_gas(2600000)]
    fn test_atan() {
        let a = FixedTrait::new(2 * ONE_u128, false);
        assert_relative(atan(a), 20423289048683266000, 'invalid two', Option::None(()));

        let a = FixedTrait::one();
        assert_relative(atan(a), 14488038916154245000, 'invalid one', Option::None(()));

        let a = FixedTrait::new(ONE_u128 / 2, false);
        assert_relative(atan(a), 8552788783625223000, 'invalid half', Option::None(()));

        let a = FixedTrait::zero();
        assert(atan(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE_u128 / 2, true);
        assert_relative(atan(a), -8552788783625223000, 'invalid neg half', Option::None(()));

        let a = FixedTrait::new(ONE_u128, true);
        assert_relative(atan(a), -14488038916154245000, 'invalid neg one', Option::None(()));

        let a = FixedTrait::new(2 * ONE_u128, true);
        assert_relative(atan(a), -20423289048683266000, 'invalid neg two', Option::None(()));
    }

    #[test]
    #[available_gas(3000000)]
    fn test_asin() {
        let a = FixedTrait::one();
        assert(asin(a).into() == 28976077832308491370, 'invalid one'); // PI / 2

        let a = FixedTrait::new(ONE_u128 / 2, false);
        assert(asin(a).into() == 9658692617570005102, 'invalid half');

        let a = FixedTrait::zero();
        assert(asin(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE_u128 / 2, true);
        assert(asin(a).into() == -9658692617570005102, 'invalid neg half');

        let a = FixedTrait::new(ONE_u128, true);
        assert(asin(a).into() == -28976077832308491370, 'invalid neg one'); // -PI / 2
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000)]
    fn test_asin_fail() {
        let a = FixedTrait::new(2 * ONE_u128, false);
        asin(a);
    }

    #[test]
    #[available_gas(6000000)]
    fn test_cos() {
        let a = FixedTrait::new(HALF_PI_u128, false);
        assert(cos(a).into() == 0, 'invalid half pi');

        let a = FixedTrait::new(HALF_PI_u128 / 2, false);
        assert_precise(
            cos(a), 13043817825332783000, 'invalid quarter pi', Option::None(()),
        ); // 0.7071067811865475

        let a = FixedTrait::new(PI_u128, false);
        assert_precise(cos(a), -18446744073709552000, 'invalid pi', Option::None(()));

        let a = FixedTrait::new(HALF_PI_u128, true);
        assert(cos(a).into() == -1, 'invalid neg half pi'); // -0.000...

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(
            cos(a), -5075867675505434000, 'invalid 17', Option::None(()),
        ); // -0.2751631780463348

        let a = FixedTrait::new_unscaled(17, true);
        assert_precise(
            cos(a), -5075867675505434000, 'invalid -17', Option::None(()),
        ); // -0.2751631780463348
    }

    #[test]
    #[available_gas(6000000)]
    fn test_cos_fast() {
        let error = Option::Some(184467440737095);

        let a = FixedTrait::new(HALF_PI_u128, false);
        assert(cos_fast(a).into() == 0, 'invalid half pi');

        let a = FixedTrait::new(HALF_PI_u128 / 2, false);
        assert_precise(
            cos_fast(a), 13043817825332783000, 'invalid quarter pi', error,
        ); // 0.7071067811865475

        let a = FixedTrait::new(PI_u128, false);
        assert_precise(cos_fast(a), -18446744073709552000, 'invalid pi', error);

        let a = FixedTrait::new(HALF_PI_u128, true);
        assert(cos_fast(a).into() == 0, 'invalid neg half pi');

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(
            cos_fast(a), -5075867675505434000, 'invalid 17', error,
        ); // -0.2751631780463348

        let a = FixedTrait::new(22091482235073817558142, true);
        assert_precise(cos_fast(a), -14852585959099408000, 'invalid theta', error);
    }

    #[test]
    #[available_gas(6000000)]
    fn test_sin() {
        let a = FixedTrait::new(HALF_PI_u128, false);
        assert_precise(sin(a), ONE, 'invalid half pi', Option::None(()));

        let a = FixedTrait::new(HALF_PI_u128 / 2, false);
        assert_precise(
            sin(a), 13043817825332781000, 'invalid quarter pi', Option::None(()),
        ); // 0.7071067811865475

        let a = FixedTrait::new(PI_u128, false);
        assert(sin(a).into() == 0, 'invalid pi');

        let a = FixedTrait::new(HALF_PI_u128, true);
        assert_precise(sin(a), -ONE, 'invalid neg half pi', Option::None(())); // 0.9999999999939766

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(
            sin(a), -17734653485808441000, 'invalid 17', Option::None(()),
        ); // -0.9613974918793389

        let a = FixedTrait::new_unscaled(17, true);
        assert_precise(
            sin(a), 17734653485808441000, 'invalid -17', Option::None(()),
        ); // 0.9613974918793389
    }

    #[test]
    #[available_gas(1000000)]
    fn test_sin_fast() {
        let error = Option::Some(184467440737095);

        let a = FixedTrait::new(HALF_PI_u128, false);
        assert_precise(sin_fast(a), ONE, 'invalid half pi', error);

        let a = FixedTrait::new(HALF_PI_u128 / 2, false);
        assert_precise(
            sin_fast(a), 13043817825332781000, 'invalid quarter pi', error,
        ); // 0.7071067811865475

        let a = FixedTrait::new(PI_u128, false);
        assert(sin_fast(a).into() == 0, 'invalid pi');

        let a = FixedTrait::new(HALF_PI_u128, true);
        assert_precise(sin_fast(a), -ONE, 'invalid neg half pi', error); // 0.9999999999939766

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(
            sin_fast(a), -17734653485808441000, 'invalid 17', error,
        ); // -0.9613974918793389

        let a = FixedTrait::new_unscaled(17, true);
        assert_precise(
            sin_fast(a), 17734653485808441000, 'invalid -17', error,
        ); // 0.9613974918793389
    }

    #[test]
    #[available_gas(8000000)]
    fn test_tan() {
        let a = FixedTrait::new(HALF_PI_u128 / 2, false);
        assert(tan(a).into() == ONE, 'invalid quarter pi');

        let a = FixedTrait::new(PI_u128, false);
        assert(tan(a).into() == 0, 'invalid pi');

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(
            tan(a), 64451367727204090000, 'invalid 17', Option::None(()),
        ); // 3.493917677159002

        let a = FixedTrait::new_unscaled(17, true);
        assert_precise(
            tan(a), -64451367727204090000, 'invalid -17', Option::None(()),
        ); // -3.493917677159002
    }
}
