use option::OptionTrait;
use result::{ResultTrait, ResultTraitImpl};
use traits::{Into, TryInto};
use integer::{u256_safe_divmod, u256_as_non_zero, u256_from_felt252, upcast};

use cubit::types::fixed::{
  HALF_u128,
  MAX_u128,
  ONE_u128,
  Fixed,
  FixedInto,
  FixedTrait,
  FixedAdd,
  FixedDiv,
  FixedMul,
  FixedNeg
};

// PUBLIC

fn abs(a: Fixed) -> Fixed {
    return FixedTrait::new(a.mag, false);
}

fn add(a: Fixed, b: Fixed) -> Fixed {
    return FixedTrait::from_felt(a.into() + b.into());
}

fn ceil(a: Fixed) -> Fixed {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if (rem_u128 == 0_u128) {
        return a;
    } else if (a.sign == false) {
        return FixedTrait::new_unscaled(div_u128 + 1_u128, false);
    } else {
        return FixedTrait::from_unscaled_felt(div_u128.into() * -1);
    }
}

fn div(a: Fixed, b: Fixed) -> Fixed {
    let res_sign = a.sign ^ b.sign;
    let (a_high, a_low) = integer::u128_wide_mul(a.mag, ONE_u128);
    let a_u256 = u256 { low: a_low, high: a_high };
    let b_u256 = u256 { low: b.mag, high: 0_u128 };
    let res_u256 = a_u256 / b_u256;

    assert(res_u256.high == 0_u128, 'result overflow');

    // Re-apply sign
    return FixedTrait::new(res_u256.low, res_sign);
}

fn eq(a: Fixed, b: Fixed) -> bool {
    return a.mag == b.mag & a.sign == b.sign;
}

// Calculates the natural exponent of x: e^x
fn exp(a: Fixed) -> Fixed {
    return exp2(FixedTrait::new(26613026195688644984_u128, false) * a);
}

// Calculates the binary exponent of x: 2^x
fn exp2(a: Fixed) -> Fixed {
    if (a.mag == 0_u128) {
        return FixedTrait::new(ONE_u128, false);
    }

    let (int_part, frac_part) = _split_unsigned(a);
    let int_res = _pow_int(FixedTrait::new_unscaled(2_u128, false), int_part, false);

    let t8 = FixedTrait::new(41691949755436_u128, false);
    let t7 = FixedTrait::new(231817862090993_u128, false);
    let t6 = FixedTrait::new(2911875592466782_u128, false);
    let t5 = FixedTrait::new(24539637786416367_u128, false);
    let t4 = FixedTrait::new(177449490038807528_u128, false);
    let t3 = FixedTrait::new(1023863119786103800_u128, false);
    let t2 = FixedTrait::new(4431397849999009866_u128, false);
    let t1 = FixedTrait::new(12786308590235521577_u128, false);

    let frac_fixed = FixedTrait::new(frac_part, false);
    let r8 = t8 * frac_fixed;
    let r7 = (r8 + t7) * frac_fixed;
    let r6 = (r7 + t6) * frac_fixed;
    let r5 = (r6 + t5) * frac_fixed;
    let r4 = (r5 + t4) * frac_fixed;
    let r3 = (r4 + t3) * frac_fixed;
    let r2 = (r3 + t2) * frac_fixed;
    let r1 = (r2 + t1) * frac_fixed;
    let frac_res = r1 + FixedTrait::new(ONE_u128, false);
    let res_u = int_res * frac_res;

    if (a.sign == true) {
        return FixedTrait::new(ONE_u128, false) / res_u;
    } else {
        return res_u;
    }
}

fn floor(a: Fixed) -> Fixed {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if (rem_u128 == 0_u128) {
        return a;
    } else if (a.sign == false) {
        return FixedTrait::new_unscaled(div_u128, false);
    } else {
        return FixedTrait::from_unscaled_felt(-1 * div_u128.into() - 1);
    }
}

fn ge(a: Fixed, b: Fixed) -> bool {
    if (a.sign != b.sign) {
        return !a.sign;
    } else {
        return (a.mag == b.mag) | ((a.mag > b.mag) ^ a.sign);
    }
}

fn gt(a: Fixed, b: Fixed) -> bool {
    if (a.sign != b.sign) {
        return !a.sign;
    } else {
        return (a.mag != b.mag) & ((a.mag > b.mag) ^ a.sign);
    }
}

