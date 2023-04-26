use array::array_append;
use array::array_new;
use debug::PrintTrait;
use gas::withdraw_gas;
use integer::u256_safe_divmod;
use integer::u256_as_non_zero;
use integer::u256_from_felt252;
use option::OptionTrait;
use result::ResultTrait;
use result::ResultTraitImpl;
use traits::Into;

use cubit::math::core;
use cubit::math::hyp;
use cubit::math::trig;


// CONSTANTS

const PRIME: felt252 = 3618502788666131213697322783095070105623107215331596699973092056135872020480;
const HALF_PRIME: felt252 = 1809251394333065606848661391547535052811553607665798349986546028067936010240;
const ONE: felt252 = 18446744073709551616; // 2 ** 64
const ONE_u128: u128 = 18446744073709551616_u128; // 2 ** 64
const HALF: felt252 = 9223372036854775808; // 2 ** 63
const HALF_u128: u128 = 9223372036854775808_u128; // 2 ** 63
const MAX_u128: u128 = 340282366920938463463374607431768211455_u128; // 2 ** 128 - 1

// STRUCTS

#[derive(Copy, Drop)]
struct FixedType { mag: u128, sign: bool }

// TRAITS

trait Fixed {
    // Constructors
    fn new(mag: u128, sign: bool) -> FixedType;
    fn new_unscaled(mag: u128, sign: bool) -> FixedType;
    fn from_felt(val: felt252) -> FixedType;
    fn from_unscaled_felt(val: felt252) -> FixedType;

    // Math
    fn abs(self: FixedType) -> FixedType;
    fn ceil(self: FixedType) -> FixedType;
    fn exp(self: FixedType) -> FixedType;
    fn exp2(self: FixedType) -> FixedType;
    fn floor(self: FixedType) -> FixedType;
    fn ln(self: FixedType) -> FixedType;
    fn log2(self: FixedType) -> FixedType;
    fn log10(self: FixedType) -> FixedType;
    fn pow(self: FixedType, b: FixedType) -> FixedType;
    fn round(self: FixedType) -> FixedType;
    fn sqrt(self: FixedType) -> FixedType;

    // Trigonometry
    fn acos(self: FixedType) -> FixedType;
    fn asin(self: FixedType) -> FixedType;
    fn atan(self: FixedType) -> FixedType;
    fn cos(self: FixedType) -> FixedType;
    fn sin(self: FixedType) -> FixedType;
    fn tan(self: FixedType) -> FixedType;

    // Hyperbolic
    fn acosh(self: FixedType) -> FixedType;
    fn asinh(self: FixedType) -> FixedType;
    fn atanh(self: FixedType) -> FixedType;
    fn cosh(self: FixedType) -> FixedType;
    fn sinh(self: FixedType) -> FixedType;
    fn tanh(self: FixedType) -> FixedType;
}

// IMPLS

impl FixedImpl of Fixed {
    fn new(mag: u128, sign: bool) -> FixedType {
        return FixedType { mag: mag, sign: sign };
    }

    fn new_unscaled(mag: u128, sign: bool) -> FixedType {
        return Fixed::new(mag * ONE_u128, sign);
    }

    fn from_felt(val: felt252) -> FixedType {
        let mag = integer::u128_try_from_felt252(_felt_abs(val)).unwrap();
        return Fixed::new(mag, _felt_sign(val));
    }

    fn from_unscaled_felt(val: felt252) -> FixedType {
        return Fixed::from_felt(val * ONE);
    }

    fn abs(self: FixedType) -> FixedType {
        return abs(self);
    }

    fn acos(self: FixedType) -> FixedType {
        return trig::acos(self);
    }

    fn acosh(self: FixedType) -> FixedType {
        return hyp::acosh(self);
    }

    fn asin(self: FixedType) -> FixedType {
        return trig::asin(self);
    }

    fn asinh(self: FixedType) -> FixedType {
        return hyp::asinh(self);
    }

    fn atan(self: FixedType) -> FixedType {
        return trig::atan(self);
    }

