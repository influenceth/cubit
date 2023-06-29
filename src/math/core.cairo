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
    let (a_high, a_low) = integer::u128_wide_mul(a.mag, ONE_u128);
    let a_u256 = u256 { low: a_low, high: a_high };
    let b_u256 = u256 { low: b.mag, high: 0_u128 };
    let res_u256 = a_u256 / b_u256;

    assert(res_u256.high == 0_u128, 'result overflow');

    // Re-apply sign
    return FixedTrait::new(res_u256.low, a.sign ^ b.sign);
}

fn eq(a: Fixed, b: Fixed) -> bool {
    return a.mag == b.mag & a.sign == b.sign;
}

// Calculates the natural exponent of x: e^x
fn exp(a: Fixed) -> Fixed {
    return exp2(FixedTrait::new(26613026195688644984, false) * a);
}

// Calculates the binary exponent of x: 2^x
fn exp2(a: Fixed) -> Fixed {
    if (a.mag == 0) {
        return FixedTrait::new(ONE_u128, false);
    }

    let (int_part, frac_part) = _split_unsigned(a);
    let int_res = FixedTrait::new_unscaled(_exp2(int_part), false);
    let mut res_u = int_res;

    if frac_part > 0 {
        let frac_fixed = FixedTrait::new(frac_part, false);
        let r8 = FixedTrait::new(41691949755436_u128, false) * frac_fixed;
        let r7 = (r8 + FixedTrait::new(231817862090993_u128, false)) * frac_fixed;
        let r6 = (r7 + FixedTrait::new(2911875592466782_u128, false)) * frac_fixed;
        let r5 = (r6 + FixedTrait::new(24539637786416367_u128, false)) * frac_fixed;
        let r4 = (r5 + FixedTrait::new(177449490038807528_u128, false)) * frac_fixed;
        let r3 = (r4 + FixedTrait::new(1023863119786103800_u128, false)) * frac_fixed;
        let r2 = (r3 + FixedTrait::new(4431397849999009866_u128, false)) * frac_fixed;
        let r1 = (r2 + FixedTrait::new(12786308590235521577_u128, false)) * frac_fixed;
        res_u = res_u * (r1 + FixedTrait::new(ONE_u128, false));
    }

    if (a.sign == true) {
        return FixedTrait::new(ONE_u128, false) / res_u;
    } else {
        return res_u;
    }
}

fn exp2_int(exp: u128) -> Fixed {
    return FixedTrait::new_unscaled(_exp2(exp), false);
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
        return FixedTrait::new(0, false);
    } else if (a.mag < ONE_u128) {
        // Compute true inverse binary log if 0 < x < 1
        let div = FixedTrait::new(ONE_u128, false) / a;
        return -log2(div);
    }

    let (msb, div) = msb(a.mag);
    let norm = a / FixedTrait::new_unscaled(div, false);

    let r8 = FixedTrait::new(167660832607149504, true) * norm;
    let r7 = (r8 + FixedTrait::new(2284550827067371376, false)) * norm;
    let r6 = (r7 + FixedTrait::new(13804762162529339368, true)) * norm;
    let r5 = (r6 + FixedTrait::new(48676798788932142400, false)) * norm;
    let r4 = (r5 + FixedTrait::new(110928274989790216568, true)) * norm;
    let r3 = (r4 + FixedTrait::new(171296190111888966192, false)) * norm;
    let r2 = (r3 + FixedTrait::new(184599081115266689944, true)) * norm;
    let r1 = (r2 + FixedTrait::new(150429590981271126408, false)) * norm;
    return r1 + FixedTrait::new(63187350828072553424, true) + FixedTrait::new_unscaled(msb, false);
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
    let (high, low) = integer::u128_wide_mul(a.mag, b.mag);
    let res_u256 = u256 { low: low, high: high };
    let ONE_u256 = u256 { low: ONE_u128, high: 0_u128 };
    let (scaled_u256, _) = u256_safe_divmod(res_u256, u256_as_non_zero(ONE_u256));

    assert(scaled_u256.high == 0_u128, 'result overflow');

    // Re-apply sign
    return FixedTrait::new(scaled_u256.low, a.sign ^ b.sign);
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
        return pow_int(a, b.mag / ONE_u128, b.sign);
    }

    // x^y = exp(y*ln(x)) for x > 0 will error for x < 0
    return exp(b * ln(a));
}