fn le(a: Fixed, b: Fixed) -> bool {
    if (a.sign != b.sign) {
        return a.sign;
    } else {
        return (a.mag == b.mag) | ((a.mag < b.mag) ^ a.sign);
    }
}

// Calculates the natural logarithm of x: ln(x)
// self must be greater than zero
fn ln(a: Fixed) -> Fixed {
    return FixedTrait::new(12786308645202655660_u128, false) * log2(a); // ln(2) = 0.693...
}

// Calculates the binary logarithm of x: log2(x)
// self must be greather than zero
fn log2(a: Fixed) -> Fixed {
    assert(a.sign == false, 'must be positive');

    if (a.mag == ONE_u128) {
        return FixedTrait::new(0_u128, false);
    } else if (a.mag < ONE_u128) {
        // Compute true inverse binary log if 0 < x < 1
        let div = FixedTrait::new_unscaled(1_u128, false) / a;
        return -log2(div);
    }

    let msb_u128 = _msb(a.mag / 2_u128);
    let divisor = _pow_int(FixedTrait::new_unscaled(2_u128, false), msb_u128, false);
    let norm = a / divisor;

    let t8 = FixedTrait::new(167660832607149504_u128, true);
    let t7 = FixedTrait::new(2284550827067371376_u128, false);
    let t6 = FixedTrait::new(13804762162529339368_u128, true);
    let t5 = FixedTrait::new(48676798788932142400_u128, false);
    let t4 = FixedTrait::new(110928274989790216568_u128, true);
    let t3 = FixedTrait::new(171296190111888966192_u128, false);
    let t2 = FixedTrait::new(184599081115266689944_u128, true);
    let t1 = FixedTrait::new(150429590981271126408_u128, false);
    let t0 = FixedTrait::new(63187350828072553424_u128, true);

    let r8 = t8 * norm;
    let r7 = (r8 + t7) * norm;
    let r6 = (r7 + t6) * norm;
    let r5 = (r6 + t5) * norm;
    let r4 = (r5 + t4) * norm;
    let r3 = (r4 + t3) * norm;
    let r2 = (r3 + t2) * norm;
    let r1 = (r2 + t1) * norm;
    return r1 + t0 + FixedTrait::new_unscaled(msb_u128, false);
}

// Calculates the base 10 log of x: log10(x)
// self must be greater than zero
fn log10(a: Fixed) -> Fixed {
    return FixedTrait::new(5553023288523357132_u128, false) * log2(a); // log10(2) = 0.301...
}

fn lt(a: Fixed, b: Fixed) -> bool {
    if (a.sign != b.sign) {
        return a.sign;
    } else {
        return (a.mag != b.mag) & ((a.mag < b.mag) ^ a.sign);
    }
}

fn mul(a: Fixed, b: Fixed) -> Fixed {
    let res_sign = a.sign ^ b.sign;
    let (high, low) = integer::u128_wide_mul(a.mag, b.mag);
    let res_u256 = u256 { low: low, high: high };
    let ONE_u256 = u256 { low: ONE_u128, high: 0_u128 };
    let (scaled_u256, _) = u256_safe_divmod(res_u256, u256_as_non_zero(ONE_u256));

    assert(scaled_u256.high == 0_u128, 'result overflow');

    // Re-apply sign
    return FixedTrait::new(scaled_u256.low, res_sign);
}

fn ne(a: Fixed, b: Fixed) -> bool {
    return a.mag != b.mag | a.sign != b.sign;
}

fn neg(a: Fixed) -> Fixed {
    if (a.sign == false) {
        return FixedTrait::new(a.mag, true);
    } else {
        return FixedTrait::new(a.mag, false);
    }
}

// Calclates the value of x^y and checks for overflow before returning
// self is a fixed point value
// b is a fixed point value
fn pow(a: Fixed, b: Fixed) -> Fixed {
    let (div_u128, rem_u128) = _split_unsigned(b);

    // use the more performant integer pow when y is an int
    if (rem_u128 == 0_u128) {
        return _pow_int(a, b.mag / ONE_u128, b.sign);
    }

    // x^y = exp(y*ln(x)) for x > 0 will error for x < 0
    return exp(b * ln(a));
}

fn rem(a: Fixed, b: Fixed) -> Fixed {
    return a - floor(a / b) * b;
}

fn round(a: Fixed) -> Fixed {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if (HALF_u128 <= rem_u128) {
        return FixedTrait::new(ONE_u128 * (div_u128 + 1_u128), a.sign);
    } else {
        return FixedTrait::new(ONE_u128 * div_u128, a.sign);
    }
}