    fn atanh(self: FixedType) -> FixedType {
        return hyp::atanh(self);
    }

    fn ceil(self: FixedType) -> FixedType {
        return ceil(self);
    }

    fn cos(self: FixedType) -> FixedType {
        return trig::cos(self);
    }

    fn cosh(self: FixedType) -> FixedType {
        return hyp::cosh(self);
    }

    fn floor(self: FixedType) -> FixedType {
        return floor(self);
    }

    // Calculates the natural exponent of x: e^x
    fn exp(self: FixedType) -> FixedType {
        return exp(self);
    }

    // Calculates the binary exponent of x: 2^x
    fn exp2(self: FixedType) -> FixedType {
        return exp2(self);
    }

    // Calculates the natural logarithm of x: ln(x)
    // self must be greater than zero
    fn ln(self: FixedType) -> FixedType {
        return ln(self);
    }

    // Calculates the binary logarithm of x: log2(x)
    // self must be greather than zero
    fn log2(self: FixedType) -> FixedType {
        return log2(self);
    }

    // Calculates the base 10 log of x: log10(x)
    // self must be greater than zero
    fn log10(self: FixedType) -> FixedType {
        return log10(self);
    }

    // Calclates the value of x^y and checks for overflow before returning
    // self is a fixed point value
    // b is a fixed point value
    fn pow(self: FixedType, b: FixedType) -> FixedType {
        return pow(self, b);
    }

    fn round(self: FixedType) -> FixedType {
        return round(self);
    }

    fn sin(self: FixedType) -> FixedType {
        return trig::sin(self);
    }

    fn sinh(self: FixedType) -> FixedType {
        return hyp::sinh(self);
    }

    // Calculates the square root of a fixed point value
    // x must be positive
    fn sqrt(self: FixedType) -> FixedType {
        return sqrt(self);
    }

    fn tan(self: FixedType) -> FixedType {
        return trig::tan(self);
    }

    fn tanh(self: FixedType) -> FixedType {
        return hyp::tanh(self);
    }
}

impl FixedPrint of PrintTrait<FixedType> {
    fn print(self: FixedType) {
        self.sign.print();
        self.mag.into().print();
    }
}

impl FixedInto of Into::<FixedType, felt252> {
    fn into(self: FixedType) -> felt252 {
        let mag_felt = self.mag.into();

        if (self.sign == true) {
            return mag_felt * -1;
        } else {
            return mag_felt;
        }
    }
}

impl FixedPartialEq of PartialEq::<FixedType> {
    #[inline(always)]
    fn eq(lhs: FixedType, rhs: FixedType) -> bool {
        return core::eq(lhs, rhs);
    }

    #[inline(always)]
    fn ne(lhs: FixedType, rhs: FixedType) -> bool {
        return core::ne(lhs, rhs);
    }
}

impl FixedAdd of Add::<FixedType> {
    fn add(lhs: FixedType, rhs: FixedType) -> FixedType {
        return core::add(lhs, rhs);
    }
}

impl FixedAddEq of AddEq::<FixedType> {
    #[inline(always)]
    fn add_eq(ref self: FixedType, other: FixedType) {
        self = Add::add(self, other);
    }
}

impl FixedSub of Sub::<FixedType> {
    fn sub(lhs: FixedType, rhs: FixedType) -> FixedType {
        return core::sub(lhs, rhs);
    }
}

impl FixedSubEq of SubEq::<FixedType> {
    #[inline(always)]
    fn sub_eq(ref self: FixedType, other: FixedType) {
        self = Sub::sub(self, other);
    }
}

impl FixedMul of Mul::<FixedType> {
    fn mul(lhs: FixedType, rhs: FixedType) -> FixedType {
        return core::mul(lhs, rhs);
    }
}

impl FixedMulEq of MulEq::<FixedType> {
    #[inline(always)]
    fn mul_eq(ref self: FixedType, other: FixedType) {
        self = Mul::mul(self, other);
    }
}

impl FixedDiv of Div::<FixedType> {
    fn div(lhs: FixedType, rhs: FixedType) -> FixedType {
        return core::div(lhs, rhs);
    }
}

