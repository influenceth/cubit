use core::debug::PrintTrait;
use core::integer::{u64_safe_divmod, u64_as_non_zero};
use core::option::OptionTrait;

use cubit::f64::math::lut;
use cubit::f64::types::fixed::{Fixed, FixedTrait, FixedAdd, FixedSub, FixedMul, FixedDiv, ONE};

// CONSTANTS

const TWO_PI: u64 = 26986075409;
const PI: u64 = 13493037705;
const HALF_PI: u64 = 6746518852;

// PUBLIC

// Calculates arccos(a) for -1 <= a <= 1 (fixed point)
// arccos(a) = arcsin(sqrt(1 - a^2)) - arctan identity has discontinuity at zero
fn acos(a: Fixed) -> Fixed {
    let asin_arg = (FixedTrait::ONE() - a * a).sqrt(); // will fail if a > 1
    let asin_res = asin(asin_arg);

    if (a.sign) {
        return FixedTrait::new(PI, false) - asin_res;
    } else {
        return asin_res;
    }
}

fn acos_fast(a: Fixed) -> Fixed {
    let asin_arg = (FixedTrait::ONE() - a * a).sqrt(); // will fail if a > 1
    let asin_res = asin_fast(asin_arg);

    if (a.sign) {
        return FixedTrait::new(PI, false) - asin_res;
    } else {
        return asin_res;
    }
}

// Calculates arcsin(a) for -1 <= a <= 1 (fixed point)
// arcsin(a) = arctan(a / sqrt(1 - a^2))
fn asin(a: Fixed) -> Fixed {
    if (a.mag == ONE) {
        return FixedTrait::new(HALF_PI, a.sign);
    }

    let div = (FixedTrait::ONE() - a * a).sqrt(); // will fail if a > 1
    return atan(a / div);
}

fn asin_fast(a: Fixed) -> Fixed {
    if (a.mag == ONE) {
        return FixedTrait::new(HALF_PI, a.sign);
    }

    let div = (FixedTrait::ONE() - a * a).sqrt(); // will fail if a > 1
    return atan_fast(a / div);
}

// Calculates arctan(a) (fixed point)
// See https://stackoverflow.com/a/50894477 for range adjustments
fn atan(a: Fixed) -> Fixed {
    let mut at = a.abs();
    let mut shift = false;
    let mut invert = false;

    // Invert value when a > 1
    if (at.mag > ONE) {
        at = FixedTrait::ONE() / at;
        invert = true;
    }

    // Account for lack of precision in polynomaial when a > 0.7
    if (at.mag > 3006477107) {
        let sqrt3_3 = FixedTrait::new(2479700525, false); // sqrt(3) / 3
        at = (at - sqrt3_3) / (FixedTrait::ONE() + at * sqrt3_3);
        shift = true;
    }

    let r10 = FixedTrait::new(7866091, true) * at;
    let r9 = (r10 + FixedTrait::new(200950905, true)) * at;
    let r8 = (r9 + FixedTrait::new(834081193, false)) * at;
    let r7 = (r8 + FixedTrait::new(1125283850, true)) * at;
    let r6 = (r7 + FixedTrait::new(187746747, false)) * at;
    let r5 = (r6 + FixedTrait::new(816293925, false)) * at;
    let r4 = (r5 + FixedTrait::new(5897657, false)) * at;
    let r3 = (r4 + FixedTrait::new(1432117161, true)) * at;
    let r2 = (r3 + FixedTrait::new(17657, false)) * at;
    let mut res = (r2 + FixedTrait::new(4294967059, false)) * at;

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = res + FixedTrait::new(2248839617, false); // pi / 6
    }

    if (invert) {
        res = res - FixedTrait::new(HALF_PI, false);
    }

    return FixedTrait::new(res.mag, a.sign);
}