// Calculates the square root of a fixed point value
// x must be positive
fn sqrt(a: Fixed) -> Fixed {
    assert(a.sign == false, 'must be positive');
    let root = integer::u128_sqrt(a.mag);
    let scale_root = integer::u128_sqrt(ONE_u128);
    let res_u128 = upcast(root) * ONE_u128 / upcast(scale_root);
    return FixedTrait::new(res_u128, false);
}

fn sub(a: Fixed, b: Fixed) -> Fixed {
    return FixedTrait::from_felt(a.into() - b.into());
}

// INTERNAL

// Calculates the most significant bit
fn _msb(a: u128) -> u128 {
    if (a <= ONE_u128) { return 0_u128; }
    return 1_u128 + _msb(a / 2_u128);
}

// Calclates the value of x^y and checks for overflow before returning
// TODO: swap to signed int when available
fn _pow_int(a: Fixed, b: u128, sign: bool) -> Fixed {
    if (sign == true) {
        return FixedTrait::new(ONE_u128, false) / _pow_int(a, b, false);
    }

    let (div, rem) = integer::u128_safe_divmod(b, integer::u128_as_non_zero(2_u128));

    if (b == 0_u128) {
        return FixedTrait::new(ONE_u128, false);
    } else if (rem == 0_u128) {
        return _pow_int(a * a, div, false);
    } else {
        return a * _pow_int(a * a, div, false);
    }
}

// Ignores sign and always returns false
fn _split_unsigned(a: Fixed) -> (u128, u128) {
    return integer::u128_safe_divmod(a.mag, integer::u128_as_non_zero(ONE_u128));
}

// Tests --------------------------------------------------------------------------------------------------------------

use cubit::test::helpers::assert_precise;
use cubit::types::fixed::{
  ONE,
  HALF,
  _felt_abs,
  _felt_sign,
  FixedPartialEq,
  FixedPartialOrd,
  FixedAddEq,
  FixedSub,
  FixedSubEq,
  FixedMulEq
};

use cubit::math::trig::HALF_PI_u128;
use cubit::math::trig::PI_u128;

#[test]
fn test_into() {
    let a = FixedTrait::from_unscaled_felt(5);
    assert(a.into() == 5 * ONE, 'invalid result');
}

#[test]
fn test_try_into_u128() {
    // Positive unscaled
    let a = FixedTrait::new_unscaled(5_u128, false);
    assert(a.try_into().unwrap() == 5, 'invalid result');

    // Positive scaled
    let b = FixedTrait::new(5_u128 * ONE_u128, false);
    assert(b.try_into().unwrap() == 5, 'invalid result');

    let c = FixedTrait::new(PI_u128, false);
    assert(c.try_into().unwrap() == 3, 'invalid result');

    // Zero
    let d = FixedTrait::new_unscaled(0_u128, false);
    assert(d.try_into().unwrap() == 0_u128, 'invalid result');
}

#[test]
#[should_panic]
fn test_negative_try_into_u128() {
    let a = FixedTrait::new_unscaled(1_u128, true);
    let a: u128 = a.try_into().unwrap();
}

#[test]
#[should_panic]
fn test_overflow_large() {
    let too_large = 0x100000000000000000000000000000000;
    FixedTrait::from_felt(too_large);
}

#[test]
#[should_panic]
fn test_overflow_small() {
    let too_small = -0x100000000000000000000000000000000;
    FixedTrait::from_felt(too_small);
}

#[test]
fn test_sign() {
    let min = -1809251394333065606848661391547535052811553607665798349986546028067936010240;
    let max = 1809251394333065606848661391547535052811553607665798349986546028067936010240;
    assert(_felt_sign(min) == true, 'invalid result');
    assert(_felt_sign(-1) == true, 'invalid result');
    assert(_felt_sign(0) == false, 'invalid result');
    assert(_felt_sign(1) == false, 'invalid result');
    assert(_felt_sign(max) == false, 'invalid result');
}

#[test]
fn test_abs() {
    assert(_felt_abs(5) == 5, 'abs of pos should be pos');
    assert(_felt_abs(-5) == 5, 'abs of neg should be pos');
    assert(_felt_abs(0) == 0, 'abs of 0 should be 0');
}

#[test]
#[available_gas(10000000)]
fn test_acos() {
    let a = FixedTrait::new(ONE_u128, false);
    assert(a.acos().into() == 0, 'invalid one');
}