impl FixedDivEq of DivEq::<FixedType> {
    #[inline(always)]
    fn div_eq(ref self: FixedType, other: FixedType) {
        self = Div::div(self, other);
    }
}

impl FixedPartialOrd of PartialOrd::<FixedType> {
    #[inline(always)]
    fn ge(lhs: FixedType, rhs: FixedType) -> bool {
        return core::ge(lhs, rhs);
    }

    #[inline(always)]
    fn gt(lhs: FixedType, rhs: FixedType) -> bool {
        return core::gt(lhs, rhs);
    }

    #[inline(always)]
    fn le(lhs: FixedType, rhs: FixedType) -> bool {
        return core::le(lhs, rhs);
    }

    #[inline(always)]
    fn lt(lhs: FixedType, rhs: FixedType) -> bool {
        return core::lt(lhs, rhs);
    }
}

impl FixedNeg of Neg::<FixedType> {
    #[inline(always)]
    fn neg(a: FixedType) -> FixedType {
        return neg(a);
    }
}

impl FixedRem of Rem::<FixedType> {
    #[inline(always)]
    fn rem(lhs: FixedType, rhs: FixedType) -> FixedType {
        return rem(lhs, rhs);
    }
}

// FUNCTIONS

fn abs(a: FixedType) -> FixedType {
    return Fixed::new(a.mag, false);
}

fn add(a: FixedType, b: FixedType) -> FixedType {
    return Fixed::from_felt(a.into() + b.into());
}

fn ceil(a: FixedType) -> FixedType {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if (rem_u128 == 0_u128) {
        return a;
    } else if (a.sign == false) {
        return Fixed::new_unscaled(div_u128 + 1_u128, false);
    } else {
        return Fixed::from_unscaled_felt(div_u128.into() * -1);
    }
}

fn div(a: FixedType, b: FixedType) -> FixedType {
    let res_sign = a.sign ^ b.sign;
    let (a_high, a_low) = integer::u128_wide_mul(a.mag, ONE_u128);
    let a_u256 = u256 { low: a_low, high: a_high };
    let b_u256 = u256 { low: b.mag, high: 0_u128 };
    let res_u256 = a_u256 / b_u256;

    assert(res_u256.high == 0_u128, 'result overflow');

    // Re-apply sign
    return Fixed::new(res_u256.low, res_sign);
}

fn eq(a: FixedType, b: FixedType) -> bool {
    return a.mag == b.mag & a.sign == b.sign;
}

// Calculates the natural exponent of x: e^x
fn exp(a: FixedType) -> FixedType {
    return exp2(Fixed::new(26613026195688644984_u128, false) * a);
}

// Calculates the binary exponent of x: 2^x
fn exp2(a: FixedType) -> FixedType {
    if (a.mag == 0_u128) {
        return Fixed::new(ONE_u128, false);
    }

    let (int_part, frac_part) = _split_unsigned(a);
    let int_res = _pow_int(Fixed::new_unscaled(2_u128, false), int_part, false);

    let t8 = Fixed::new(41691949755436_u128, false);
    let t7 = Fixed::new(231817862090993_u128, false);
    let t6 = Fixed::new(2911875592466782_u128, false);
    let t5 = Fixed::new(24539637786416367_u128, false);
    let t4 = Fixed::new(177449490038807528_u128, false);
    let t3 = Fixed::new(1023863119786103800_u128, false);
    let t2 = Fixed::new(4431397849999009866_u128, false);
    let t1 = Fixed::new(12786308590235521577_u128, false);

    let frac_fixed = Fixed::new(frac_part, false);
    let r8 = t8 * frac_fixed;
    let r7 = (r8 + t7) * frac_fixed;
    let r6 = (r7 + t6) * frac_fixed;
    let r5 = (r6 + t5) * frac_fixed;
    let r4 = (r5 + t4) * frac_fixed;
    let r3 = (r4 + t3) * frac_fixed;
    let r2 = (r3 + t2) * frac_fixed;
    let r1 = (r2 + t1) * frac_fixed;
    let frac_res = r1 + Fixed::new(ONE_u128, false);
    let res_u = int_res * frac_res;

    if (a.sign == true) {
        return Fixed::new(ONE_u128, false) / res_u;
    } else {
        return res_u;
    }
}