fn atan_fast(a: Fixed) -> Fixed {
    let mut at = a.abs();
    let mut shift = false;
    let mut invert = false;

    // Invert value when a > 1
    if (at.mag > ONE) {
        at = FixedTrait::ONE() / at;
        invert = true;
    }

    // Account for lack of precision in polynomaial when a > 0.7
    if (at.mag > 3006477107) {
        let sqrt3_3 = FixedTrait::new(2479700525, false); // sqrt(3) / 3
        at = (at - sqrt3_3) / (FixedTrait::ONE() + at * sqrt3_3);
        shift = true;
    }

    let (start, low, high) = lut::atan(at.mag);
    let partial_step = FixedTrait::new(at.mag - start, false) / FixedTrait::new(30064771, false);
    let mut res = partial_step * FixedTrait::new(high - low, false) + FixedTrait::new(low, false);

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = res + FixedTrait::new(2248839617, false); // pi / 6
    }

    if (invert) {
        res = res - FixedTrait::new(HALF_PI, false);
    }

    return FixedTrait::new(res.mag, a.sign);
}

// Calculates cos(a) with a in radians (fixed point)
fn cos(a: Fixed) -> Fixed {
    return sin(FixedTrait::new(HALF_PI, false) - a);
}

fn cos_fast(a: Fixed) -> Fixed {
    return sin_fast(FixedTrait::new(HALF_PI, false) - a);
}

fn sin(a: Fixed) -> Fixed {
    let a1 = a.mag % TWO_PI;
    let (whole_rem, partial_rem) = u64_safe_divmod(a1, u64_as_non_zero(PI));
    let a2 = FixedTrait::new(partial_rem, false);
    let partial_sign = whole_rem == 1;

    let loop_res = a2 * _sin_loop(a2, 7, FixedTrait::ONE());
    return FixedTrait::new(loop_res.mag, a.sign ^ partial_sign && loop_res.mag != 0);
}

