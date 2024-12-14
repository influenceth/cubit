use core::option::OptionTrait;
use core::result::{ResultTrait, ResultTraitImpl};
use core::traits::{Into, TryInto};
use core::integer::{u64_safe_divmod, u64_as_non_zero};
use core::num::traits::{Sqrt, WideMul};

use cubit::f64::math::lut;
use cubit::f64::types::fixed::{HALF, ONE, Fixed, FixedIntoFelt252, FixedTrait};

// PUBLIC

fn abs(a: Fixed) -> Fixed {
    return FixedTrait::new(a.mag, false);
}

fn add(a: Fixed, b: Fixed) -> Fixed {
    if a.sign == b.sign {
        return FixedTrait::new(a.mag + b.mag, a.sign);
    }

    if a.mag == b.mag {
        return FixedTrait::ZERO();
    }

    if (a.mag > b.mag) {
        return FixedTrait::new(a.mag - b.mag, a.sign);
    } else {
        return FixedTrait::new(b.mag - a.mag, b.sign);
    }
}

fn ceil(a: Fixed) -> Fixed {
    let (div, rem) = u64_safe_divmod(a.mag, u64_as_non_zero(ONE));

    if rem == 0 {
        return a;
    } else if !a.sign {
        return FixedTrait::new_unscaled(div + 1, false);
    } else if div == 0 {
        return FixedTrait::new_unscaled(0, false);
    } else {
        return FixedTrait::new_unscaled(div, true);
    }
}

fn div(a: Fixed, b: Fixed) -> Fixed {
    let a_u128 = a.mag.wide_mul(ONE);
    let res_u128 = a_u128 / b.mag.into();

    // Re-apply sign
    return FixedTrait::new(res_u128.try_into().unwrap(), a.sign ^ b.sign);
}

fn eq(a: @Fixed, b: @Fixed) -> bool {
    return (*a.mag == *b.mag) && (*a.sign == *b.sign);
}

// // Calculates the natural exponent of x: e^x
fn exp(a: Fixed) -> Fixed {
    return exp2(FixedTrait::new(6196328018, false) * a);
}

// Calculates the binary exponent of x: 2^x
fn exp2(a: Fixed) -> Fixed {
    if (a.mag == 0) {
        return FixedTrait::ONE();
    }

    let (int_part, frac_part) = core::integer::u64_safe_divmod(a.mag, u64_as_non_zero(ONE));
    let int_res = FixedTrait::new_unscaled(lut::exp2(int_part), false);
    let mut res_u = int_res;

    if frac_part != 0 {
        let frac = FixedTrait::new(frac_part, false);
        let r8 = FixedTrait::new(9707, false) * frac;
        let r7 = (r8 + FixedTrait::new(53974, false)) * frac;
        let r6 = (r7 + FixedTrait::new(677974, false)) * frac;
        let r5 = (r6 + FixedTrait::new(5713580, false)) * frac;
        let r4 = (r5 + FixedTrait::new(41315679, false)) * frac;
        let r3 = (r4 + FixedTrait::new(238386709, false)) * frac;
        let r2 = (r3 + FixedTrait::new(1031765214, false)) * frac;
        let r1 = (r2 + FixedTrait::new(2977044459, false)) * frac;
        res_u = res_u * (r1 + FixedTrait::ONE());
    }

    if (a.sign == true) {
        return FixedTrait::ONE() / res_u;
    } else {
        return res_u;
    }
}

fn exp2_int(exp: u64) -> Fixed {
    return FixedTrait::new_unscaled(lut::exp2(exp), false);
}

fn floor(a: Fixed) -> Fixed {
    let (div, rem) = core::integer::u64_safe_divmod(a.mag, u64_as_non_zero(ONE));

    if rem == 0 {
        return a;
    } else if !a.sign {
        return FixedTrait::new_unscaled(div, false);
    } else {
        return FixedTrait::new_unscaled(div + 1, true);
    }
}

fn ge(a: Fixed, b: Fixed) -> bool {
    if a.sign != b.sign {
        return !a.sign;
    } else {
        return (a.mag == b.mag) || ((a.mag > b.mag) ^ a.sign);
    }
}