fn floor(a: FixedType) -> FixedType {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if (rem_u128 == 0_u128) {
        return a;
    } else if (a.sign == false) {
        return Fixed::new_unscaled(div_u128, false);
    } else {
        return Fixed::from_unscaled_felt(-1 * div_u128.into() - 1);
    }
}

fn ge(a: FixedType, b: FixedType) -> bool {
    if (a.sign != b.sign) {
        return !a.sign;
    } else {
        return (a.mag == b.mag) | ((a.mag > b.mag) ^ a.sign);
    }
}

fn gt(a: FixedType, b: FixedType) -> bool {
    if (a.sign != b.sign) {
        return !a.sign;
    } else {
        return (a.mag != b.mag) & ((a.mag > b.mag) ^ a.sign);
    }
}

fn le(a: FixedType, b: FixedType) -> bool {
    if (a.sign != b.sign) {
        return a.sign;
    } else {
        return (a.mag == b.mag) | ((a.mag < b.mag) ^ a.sign);
    }
}

// Calculates the natural logarithm of x: ln(x)
// self must be greater than zero
fn ln(a: FixedType) -> FixedType {
    return Fixed::new(12786308645202655660_u128, false) * log2(a); // ln(2) = 0.693...
}

// Calculates the binary logarithm of x: log2(x)
// self must be greather than zero
fn log2(a: FixedType) -> FixedType {
    match withdraw_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt252>();
            array_append::<felt252>(ref data, 'OOG');
            panic(data);
        },
    }

    assert(a.sign == false, 'must be positive');

    if (a.mag == ONE_u128) {
        return Fixed::new(0_u128, false);
    } else if (a.mag < ONE_u128) {
        // Compute true inverse binary log if 0 < x < 1
        let div = Fixed::new_unscaled(1_u128, false) / a;
        return -log2(div);
    }

    let msb_u128 = _msb(a.mag / 2_u128);
    let divisor = _pow_int(Fixed::new_unscaled(2_u128, false), msb_u128, false);
    let norm = a / divisor;

    let t8 = Fixed::new(167660832607149504_u128, true);
    let t7 = Fixed::new(2284550827067371376_u128, false);
    let t6 = Fixed::new(13804762162529339368_u128, true);
    let t5 = Fixed::new(48676798788932142400_u128, false);
    let t4 = Fixed::new(110928274989790216568_u128, true);
    let t3 = Fixed::new(171296190111888966192_u128, false);
    let t2 = Fixed::new(184599081115266689944_u128, true);
    let t1 = Fixed::new(150429590981271126408_u128, false);
    let t0 = Fixed::new(63187350828072553424_u128, true);

    let r8 = t8 * norm;
    let r7 = (r8 + t7) * norm;
    let r6 = (r7 + t6) * norm;
    let r5 = (r6 + t5) * norm;
    let r4 = (r5 + t4) * norm;
    let r3 = (r4 + t3) * norm;
    let r2 = (r3 + t2) * norm;
    let r1 = (r2 + t1) * norm;
    return r1 + t0 + Fixed::new_unscaled(msb_u128, false);
}

// Calculates the base 10 log of x: log10(x)
// self must be greater than zero
fn log10(a: FixedType) -> FixedType {
    return Fixed::new(5553023288523357132_u128, false) * log2(a); // log10(2) = 0.301...
}

fn lt(a: FixedType, b: FixedType) -> bool {
    if (a.sign != b.sign) {
        return a.sign;
    } else {
        return (a.mag != b.mag) & ((a.mag < b.mag) ^ a.sign);
    }
}