#[test]
#[available_gas(10000000)]
fn test_asin() {
    let a = FixedTrait::new(ONE_u128, false);
    assert(a.asin().into() == 28976077832308491370, 'invalid one'); // PI / 2
}

#[test]
#[available_gas(10000000)]
fn test_atan() {
    let a = FixedTrait::new(2_u128 * ONE_u128, false);

    // use `DEFAULT_PRECISION`
    assert_precise(a.atan(), 20423289048683266000, 'invalid two', Option::None(()));

    // use `custom_precision`
    assert_precise(
        a.atan(), 20423289048683266000, 'invalid two', Option::Some(184467440737_u128)
    ); // 1e-8
}

#[test]
fn test_ceil() {
    let a = FixedTrait::from_felt(53495557813757699680); // 2.9
    assert(a.ceil().into() == 3 * ONE, 'invalid pos decimal');
}

#[test]
fn test_floor() {
    let a = FixedTrait::from_felt(53495557813757699680); // 2.9
    assert(a.floor().into() == 2 * ONE, 'invalid pos decimal');
}

#[test]
fn test_round() {
    let a = FixedTrait::from_felt(53495557813757699680); // 2.9
    assert(a.round().into() == 3 * ONE, 'invalid pos decimal');
}

#[test]
#[should_panic]
fn test_sqrt_fail() {
    let a = FixedTrait::from_unscaled_felt(-25);
    a.sqrt();
}

#[test]
fn test_sqrt() {
    let a = FixedTrait::from_unscaled_felt(0);
    assert(a.sqrt().into() == 0, 'invalid zero root');
}

#[test]
#[available_gas(10000000)]
fn test_pow() {
    let a = FixedTrait::from_unscaled_felt(3);
    let b = FixedTrait::from_unscaled_felt(4);
    assert(a.pow(b).into() == 81 * ONE, 'invalid pos base power');
}

#[test]
#[available_gas(10000000)]
fn test_exp() {
    let a = FixedTrait::new_unscaled(2_u128, false);
    assert(a.exp().into() == 136304026800730572984, 'invalid exp of 2'); // 7.389056098793725
}

#[test]
#[available_gas(10000000)]
fn test_exp2() {
    let a = FixedTrait::new_unscaled(2_u128, false);
    assert(a.exp2().into() == 73786976294838206464, 'invalid exp2 of 2'); // 4
}

#[test]
#[available_gas(10000000)]
fn test_ln() {
    let a = FixedTrait::from_unscaled_felt(1);
    assert(a.ln().into() == 0, 'invalid ln of 1');
}

#[test]
#[available_gas(10000000)]
fn test_log2() {
    let a = FixedTrait::from_unscaled_felt(32);
    assert_precise(a.log2(), 5 * ONE, 'invalid log2 32', Option::None(()));
}

#[test]
#[available_gas(10000000)]
fn test_log10() {
    let a = FixedTrait::from_unscaled_felt(100);
    assert_precise(a.log10(), 2 * ONE, 'invalid log10', Option::None(()));
}

#[test]
fn test_eq() {
    let a = FixedTrait::from_unscaled_felt(42);
    let b = FixedTrait::from_unscaled_felt(42);
    let c = a == b;
    assert(c == true, 'invalid result');
}

#[test]
fn test_ne() {
    let a = FixedTrait::from_unscaled_felt(42);
    let b = FixedTrait::from_unscaled_felt(42);
    let c = a != b;
    assert(c == false, 'invalid result');
}

#[test]
fn test_add() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(2);
    assert(a + b == FixedTrait::from_unscaled_felt(3), 'invalid result');
}

#[test]
fn test_add_eq() {
    let mut a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(2);
    a += b;
    assert(a.into() == 3 * ONE, 'invalid result');
}

#[test]
fn test_sub() {
    let a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(2);
    let c = a - b;
    assert(c.into() == 3 * ONE, 'false result invalid');
}

#[test]
fn test_sub_eq() {
    let mut a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(2);
    a -= b;
    assert(a.into() == 3 * ONE, 'invalid result');
}

#[test]
fn test_mul_pos() {
    let a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(2);
    let c = a * b;
    assert(c.into() == 10 * ONE, 'invalid result');
}

#[test]
fn test_mul_neg() {
    let a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(-2);
    let c = a * b;
    assert(c.into() == -10 * ONE, 'true result invalid');
}

#[test]
fn test_mul_eq() {
    let mut a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(-2);
    a *= b;
    assert(a.into() == -10 * ONE, 'invalid result');
}