fn gt(a: Fixed, b: Fixed) -> bool {
    if a.sign != b.sign {
        return !a.sign;
    } else {
        return (a.mag != b.mag) && ((a.mag > b.mag) ^ a.sign);
    }
}

fn le(a: Fixed, b: Fixed) -> bool {
    if a.sign != b.sign {
        return a.sign;
    } else {
        return (a.mag == b.mag) || ((a.mag < b.mag) ^ a.sign);
    }
}

// Calculates the natural logarithm of x: ln(x)
// self must be greater than zero
fn ln(a: Fixed) -> Fixed {
    return FixedTrait::new(2977044472, false) * log2(a); // ln(2) = 0.693...
}

// Calculates the binary logarithm of x: log2(x)
// self must be greather than zero
fn log2(a: Fixed) -> Fixed {
    assert(a.sign == false, 'must be positive');

    if (a.mag == ONE) {
        return FixedTrait::ZERO();
    } else if (a.mag < ONE) {
        // Compute true inverse binary log if 0 < x < 1
        let div = FixedTrait::ONE() / a;
        return -log2(div);
    }

    let whole = a.mag / ONE;
    let (msb, div) = lut::msb(whole);

    if a.mag == div * ONE {
        return FixedTrait::new_unscaled(msb, false);
    } else {
        let norm = a / FixedTrait::new_unscaled(div, false);
        let r8 = FixedTrait::new(39036580, true) * norm;
        let r7 = (r8 + FixedTrait::new(531913440, false)) * norm;
        let r6 = (r7 + FixedTrait::new(3214171660, true)) * norm;
        let r5 = (r6 + FixedTrait::new(11333450393, false)) * norm;
        let r4 = (r5 + FixedTrait::new(25827501665, true)) * norm;
        let r3 = (r4 + FixedTrait::new(39883002199, false)) * norm;
        let r2 = (r3 + FixedTrait::new(42980322874, true)) * norm;
        let r1 = (r2 + FixedTrait::new(35024618493, false)) * norm;
        return r1 + FixedTrait::new(14711951564, true) + FixedTrait::new_unscaled(msb, false);
    }
}

// Calculates the base 10 log of x: log10(x)
// self must be greater than zero
fn log10(a: Fixed) -> Fixed {
    return FixedTrait::new(1292913986, false) * log2(a); // log10(2) = 0.301...
}

fn lt(a: Fixed, b: Fixed) -> bool {
    if a.sign != b.sign {
        return a.sign;
    } else {
        return (a.mag != b.mag) && ((a.mag < b.mag) ^ a.sign);
    }
}

fn mul(a: Fixed, b: Fixed) -> Fixed {
    let prod_u128 = a.mag.wide_mul(b.mag);

    // Re-apply sign
    return FixedTrait::new((prod_u128 / ONE.into()).try_into().unwrap(), a.sign ^ b.sign);
}

fn ne(a: @Fixed, b: @Fixed) -> bool {
    return (*a.mag != *b.mag) || (*a.sign != *b.sign);
}

fn neg(a: Fixed) -> Fixed {
    if a.mag == 0 {
        return a;
    } else if !a.sign {
        return FixedTrait::new(a.mag, !a.sign);
    } else {
        return FixedTrait::new(a.mag, false);
    }
}

// Calclates the value of x^y and checks for overflow before returning
// self is a Fixed point value
// b is a Fixed point value
fn pow(a: Fixed, b: Fixed) -> Fixed {
    let (_div, rem) = core::integer::u64_safe_divmod(b.mag, u64_as_non_zero(ONE));

    // use the more performant integer pow when y is an int
    if (rem == 0) {
        return pow_int(a, b.mag / ONE, b.sign);
    }

    // x^y = exp(y*ln(x)) for x > 0 will error for x < 0
    return exp(b * ln(a));
}