fn mul(a: FixedType, b: FixedType) -> FixedType {
    let res_sign = a.sign ^ b.sign;
    let (high, low) = integer::u128_wide_mul(a.mag, b.mag);
    let res_u256 = u256 { low: low, high: high };
    let ONE_u256 = u256 { low: ONE_u128, high: 0_u128 };
    let (scaled_u256, _) = u256_safe_divmod(res_u256, u256_as_non_zero(ONE_u256));

    assert(scaled_u256.high == 0_u128, 'result overflow');

    // Re-apply sign
    return Fixed::new(scaled_u256.low, res_sign);
}

fn ne(a: FixedType, b: FixedType) -> bool {
    return a.mag != b.mag | a.sign != b.sign;
}

fn neg(a: FixedType) -> FixedType {
    if (a.sign == false) {
        return Fixed::new(a.mag, true);
    } else {
        return Fixed::new(a.mag, false);
    }
}

// Calclates the value of x^y and checks for overflow before returning
// self is a fixed point value
// b is a fixed point value
fn pow(a: FixedType, b: FixedType) -> FixedType {
    let (div_u128, rem_u128) = _split_unsigned(b);

    // use the more performant integer pow when y is an int
    if (rem_u128 == 0_u128) {
        return _pow_int(a, b.mag / ONE_u128, b.sign);
    }

    // x^y = exp(y*ln(x)) for x > 0 will error for x < 0
    return exp(b * ln(a));
}

fn rem(a: FixedType, b: FixedType) -> FixedType {
    return b - (a * floor(a / b));
}

fn round(a: FixedType) -> FixedType {
    let (div_u128, rem_u128) = _split_unsigned(a);

    if (HALF_u128 <= rem_u128) {
        return Fixed::new(ONE_u128 * (div_u128 + 1_u128), a.sign);
    } else {
        return Fixed::new(ONE_u128 * div_u128, a.sign);
    }
}

// Calculates the square root of a fixed point value
// x must be positive
fn sqrt(a: FixedType) -> FixedType {
    assert(a.sign == false, 'must be positive');
    let root = integer::u128_sqrt(a.mag);
    let scale_root = integer::u128_sqrt(ONE_u128);
    let res_u128 = root * ONE_u128 / scale_root;
    return Fixed::new(res_u128, false);
}

fn sub(a: FixedType, b: FixedType) -> FixedType {
    return Fixed::from_felt(a.into() - b.into());
}

// INTERNAL

// Calculates the most significant bit
fn _msb(a: u128) -> u128 {
    match withdraw_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt252>();
            array_append::<felt252>(ref data, 'OOG');
            panic(data);
        },
    }

    if (a <= ONE_u128) {
        return 0_u128;
    }

    return 1_u128 + _msb(a / 2_u128);
}

// Calclates the value of x^y and checks for overflow before returning
// TODO: swap to signed int when available
fn _pow_int(a: FixedType, b: u128, sign: bool) -> FixedType {
    match withdraw_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt252>();
            array_append::<felt252>(ref data, 'OOG');
            panic(data);
        },
    }

    if (sign == true) {
        return Fixed::new(ONE_u128, false) / _pow_int(a, b, false);
    }

    let (div, rem) = integer::u128_safe_divmod(b, integer::u128_as_non_zero(2_u128));

    if (b == 0_u128) {
        return Fixed::new(ONE_u128, false);
    } else if (rem == 0_u128) {
        return _pow_int(a * a, div, false);
    } else {
        return a * _pow_int(a * a, div, false);
    }
}

// Ignores sign and always returns false
fn _split_unsigned(a: FixedType) -> (u128, u128) {
    return integer::u128_safe_divmod(a.mag, integer::u128_as_non_zero(ONE_u128));
}

// Returns the sign of a signed `felt252` as with signed magnitude representation
// true = negative
// false = positive
fn _felt_sign(a: felt252) -> bool {
    return integer::u256_from_felt252(a) > integer::u256_from_felt252(HALF_PRIME);
}

// Returns the absolute value of a signed `felt252`
fn _felt_abs(a: felt252) -> felt252 {
    let a_sign = _felt_sign(a);

    if (a_sign == true) {
        return a * -1;
    } else {
        return a;
    }
}