fn sin_fast(a: Fixed) -> Fixed {
    let a1 = a.mag % TWO_PI;
    let (whole_rem, mut partial_rem) = u64_safe_divmod(a1, u64_as_non_zero(PI));
    let partial_sign = whole_rem == 1;

    if partial_rem >= HALF_PI {
        partial_rem = PI - partial_rem;
    }

    let (start, low, high) = lut::sin(partial_rem);
    let partial_step = (FixedTrait::new(partial_rem, false) - FixedTrait::new(start, false))
        / FixedTrait::new(26353589, false);
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
fn _sin_loop(a: Fixed, i: u64, acc: Fixed) -> Fixed {
    let div = (2 * i + 2) * (2 * i + 3);
    let term = a * a * acc / FixedTrait::new_unscaled(div, false);
    let new_acc = FixedTrait::ONE() - term;

    if (i == 0) {
        return new_acc;
    }

    return _sin_loop(a, i - 1, new_acc);
}

// Tests
// --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use core::traits::Into;

    use cubit::f64::test::helpers::{assert_precise, assert_relative};
    use cubit::f64::types::fixed::{FixedPartialEq, FixedPrint};

    use super::{
        FixedTrait, acos, ONE, HALF_PI, PI, acos_fast, atan_fast, atan, asin, cos, cos_fast, sin,
        sin_fast, tan,
    };

    #[test]
    #[available_gas(3000000)]
    fn test_acos() {
        let error = Option::Some(42950); // 1e-5

        let a = FixedTrait::ONE();
        assert(acos(a).into() == 0, 'invalid one');

        let a = FixedTrait::new(ONE / 2, false);
        assert_relative(acos(a), 4497679235, 'invalid half', error); // 1.0471975506263043

        let a = FixedTrait::ZERO();
        assert_relative(acos(a), HALF_PI.into(), 'invalid zero', Option::None(())); // PI / 2

        let a = FixedTrait::new(ONE / 2, true);
        assert_relative(acos(a), 8995358470, 'invalid neg half', error); // 2.094395102963489

        let a = FixedTrait::new(ONE, true);
        assert_relative(acos(a), PI.into(), 'invalid neg one', Option::None(())); // PI
    }

    #[test]
    #[available_gas(3000000)]
    fn test_acos_fast() {
        let error = Option::Some(42950); // 1e-5

        let a = FixedTrait::ONE();
        assert(acos_fast(a).into() == 0, 'invalid one');

        let a = FixedTrait::new(ONE / 2, false);
        assert_relative(acos_fast(a), 4497679235, 'invalid half', error); // 1.0471975506263043

        let a = FixedTrait::ZERO();
        assert_relative(acos_fast(a), HALF_PI.into(), 'invalid zero', Option::None(())); // PI / 2

        let a = FixedTrait::new(ONE / 2, true);
        assert_relative(acos_fast(a), 8995358470, 'invalid neg half', error); // 2.094395102963489

        let a = FixedTrait::new(ONE, true);
        assert_relative(acos_fast(a), PI.into(), 'invalid neg one', Option::None(())); // PI
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000)]
    fn test_acos_fail() {
        let a = FixedTrait::new(2 * ONE, true);
        acos(a);
    }

    #[test]
    #[available_gas(1400000)]
    fn test_atan_fast() {
        let error = Option::Some(42950); // 1e-5

        let a = FixedTrait::new(2 * ONE, false);
        assert_relative(atan_fast(a), 4755167535, 'invalid two', error);

        let a = FixedTrait::ONE();
        assert_relative(atan_fast(a), 3373259426, 'invalid one', error);

        let a = FixedTrait::new(ONE / 2, false);
        assert_relative(atan_fast(a), 1991351318, 'invalid half', error);

        let a = FixedTrait::ZERO();
        assert(atan_fast(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE / 2, true);
        assert_relative(atan_fast(a), -1991351318, 'invalid neg half', error);

        let a = FixedTrait::new(ONE, true);
        assert_relative(atan_fast(a), -3373259426, 'invalid neg one', error);

        let a = FixedTrait::new(2 * ONE, true);
        assert_relative(atan_fast(a), -4755167535, 'invalid neg two', error);
    }

    #[test]
    #[available_gas(2600000)]
    fn test_atan() {
        let a = FixedTrait::new(2 * ONE, false);
        assert_relative(atan(a), 4755167535, 'invalid two', Option::None(()));

        let a = FixedTrait::ONE();
        assert_relative(atan(a), 3373259426, 'invalid one', Option::None(()));

        let a = FixedTrait::new(ONE / 2, false);
        assert_relative(atan(a), 1991351318, 'invalid half', Option::None(()));

        let a = FixedTrait::ZERO();
        assert(atan(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE / 2, true);
        assert_relative(atan(a), -1991351318, 'invalid neg half', Option::None(()));

        let a = FixedTrait::new(ONE, true);
        assert_relative(atan(a), -3373259426, 'invalid neg one', Option::None(()));

        let a = FixedTrait::new(2 * ONE, true);
        assert_relative(atan(a), -4755167535, 'invalid neg two', Option::None(()));
    }

    #[test]
    #[available_gas(3000000)]
    fn test_asin() {
        let error = Option::Some(42950); // 1e-5

        let a = FixedTrait::ONE();
        assert_relative(asin(a), HALF_PI.into(), 'invalid one', Option::None(())); // PI / 2

        let a = FixedTrait::new(ONE / 2, false);
        assert_relative(asin(a), 2248839617, 'invalid half', error);

        let a = FixedTrait::ZERO();
        assert_precise(asin(a), 0, 'invalid zero', Option::None(()));

        let a = FixedTrait::new(ONE / 2, true);
        assert_relative(asin(a), -2248839617, 'invalid neg half', error);

        let a = FixedTrait::new(ONE, true);
        assert_relative(asin(a), -HALF_PI.into(), 'invalid neg one', Option::None(())); // -PI / 2
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000)]
    fn test_asin_fail() {
        let a = FixedTrait::new(2 * ONE, false);
        asin(a);
    }

    #[test]
    #[available_gas(6000000)]
    fn test_cos() {
        let a = FixedTrait::new(HALF_PI, false);
        assert(cos(a).into() == 0, 'invalid half pi');

        let a = FixedTrait::new(HALF_PI / 2, false);
        assert_relative(
            cos(a), 3037000500, 'invalid quarter pi', Option::None(()),
        ); // 0.7071067811865475

        let a = FixedTrait::new(PI, false);
        assert_relative(cos(a), -1 * ONE.into(), 'invalid pi', Option::None(()));

        let a = FixedTrait::new(HALF_PI, true);
        assert_precise(cos(a), 0, 'invalid neg half pi', Option::None(()));

        let a = FixedTrait::new_unscaled(17, false);
        assert_relative(cos(a), -1181817538, 'invalid 17', Option::None(())); // -0.2751631780463348

        let a = FixedTrait::new_unscaled(17, true);
        assert_relative(
            cos(a), -1181817538, 'invalid -17', Option::None(()),
        ); // -0.2751631780463348
    }

    #[test]
    #[available_gas(6000000)]
    fn test_cos_fast() {
        let error = Option::Some(42950); // 1e-5

        let a = FixedTrait::new(HALF_PI, false);
        assert(cos_fast(a).into() == 0, 'invalid half pi');

        let a = FixedTrait::new(HALF_PI / 2, false);
        assert_precise(cos_fast(a), 3037000500, 'invalid quarter pi', error); // 0.7071067811865475

        let a = FixedTrait::new(PI, false);
        assert_precise(cos_fast(a), -1 * ONE.into(), 'invalid pi', error);

        let a = FixedTrait::new(HALF_PI, true);
        assert_precise(cos(a), 0, 'invalid neg half pi', Option::None(()));

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(cos_fast(a), -1181817538, 'invalid 17', error); // -0.2751631780463348

        let a = FixedTrait::new(5143574028060, true);
        assert_precise(cos_fast(a), -3458137149, 'invalid theta', error);
    }

    #[test]
    #[available_gas(6000000)]
    fn test_sin() {
        let a = FixedTrait::new(HALF_PI, false);
        assert_precise(sin(a), ONE.into(), 'invalid half pi', Option::None(()));

        let a = FixedTrait::new(HALF_PI / 2, false);
        assert_precise(
            sin(a), 3037000500, 'invalid quarter pi', Option::None(()),
        ); // 0.7071067811865475

        let a = FixedTrait::new(PI, false);
        assert(sin(a).into() == 0, 'invalid pi');

        let a = FixedTrait::new(HALF_PI, true);
        assert_precise(
            sin(a), -ONE.into(), 'invalid neg half pi', Option::None(()),
        ); // 0.9999999999939766

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(sin(a), -4129170786, 'invalid 17', Option::None(())); // -0.9613974918793389

        let a = FixedTrait::new_unscaled(17, true);
        assert_precise(sin(a), 4129170786, 'invalid -17', Option::None(())); // 0.9613974918793389
    }

    #[test]
    #[available_gas(1000000)]
    fn test_sin_fast() {
        let error = Option::Some(42950); // 1e-5

        let a = FixedTrait::new(HALF_PI, false);
        assert_precise(sin_fast(a), ONE.into(), 'invalid half pi', error);

        let a = FixedTrait::new(HALF_PI / 2, false);
        assert_precise(sin_fast(a), 3037000500, 'invalid quarter pi', error); // 0.7071067811865475

        let a = FixedTrait::new(PI, false);
        assert(sin_fast(a).into() == 0, 'invalid pi');

        let a = FixedTrait::new(HALF_PI, true);
        assert_precise(
            sin_fast(a), -ONE.into(), 'invalid neg half pi', error,
        ); // 0.9999999999939766

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(sin_fast(a), -4129170786, 'invalid 17', error); // -0.9613974918793389

        let a = FixedTrait::new_unscaled(17, true);
        assert_precise(sin_fast(a), 4129170786, 'invalid -17', error); // 0.9613974918793389
    }

    #[test]
    #[available_gas(9_000_000_000)]
    fn test_compare_sin() {
        let error = Option::Some(42950); // 1e-5

        let MAX: u64 = 256 * 4;
        let mut n: u64 = 0;
        loop {
            if n == MAX {
                break;
            }
            let a = FixedTrait::new(n * 26353589 * 256 / MAX + 1, false);
            let sin1 = sin_fast(a);
            let sin2 = sin(a);

            assert_precise(sin1, sin2.mag.into(), 'invalid sin', error);

            n += 1;
        }
    }

    #[test]
    #[available_gas(8000000)]
    fn test_tan() {
        let a = FixedTrait::new(HALF_PI / 2, false);
        assert_precise(tan(a), ONE.into(), 'invalid quarter pi', Option::None(()));

        let a = FixedTrait::new(PI, false);
        assert_precise(tan(a), 0, 'invalid pi', Option::None(()));

        let a = FixedTrait::new_unscaled(17, false);
        assert_precise(tan(a), 15006253432, 'invalid 17', Option::None(())); // 3.493917677159002

        let a = FixedTrait::new_unscaled(17, true);
        assert_precise(tan(a), -15006253432, 'invalid -17', Option::None(())); // -3.493917677159002
    }
}
