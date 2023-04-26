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
        return core::abs(self);
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
        return core::ceil(self);
    }

    fn cos(self: FixedType) -> FixedType {
        return trig::cos(self);
    }

    fn cosh(self: FixedType) -> FixedType {
        return hyp::cosh(self);
    }

    fn floor(self: FixedType) -> FixedType {
        return core::floor(self);
    }

    // Calculates the natural exponent of x: e^x
    fn exp(self: FixedType) -> FixedType {
        return core::exp(self);
    }

    // Calculates the binary exponent of x: 2^x
    fn exp2(self: FixedType) -> FixedType {
        return core::exp2(self);
    }

    // Calculates the natural logarithm of x: ln(x)
    // self must be greater than zero
    fn ln(self: FixedType) -> FixedType {
        return core::ln(self);
    }

    // Calculates the binary logarithm of x: log2(x)
    // self must be greather than zero
    fn log2(self: FixedType) -> FixedType {
        return core::log2(self);
    }

    // Calculates the base 10 log of x: log10(x)
    // self must be greater than zero
    fn log10(self: FixedType) -> FixedType {
        return core::log10(self);
    }

    // Calclates the value of x^y and checks for overflow before returning
    // self is a fixed point value
    // b is a fixed point value
    fn pow(self: FixedType, b: FixedType) -> FixedType {
        return core::pow(self, b);
    }

    fn round(self: FixedType) -> FixedType {
        return core::round(self);
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
        return core::sqrt(self);
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
        return core::neg(a);
    }
}

impl FixedRem of Rem::<FixedType> {
    #[inline(always)]
    fn rem(lhs: FixedType, rhs: FixedType) -> FixedType {
        return core::rem(lhs, rhs);
    }
}


// INTERNAL

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