// Calclates the value of a^b and checks for overflow before returning
fn pow_int(a: Fixed, b: u128, sign: bool) -> Fixed {
    let mut x = a;
    let mut n = b;

    if sign == true {
        x = FixedTrait::new(ONE_u128, false) / x;
    }

    if n == 0 {
        return FixedTrait::new(ONE_u128, false);
    }

    let mut y = FixedTrait::new(ONE_u128, false);
    let two = integer::u128_as_non_zero(2);

    loop {
        if n <= 1 {
            break;
        }

        let (div, rem) = integer::u128_safe_divmod(n, two);

        if rem == 1 {
            y = x * y;
        }

        x = x * x;
        n = div;
    };

    return x * y;
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

// Calculates the most significant bit
fn msb(a: u128) -> (u128, u128) {
    let whole = a / ONE_u128;

    if whole < 256 {
        if whole < 2 { return (0, 1); }
        if whole < 4 { return (1, 2); }
        if whole < 8 { return (2, 4); }
        if whole < 16 { return (3, 8); }
        if whole < 32 { return (4, 16); }
        if whole < 64 { return (5, 32); }
        if whole < 128 { return (6, 64); }
        if whole < 256 { return (7, 128); }
    } else if whole < 65536 {
        if whole < 512 { return (8, 256); }
        if whole < 1024 { return (9, 512); }
        if whole < 2048 { return (10, 1024); }
        if whole < 4096 { return (11, 2048); }
        if whole < 8192 { return (12, 4096); }
        if whole < 16384 { return (13, 8192); }
        if whole < 32768 { return (14, 16384); }
        if whole < 65536 { return (15, 32768); }
    } else if whole < 16777216 {
        if whole < 131072 { return (16, 65536); }
        if whole < 262144 { return (17, 131072); }
        if whole < 524288 { return (18, 262144); }
        if whole < 1048576 { return (19, 524288); }
        if whole < 2097152 { return (20, 1048576); }
        if whole < 4194304 { return (21, 2097152); }
        if whole < 8388608 { return (22, 4194304); }
        if whole < 16777216 { return (23, 8388608); }
    } else if whole < 4294967296 {
        if whole < 33554432 { return (24, 16777216); }
        if whole < 67108864 { return (25, 33554432); }
        if whole < 134217728 { return (26, 67108864); }
        if whole < 268435456 { return (27, 134217728); }
        if whole < 536870912 { return (28, 268435456); }
        if whole < 1073741824 { return (29, 536870912); }
        if whole < 2147483648 { return (30, 1073741824); }
        if whole < 4294967296 { return (31, 2147483648); }
    } else if whole < 1099511627776 {
        if whole < 8589934592 { return (32, 4294967296); }
        if whole < 17179869184 { return (33, 8589934592); }
        if whole < 34359738368 { return (34, 17179869184); }
        if whole < 68719476736 { return (35, 34359738368); }
        if whole < 137438953472 { return (36, 68719476736); }
        if whole < 274877906944 { return (37, 137438953472); }
        if whole < 549755813888 { return (38, 274877906944); }
        if whole < 1099511627776 { return (39, 549755813888); }
    } else if whole < 281474976710656 {
        if whole < 2199023255552 { return (40, 1099511627776); }
        if whole < 4398046511104 { return (41, 2199023255552); }
        if whole < 8796093022208 { return (42, 4398046511104); }
        if whole < 17592186044416 { return (43, 8796093022208); }
        if whole < 35184372088832 { return (44, 17592186044416); }
        if whole < 70368744177664 { return (45, 35184372088832); }
        if whole < 140737488355328 { return (46, 70368744177664); }
        if whole < 281474976710656 { return (47, 140737488355328); }
    } else if whole < 72057594037927936 {
        if whole < 562949953421312 { return (48, 281474976710656); }
        if whole < 1125899906842624 { return (49, 562949953421312); }
        if whole < 2251799813685248 { return (50, 1125899906842624); }
        if whole < 4503599627370496 { return (51, 2251799813685248); }
        if whole < 9007199254740992 { return (52, 4503599627370496); }
        if whole < 18014398509481984 { return (53, 9007199254740992); }
        if whole < 36028797018963968 { return (54, 18014398509481984); }
        if whole < 72057594037927936 { return (55, 36028797018963968); }
    } else {
        if whole < 144115188075855872 { return (56, 72057594037927936); }
        if whole < 288230376151711744 { return (57, 144115188075855872); }
        if whole < 576460752303423488 { return (58, 288230376151711744); }
        if whole < 1152921504606846976 { return (59, 576460752303423488); }
        if whole < 2305843009213693952 { return (60, 1152921504606846976); }
        if whole < 4611686018427387904 { return (61, 2305843009213693952); }
        if whole < 9223372036854775808 { return (62, 4611686018427387904); }
        if whole < 18446744073709551616 { return (63, 9223372036854775808); }
    }

    return (64, 18446744073709551616);
}

fn _exp2(exp: u128) -> u128 {
    if exp <= 16 {
        if exp == 0 { return 1; }
        if exp == 1 { return 2; }
        if exp == 2 { return 4; }
        if exp == 3 { return 8; }
        if exp == 4 { return 16; }
        if exp == 5 { return 32; }
        if exp == 6 { return 64; }
        if exp == 7 { return 128; }
        if exp == 8 { return 256; }
        if exp == 9 { return 512; }
        if exp == 10 { return 1024; }
        if exp == 11 { return 2048; }
        if exp == 12 { return 4096; }
        if exp == 13 { return 8192; }
        if exp == 14 { return 16384; }
        if exp == 15 { return 32768; }
        if exp == 16 { return 65536; }
    } else if exp <= 32 {
        if exp == 17 { return 131072; }
        if exp == 18 { return 262144; }
        if exp == 19 { return 524288; }
        if exp == 20 { return 1048576; }
        if exp == 21 { return 2097152; }
        if exp == 22 { return 4194304; }
        if exp == 23 { return 8388608; }
        if exp == 24 { return 16777216; }
        if exp == 25 { return 33554432; }
        if exp == 26 { return 67108864; }
        if exp == 27 { return 134217728; }
        if exp == 28 { return 268435456; }
        if exp == 29 { return 536870912; }
        if exp == 30 { return 1073741824; }
        if exp == 31 { return 2147483648; }
        if exp == 32 { return 4294967296; }
    } else if exp <= 48 {
        if exp == 33 { return 8589934592; }
        if exp == 34 { return 17179869184; }
        if exp == 35 { return 34359738368; }
        if exp == 36 { return 68719476736; }
        if exp == 37 { return 137438953472; }
        if exp == 38 { return 274877906944; }
        if exp == 39 { return 549755813888; }
        if exp == 40 { return 1099511627776; }
        if exp == 41 { return 2199023255552; }
        if exp == 42 { return 4398046511104; }
        if exp == 43 { return 8796093022208; }
        if exp == 44 { return 17592186044416; }
        if exp == 45 { return 35184372088832; }
        if exp == 46 { return 70368744177664; }
        if exp == 47 { return 140737488355328; }
        if exp == 48 { return 281474976710656; }
    } else {
        if exp == 49 { return 562949953421312; }
        if exp == 50 { return 1125899906842624; }
        if exp == 51 { return 2251799813685248; }
        if exp == 52 { return 4503599627370496; }
        if exp == 53 { return 9007199254740992; }
        if exp == 54 { return 18014398509481984; }
        if exp == 55 { return 36028797018963968; }
        if exp == 56 { return 72057594037927936; }
        if exp == 57 { return 144115188075855872; }
        if exp == 58 { return 288230376151711744; }
        if exp == 59 { return 576460752303423488; }
        if exp == 60 { return 1152921504606846976; }
        if exp == 61 { return 2305843009213693952; }
        if exp == 62 { return 4611686018427387904; }
        if exp == 63 { return 9223372036854775808; }
    }

    return 18446744073709551616;
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
    assert(a.try_into().unwrap() == 5_u128, 'invalid result');

    // Positive scaled
    let b = FixedTrait::new(5_u128 * ONE_u128, false);
    assert(b.try_into().unwrap() == 5_u128, 'invalid result');

    let c = FixedTrait::new(PI_u128, false);
    assert(c.try_into().unwrap() == 3_u128, 'invalid result');

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
#[available_gas(1000000)]
fn test_acos() {
    let a = FixedTrait::new(ONE_u128, false);
    assert(a.acos().into() == 0, 'invalid one');
}

#[test]
#[available_gas(1000000)]
fn test_asin() {
    let a = FixedTrait::new(ONE_u128, false);
    assert(a.asin().into() == 28976077832308491370, 'invalid one'); // PI / 2
}

#[test]
#[available_gas(2000000)]
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
#[available_gas(100000)]
fn test_msb() {
    let a = FixedTrait::new_unscaled(4503599627370495, false);
    let (msb, div) = msb(a.mag);
    assert(msb == 51, 'invalid msb');
    assert(div == 2251799813685248, 'invalid msb ceil');
}

#[test]
#[available_gas(600000)] // 600k
fn test_pow() {
    let a = FixedTrait::new_unscaled(3, false);
    let b = FixedTrait::new_unscaled(4, false);
    assert(a.pow(b).into() == 81 * ONE, 'invalid pos base power');
}

#[test]
#[available_gas(900000)] // 1000k
fn test_pow_frac() {
    let a = FixedTrait::new_unscaled(3, false);
    let b = FixedTrait::new(9223372036854775808, false); // 0.5
    assert_precise(a.pow(b), 31950697969885030000, 'invalid pos base power', Option::None(())); // 1.7320508075688772
}

#[test]
#[available_gas(1000000)]
fn test_exp() {
    let a = FixedTrait::new_unscaled(2, false);
    assert(a.exp().into() == 136304026800730572984, 'invalid exp of 2'); // 7.389056098793725
}

#[test]
#[available_gas(400000)]
fn test_exp2() {
    let a = FixedTrait::new_unscaled(24, false);
    assert(a.exp2().into() == 309485009821345068724781056, 'invalid exp2 of 2');
}

#[test]
#[available_gas(20000)]
fn test_exp2_int() {
    assert(exp2_int(24).into() == 309485009821345068724781056, 'invalid exp2 of 2');
}

#[test]
#[available_gas(1000000)]
fn test_ln() {
    let a = FixedTrait::from_unscaled_felt(1);
    assert(a.ln().into() == 0, 'invalid ln of 1');
}

#[test]
#[available_gas(1000000)]
fn test_log2() {
    let a = FixedTrait::from_unscaled_felt(32);
    assert_precise(a.log2(), 5 * ONE, 'invalid log2 32', Option::None(()));
}

#[test]
#[available_gas(1000000)]
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
#[available_gas(1000000)]
fn test_cos() {
    let a = FixedTrait::new(HALF_PI_u128, false);
    assert(a.cos().into() == 0, 'invalid half pi');
}

#[test]
#[available_gas(1000000)]
fn test_sin() {
    let a = FixedTrait::new(HALF_PI_u128, false);
    assert_precise(a.sin(), ONE, 'invalid half pi', Option::None(()));
}

#[test]
#[available_gas(2000000)]
fn test_tan() {
    let a = FixedTrait::new(HALF_PI_u128 / 2, false);
    assert(a.tan().into() == ONE, 'invalid quarter pi');
}

#[test]
#[available_gas(1000000)]
fn test_cosh() {
    let a = FixedTrait::new_unscaled(2, false);
    assert_precise(
        a.cosh(), 69400261068632590000, 'invalid two', Option::None(())
    ); // 3.762195691016423
}

#[test]
#[available_gas(1000000)]
fn test_sinh() {
    let a = FixedTrait::new_unscaled(2, false);
    assert_precise(
        a.sinh(), 66903765734623805000, 'invalid two', Option::None(())
    ); // 3.6268604077773023
}

#[test]
#[available_gas(1000000)]
fn test_tanh() {
    let a = FixedTrait::new_unscaled(2, false);
    assert_precise(
        a.tanh(), 17783170049656136000, 'invalid two', Option::None(())
    ); // 0.9640275800745076
}

#[test]
#[available_gas(1000000)]
fn test_acosh() {
    let a = FixedTrait::new(69400261067392811864_u128, false); // 3.762195691016423
    assert_precise(a.acosh(), 2 * ONE, 'invalid two', Option::None(()));
}

#[test]
#[available_gas(1000000)]
fn test_asinh() {
    let a = FixedTrait::new(66903765733337761105_u128, false); // 3.6268604077773023
    assert_precise(a.asinh(), 2 * ONE, 'invalid two', Option::None(()));
}

#[test]
#[available_gas(1000000)]
fn test_atanh() {
    let a = FixedTrait::new(16602069666338597000, false); // 0.9
    assert_precise(
        a.atanh(), 27157656144668970000, 'invalid 0.9', Option::None(())
    ); // 1.4722194895832204
}