// Calclates the value of a^b and checks for overflow before returning
fn pow_int(a: Fixed, b: u64, sign: bool) -> Fixed {
    let mut x = a;
    let mut n = b;

    if sign == true {
        x = FixedTrait::ONE() / x;
    }

    if n == 0 {
        return FixedTrait::ONE();
    }

    let mut y = FixedTrait::ONE();
    let two = core::integer::u64_as_non_zero(2);

    loop {
        if n <= 1 {
            break;
        }

        let (div, rem) = core::integer::u64_safe_divmod(n, two);

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
    let (div, rem) = core::integer::u64_safe_divmod(a.mag, u64_as_non_zero(ONE));

    if (HALF <= rem) {
        return FixedTrait::new_unscaled(div + 1, a.sign);
    } else {
        return FixedTrait::new_unscaled(div, a.sign);
    }
}

// Calculates the square root of a Fixed point value
// x must be positive
fn sqrt(a: Fixed) -> Fixed {
    assert(a.sign == false, 'must be positive');
    let root = (a.mag * ONE).sqrt();
    return FixedTrait::new(root.into(), false);
}

fn sub(a: Fixed, b: Fixed) -> Fixed {
    return add(a, -b);
}

// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use cubit::f64::math::trig::{PI, HALF_PI};
    use cubit::f64::test::helpers::{assert_precise, assert_relative};

    use super::{
        FixedTrait, ONE, round, floor, sqrt, ceil, lut, exp, exp2, exp2_int, pow, log10, log2, ln,
        eq, ne, add, Fixed
    };

    #[test]
    fn test_into() {
        let a = FixedTrait::new_unscaled(5, false);
        assert(a.mag == 5 * ONE, 'invalid result');
    }

    #[test]
    fn test_try_into_u128() {
        // Positive unscaled
        let a = FixedTrait::new_unscaled(5, false);
        assert(a.try_into().unwrap() == 5_u128, 'invalid result');

        // Positive scaled
        let b = FixedTrait::new(5 * ONE, false);
        assert(b.try_into().unwrap() == 5_u128, 'invalid result');

        // let c = FixedTrait::new(PI_u128, false);
        // assert(c.try_into().unwrap() == 3_u128, 'invalid result');

        // Zero
        let d = FixedTrait::new_unscaled(0, false);
        assert(d.try_into().unwrap() == 0_u128, 'invalid result');
    }

    #[test]
    #[should_panic]
    fn test_negative_try_into_u128() {
        let a = FixedTrait::new_unscaled(1, true);
        let _a: u128 = a.try_into().unwrap();
    }

    #[test]
    #[available_gas(1000000)]
    fn test_acos() {
        let a = FixedTrait::ONE();
        assert(a.acos().into() == 0, 'invalid one');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_asin() {
        let a = FixedTrait::ONE();
        assert_precise(a.asin(), HALF_PI.into(), 'invalid one', Option::None(())); // PI / 2
    }

    #[test]
    #[available_gas(2000000)]
    fn test_atan() {
        let a = FixedTrait::new(2 * ONE, false);
        assert_relative(a.atan(), 4755167535, 'invalid two', Option::None(()));
    }

    #[test]
    fn test_ceil() {
        let a = FixedTrait::new(12455405158, false); // 2.9
        assert(ceil(a).mag == 3 * ONE, 'invalid pos decimal');
    }

    #[test]
    fn test_floor() {
        let a = FixedTrait::new(12455405158, false); // 2.9
        assert(floor(a).mag == 2 * ONE, 'invalid pos decimal');
    }

    #[test]
    fn test_round() {
        let a = FixedTrait::new(12455405158, false); // 2.9
        assert(round(a).mag == 3 * ONE, 'invalid pos decimal');
    }

    #[test]
    #[should_panic]
    fn test_sqrt_fail() {
        let a = FixedTrait::new_unscaled(25, true);
        sqrt(a);
    }

    #[test]
    fn test_sqrt() {
        let mut a = FixedTrait::new_unscaled(0, false);
        assert(sqrt(a).mag == 0, 'invalid zero root');
        a = FixedTrait::new_unscaled(25, false);
        assert(sqrt(a).mag == 5 * ONE, 'invalid pos root');
    }

    #[test]
    #[available_gas(100000)]
    fn test_msb() {
        let a = FixedTrait::new_unscaled(1000000, false);
        let (msb, div) = lut::msb(a.mag / ONE);
        assert(msb == 19, 'invalid msb');
        assert(div == 524288, 'invalid msb ceil');
    }

    #[test]
    #[available_gas(600000)] // 430k
    fn test_pow() {
        let a = FixedTrait::new_unscaled(3, false);
        let b = FixedTrait::new_unscaled(4, false);
        assert(pow(a, b).mag == 81 * ONE, 'invalid pos base power');
    }

    #[test]
    #[available_gas(900000)] // 350k
    fn test_pow_frac() {
        let a = FixedTrait::new_unscaled(3, false);
        let b = FixedTrait::new(2147483648, false); // 0.5
        assert_relative(
            pow(a, b), 7439101574, 'invalid pos base power', Option::None(())
        ); // 1.7320508075688772
    }

    #[test]
    #[available_gas(1000000)] // 167k
    fn test_exp() {
        let a = FixedTrait::new_unscaled(2, false);
        assert_relative(
            exp(a), 31735754293, 'invalid exp of 2', Option::None(())
        ); // 7.389056098793725
    }

    #[test]
    #[available_gas(400000)]
    fn test_exp2() {
        let a = FixedTrait::new_unscaled(24, false);
        assert(exp2(a).mag == 72057594037927936, 'invalid exp2 of 2');
    }

    #[test]
    #[available_gas(20000)]
    fn test_exp2_int() {
        assert(exp2_int(24).into() == 72057594037927936, 'invalid exp2 of 2');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_ln() {
        let mut a = FixedTrait::new_unscaled(1, false);
        assert(ln(a).mag == 0, 'invalid ln of 1');

        a = FixedTrait::new(11674931554, false);
        assert_relative(ln(a), ONE.into(), 'invalid ln of 2.7...', Option::None(()));
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log2() {
        let mut a = FixedTrait::new_unscaled(32, false);
        assert(log2(a) == FixedTrait::new_unscaled(5, false), 'invalid log2 32');

        a = FixedTrait::new_unscaled(10, false);
        assert_relative(
            log2(a), 14267572527, 'invalid log2 10', Option::None(())
        ); // 3.321928094887362
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log10() {
        let a = FixedTrait::new_unscaled(100, false);
        assert_relative(log10(a), 2 * ONE.into(), 'invalid log10', Option::None(()));
    }

    #[test]
    fn test_eq() {
        let a = FixedTrait::new_unscaled(42, false);
        let b = FixedTrait::new_unscaled(42, false);
        let c = eq(@a, @b);
        assert(c == true, 'invalid result');
    }

    #[test]
    fn test_ne() {
        let a = FixedTrait::new_unscaled(42, false);
        let b = FixedTrait::new_unscaled(42, false);
        let c = ne(@a, @b);
        assert(c == false, 'invalid result');
    }

    #[test]
    fn test_add() {
        let a = FixedTrait::new_unscaled(1, false);
        let b = FixedTrait::new_unscaled(2, false);
        assert(add(a, b) == FixedTrait::new_unscaled(3, false), 'invalid result');
    }

    #[test]
    fn test_add_eq() {
        let mut a = FixedTrait::new_unscaled(1, false);
        let b = FixedTrait::new_unscaled(2, false);
        a += b;
        assert(a == FixedTrait::new_unscaled(3, false), 'invalid result');
    }

    #[test]
    fn test_sub() {
        let a = FixedTrait::new_unscaled(5, false);
        let b = FixedTrait::new_unscaled(2, false);
        let c = a - b;
        assert(c == FixedTrait::new_unscaled(3, false), 'false result invalid');
    }

    #[test]
    fn test_sub_eq() {
        let mut a = FixedTrait::new_unscaled(5, false);
        let b = FixedTrait::new_unscaled(2, false);
        a -= b;
        assert(a == FixedTrait::new_unscaled(3, false), 'invalid result');
    }

    #[test]
    #[available_gas(100000)] // 13k
    fn test_mul_pos() {
        let a = Fixed { mag: 12455405158, sign: false };
        let b = Fixed { mag: 12455405158, sign: false };
        let c = a * b;
        assert(c.mag == 36120674957, 'invalid result');
    }

    #[test]
    fn test_mul_neg() {
        let a = FixedTrait::new_unscaled(5, false);
        let b = FixedTrait::new_unscaled(2, true);
        let c = a * b;
        assert(c == FixedTrait::new_unscaled(10, true), 'invalid result');
    }

    #[test]
    fn test_mul_eq() {
        let mut a = FixedTrait::new_unscaled(5, false);
        let b = FixedTrait::new_unscaled(2, true);
        a *= b;
        assert(a == FixedTrait::new_unscaled(10, true), 'invalid result');
    }

    #[test]
    fn test_div() {
        let a = FixedTrait::new_unscaled(10, false);
        let b = FixedTrait::new(12455405158, false); // 2.9
        let c = a / b;
        assert(c.mag == 14810232055, 'invalid pos decimal'); // 3.4482758620689653
    }

    #[test]
    fn test_le() {
        let a = FixedTrait::new_unscaled(1, false);
        let b = FixedTrait::new_unscaled(0, false);
        let c = FixedTrait::new_unscaled(1, true);

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
        let a = FixedTrait::new_unscaled(1, false);
        let b = FixedTrait::new_unscaled(0, false);
        let c = FixedTrait::new_unscaled(1, true);

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
        let a = FixedTrait::new_unscaled(1, false);
        let b = FixedTrait::new_unscaled(0, false);
        let c = FixedTrait::new_unscaled(1, true);

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
        let a = FixedTrait::new_unscaled(1, false);
        let b = FixedTrait::new_unscaled(0, false);
        let c = FixedTrait::new_unscaled(1, true);

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
        let a = FixedTrait::new(HALF_PI, false);
        assert(a.cos().into() == 0, 'invalid half pi');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_sin() {
        let a = FixedTrait::new(HALF_PI, false);
        assert_precise(a.sin(), ONE.into(), 'invalid half pi', Option::None(()));
    }

    #[test]
    #[available_gas(2000000)]
    fn test_tan() {
        let a = FixedTrait::new(HALF_PI / 2, false);
        assert(a.tan().mag == ONE, 'invalid quarter pi');
    }
// #[test]
// #[available_gas(1000000)]
// fn test_cosh() {
//     let a = FixedTrait::new_unscaled(2, false);
//     assert_precise(
//         a.cosh(), 69400261068632590000, 'invalid two', Option::None(())
//     ); // 3.762195691016423
// }

// #[test]
// #[available_gas(1000000)]
// fn test_sinh() {
//     let a = FixedTrait::new_unscaled(2, false);
//     assert_precise(
//         a.sinh(), 66903765734623805000, 'invalid two', Option::None(())
//     ); // 3.6268604077773023
// }

// #[test]
// #[available_gas(1000000)]
// fn test_tanh() {
//     let a = FixedTrait::new_unscaled(2, false);
//     assert_precise(
//         a.tanh(), 17783170049656136000, 'invalid two', Option::None(())
//     ); // 0.9640275800745076
// }

// #[test]
// #[available_gas(1000000)]
// fn test_acosh() {
//     let a = FixedTrait::new(69400261067392811864, false); // 3.762195691016423
//     assert_precise(a.acosh(), 2 * ONE, 'invalid two', Option::None(()));
// }

// #[test]
// #[available_gas(1000000)]
// fn test_asinh() {
//     let a = FixedTrait::new(66903765733337761105, false); // 3.6268604077773023
//     assert_precise(a.asinh(), 2 * ONE, 'invalid two', Option::None(()));
// }

// #[test]
// #[available_gas(1000000)]
// fn test_atanh() {
//     let a = FixedTrait::new(16602069666338597000, false); // 0.9
//     assert_precise(
//         a.atanh(), 27157656144668970000, 'invalid 0.9', Option::None(())
//     ); // 1.4722194895832204
// }

}