#[test]
fn test_div() {
    let a = FixedTrait::from_unscaled_felt(10);
    let b = FixedTrait::from_felt(53495557813757699680); // 2.9
    let c = a / b;
    assert(c.into() == 63609462323136384890, 'invalid pos decimal'); // 3.4482758620689653
}

#[test]
fn test_le() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(0);
    let c = FixedTrait::from_unscaled_felt(-1);

    assert(a <= a, 'a <= a');
    assert(a <= b == false, 'a <= b');
    assert(a <= c == false, 'a <= c');

    assert(b <= a, 'b <= a');
    assert(b <= b, 'b <= b');
    assert(b <= c == false, 'b <= c');

    assert(c <= a, 'c <= a');
    assert(c <= b, 'c <= b');
    assert(c <= c, 'c <= c');
}

#[test]
fn test_lt() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(0);
    let c = FixedTrait::from_unscaled_felt(-1);

    assert(a < a == false, 'a < a');
    assert(a < b == false, 'a < b');
    assert(a < c == false, 'a < c');

    assert(b < a, 'b < a');
    assert(b < b == false, 'b < b');
    assert(b < c == false, 'b < c');

    assert(c < a, 'c < a');
    assert(c < b, 'c < b');
    assert(c < c == false, 'c < c');
}

#[test]
fn test_ge() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(0);
    let c = FixedTrait::from_unscaled_felt(-1);

    assert(a >= a, 'a >= a');
    assert(a >= b, 'a >= b');
    assert(a >= c, 'a >= c');

    assert(b >= a == false, 'b >= a');
    assert(b >= b, 'b >= b');
    assert(b >= c, 'b >= c');

    assert(c >= a == false, 'c >= a');
    assert(c >= b == false, 'c >= b');
    assert(c >= c, 'c >= c');
}

#[test]
fn test_gt() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(0);
    let c = FixedTrait::from_unscaled_felt(-1);

    assert(a > a == false, 'a > a');
    assert(a > b, 'a > b');
    assert(a > c, 'a > c');

    assert(b > a == false, 'b > a');
    assert(b > b == false, 'b > b');
    assert(b > c, 'b > c');

    assert(c > a == false, 'c > a');
    assert(c > b == false, 'c > b');
    assert(c > c == false, 'c > c');
}

#[test]
#[available_gas(10000000)]
fn test_cos() {
    let a = FixedTrait::new(HALF_PI_u128, false);
    assert(a.cos().into() == 0, 'invalid half pi');
}

#[test]
#[available_gas(10000000)]
fn test_sin() {
    let a = FixedTrait::new(HALF_PI_u128, false);
    assert_precise(a.sin(), ONE, 'invalid half pi', Option::None(()));
}

#[test]
#[available_gas(10000000)]
fn test_tan() {
    let a = FixedTrait::new(HALF_PI_u128 / 2_u128, false);
    assert(a.tan().into() == ONE, 'invalid quarter pi');
}

#[test]
#[available_gas(10000000)]
fn test_cosh() {
    let a = FixedTrait::new_unscaled(2_u128, false);
    assert_precise(
        a.cosh(), 69400261068632590000, 'invalid two', Option::None(())
    ); // 3.762195691016423
}

#[test]
#[available_gas(10000000)]
fn test_sinh() {
    let a = FixedTrait::new_unscaled(2_u128, false);
    assert_precise(
        a.sinh(), 66903765734623805000, 'invalid two', Option::None(())
    ); // 3.6268604077773023
}

#[test]
#[available_gas(10000000)]
fn test_tanh() {
    let a = FixedTrait::new_unscaled(2_u128, false);
    assert_precise(
        a.tanh(), 17783170049656136000, 'invalid two', Option::None(())
    ); // 0.9640275800745076
}

#[test]
#[available_gas(10000000)]
fn test_acosh() {
    let a = FixedTrait::new(69400261067392811864_u128, false); // 3.762195691016423
    assert_precise(a.acosh(), 2 * ONE, 'invalid two', Option::None(()));
}

#[test]
#[available_gas(10000000)]
fn test_asinh() {
    let a = FixedTrait::new(66903765733337761105_u128, false); // 3.6268604077773023
    assert_precise(a.asinh(), 2 * ONE, 'invalid two', Option::None(()));
}

#[test]
#[available_gas(10000000)]
fn test_atanh() {
    let a = FixedTrait::new(16602069666338597000, false); // 0.9
    assert_precise(
        a.atanh(), 27157656144668970000, 'invalid 0.9', Option::None(())
    ); // 1.4722194895832204
}
