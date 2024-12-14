use core::debug::PrintTrait;
use core::integer::{U256DivRem, u256_safe_divmod, u256_as_non_zero, u256_from_felt252};

use core::option::OptionTrait;
use core::result::{ResultTrait, ResultTraitImpl};
use core::traits::{TryInto, Into};
use core::num::traits::WideMul;

use starknet::storage_access::StorePacking;

use cubit::utils;
use cubit::f128::math::{ops, hyp, trig};
use cubit::f64::{Fixed as Fixed64, FixedTrait as FixedTrait64, ONE as ONE_u64};

// CONSTANTS

const PRIME: felt252 = 3618502788666131213697322783095070105623107215331596699973092056135872020480;
const ONE: felt252 = 18446744073709551616; // 2 ** 64
const ONE_u128: u128 = 18446744073709551616_u128; // 2 ** 64
const HALF: felt252 = 9223372036854775808; // 2 ** 63
const HALF_u128: u128 = 9223372036854775808_u128; // 2 ** 63
const MAX_u128: u128 = 340282366920938463463374607431768211455_u128; // 2 ** 128 - 1

// STRUCTS

#[derive(Copy, Drop, Serde)]
struct Fixed {
    mag: u128,
    sign: bool
}

// TRAITS

trait FixedTrait {
    fn ZERO() -> Fixed;
    fn ONE() -> Fixed;

    // Constructors
    fn new(mag: u128, sign: bool) -> Fixed;
    fn new_unscaled(mag: u128, sign: bool) -> Fixed;
    fn from_felt(val: felt252) -> Fixed;
    fn from_unscaled_felt(val: felt252) -> Fixed;

    // Math
    fn abs(self: Fixed) -> Fixed;
    fn ceil(self: Fixed) -> Fixed;
    fn exp(self: Fixed) -> Fixed;
    fn exp2(self: Fixed) -> Fixed;
    fn floor(self: Fixed) -> Fixed;
    fn ln(self: Fixed) -> Fixed;
    fn log2(self: Fixed) -> Fixed;
    fn log10(self: Fixed) -> Fixed;
    fn pow(self: Fixed, b: Fixed) -> Fixed;
    fn round(self: Fixed) -> Fixed;
    fn sqrt(self: Fixed) -> Fixed;

    // Trigonometry
    fn acos(self: Fixed) -> Fixed;
    fn acos_fast(self: Fixed) -> Fixed;
    fn asin(self: Fixed) -> Fixed;
    fn asin_fast(self: Fixed) -> Fixed;
    fn atan(self: Fixed) -> Fixed;
    fn atan_fast(self: Fixed) -> Fixed;
    fn cos(self: Fixed) -> Fixed;
    fn cos_fast(self: Fixed) -> Fixed;
    fn sin(self: Fixed) -> Fixed;
    fn sin_fast(self: Fixed) -> Fixed;
    fn tan(self: Fixed) -> Fixed;
    fn tan_fast(self: Fixed) -> Fixed;

    // Hyperbolic
    fn acosh(self: Fixed) -> Fixed;
    fn asinh(self: Fixed) -> Fixed;
    fn atanh(self: Fixed) -> Fixed;
    fn cosh(self: Fixed) -> Fixed;
    fn sinh(self: Fixed) -> Fixed;
    fn tanh(self: Fixed) -> Fixed;
}

// IMPLS

impl FixedImpl of FixedTrait {
    fn ZERO() -> Fixed {
        return core::num::traits::Zero::zero();
    }

    fn ONE() -> Fixed {
        return core::num::traits::One::one();
    }

    fn new(mag: u128, sign: bool) -> Fixed {
        return Fixed { mag: mag, sign: sign };
    }

    fn new_unscaled(mag: u128, sign: bool) -> Fixed {
        return Self::new(mag * ONE_u128, sign);
    }

    fn from_felt(val: felt252) -> Fixed {
        let mag = core::integer::u128_try_from_felt252(utils::felt_abs(val)).unwrap();
        return Self::new(mag, utils::felt_sign(val));
    }

    fn from_unscaled_felt(val: felt252) -> Fixed {
        return Self::from_felt(val * ONE);
    }

    fn abs(self: Fixed) -> Fixed {
        return ops::abs(self);
    }

    fn acos(self: Fixed) -> Fixed {
        return trig::acos(self);
    }

    fn acos_fast(self: Fixed) -> Fixed {
        return trig::acos_fast(self);
    }

    fn acosh(self: Fixed) -> Fixed {
        return hyp::acosh(self);
    }

    fn asin(self: Fixed) -> Fixed {
        return trig::asin(self);
    }

    fn asin_fast(self: Fixed) -> Fixed {
        return trig::asin_fast(self);
    }

    fn asinh(self: Fixed) -> Fixed {
        return hyp::asinh(self);
    }

    fn atan(self: Fixed) -> Fixed {
        return trig::atan(self);
    }

    fn atan_fast(self: Fixed) -> Fixed {
        return trig::atan_fast(self);
    }

    fn atanh(self: Fixed) -> Fixed {
        return hyp::atanh(self);
    }

    fn ceil(self: Fixed) -> Fixed {
        return ops::ceil(self);
    }

    fn cos(self: Fixed) -> Fixed {
        return trig::cos(self);
    }

    fn cos_fast(self: Fixed) -> Fixed {
        return trig::cos_fast(self);
    }

    fn cosh(self: Fixed) -> Fixed {
        return hyp::cosh(self);
    }

    fn floor(self: Fixed) -> Fixed {
        return ops::floor(self);
    }

    // Calculates the natural exponent of x: e^x
    fn exp(self: Fixed) -> Fixed {
        return ops::exp(self);
    }

    // Calculates the binary exponent of x: 2^x
    fn exp2(self: Fixed) -> Fixed {
        return ops::exp2(self);
    }

    // Calculates the natural logarithm of x: ln(x)
    // self must be greater than zero
    fn ln(self: Fixed) -> Fixed {
        return ops::ln(self);
    }

    // Calculates the binary logarithm of x: log2(x)
    // self must be greather than zero
    fn log2(self: Fixed) -> Fixed {
        return ops::log2(self);
    }

    // Calculates the base 10 log of x: log10(x)
    // self must be greater than zero
    fn log10(self: Fixed) -> Fixed {
        return ops::log10(self);
    }

    // Calclates the value of x^y and checks for overflow before returning
    // self is a fixed point value
    // b is a fixed point value
    fn pow(self: Fixed, b: Fixed) -> Fixed {
        return ops::pow(self, b);
    }

    fn round(self: Fixed) -> Fixed {
        return ops::round(self);
    }

    fn sin(self: Fixed) -> Fixed {
        return trig::sin(self);
    }

    fn sin_fast(self: Fixed) -> Fixed {
        return trig::sin_fast(self);
    }

    fn sinh(self: Fixed) -> Fixed {
        return hyp::sinh(self);
    }

    // Calculates the square root of a fixed point value
    // x must be positive
    fn sqrt(self: Fixed) -> Fixed {
        return ops::sqrt(self);
    }

    fn tan(self: Fixed) -> Fixed {
        return trig::tan(self);
    }

    fn tan_fast(self: Fixed) -> Fixed {
        return trig::tan_fast(self);
    }

    fn tanh(self: Fixed) -> Fixed {
        return hyp::tanh(self);
    }
}

impl Fixed128TryIntoFixed64 of TryInto<Fixed, Fixed64> {
    fn try_into(self: Fixed) -> Option<Fixed64> {
        let max = 0x1000000000000000000000000; // 2^96

        if self.mag >= max {
            return Option::None(());
        } else {
            let mag = (self.mag / ONE_u64.into()).try_into().unwrap();
            return Option::Some(FixedTrait64::new(mag, self.sign));
        }
    }
}

impl FixedPrint of PrintTrait<Fixed> {
    fn print(self: Fixed) {
        self.sign.print();
        self.mag.print();
    }
}

// Into a raw felt without unscaling
impl FixedInto of Into<Fixed, felt252> {
    fn into(self: Fixed) -> felt252 {
        let mag_felt = self.mag.into();

        if self.sign {
            return mag_felt * -1;
        } else {
            return mag_felt * 1;
        }
    }
}

impl FixedTryIntoU128 of TryInto<Fixed, u128> {
    fn try_into(self: Fixed) -> Option<u128> {
        if self.sign {
            return Option::None(());
        } else {
            // Unscale the magnitude and round down
            return Option::Some(self.mag / ONE_u128);
        }
    }
}

impl FixedTryIntoU64 of TryInto<Fixed, u64> {
    fn try_into(self: Fixed) -> Option<u64> {
        if self.sign {
            return Option::None(());
        } else {
            // Unscale the magnitude and round down
            return Into::<u128, felt252>::into(self.mag / ONE_u128).try_into();
        }
    }
}

impl FixedTryIntoU32 of TryInto<Fixed, u32> {
    fn try_into(self: Fixed) -> Option<u32> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return Into::<u128, felt252>::into(self.mag / ONE_u128).try_into();
        }
    }
}

impl FixedTryIntoU16 of TryInto<Fixed, u16> {
    fn try_into(self: Fixed) -> Option<u16> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return Into::<u128, felt252>::into(self.mag / ONE_u128).try_into();
        }
    }
}

impl FixedTryIntoU8 of TryInto<Fixed, u8> {
    fn try_into(self: Fixed) -> Option<u8> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return Into::<u128, felt252>::into(self.mag / ONE_u128).try_into();
        }
    }
}

impl U8IntoFixed of Into<u8, Fixed> {
    fn into(self: u8) -> Fixed {
        FixedTrait::new_unscaled(self.into(), false)
    }
}

impl U16IntoFixed of Into<u16, Fixed> {
    fn into(self: u16) -> Fixed {
        FixedTrait::new_unscaled(self.into(), false)
    }
}

impl U32IntoFixed of Into<u32, Fixed> {
    fn into(self: u32) -> Fixed {
        FixedTrait::new_unscaled(self.into(), false)
    }
}

impl U64IntoFixed of Into<u64, Fixed> {
    fn into(self: u64) -> Fixed {
        FixedTrait::new_unscaled(self.into(), false)
    }
}

impl U128IntoFixed of Into<u128, Fixed> {
    fn into(self: u128) -> Fixed {
        FixedTrait::new_unscaled(self.into(), false)
    }
}

impl U256TryIntoFixed of TryInto<u256, Fixed> {
    fn try_into(self: u256) -> Option<Fixed> {
        if self.high > 0 {
            return Option::None(());
        } else {
            return Option::Some(FixedTrait::new_unscaled(self.try_into().unwrap(), false));
        }
    }
}

impl I8IntoFixed of Into<i8, Fixed> {
    fn into(self: i8) -> Fixed {
        if 0 <= self {
            return FixedTrait::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return FixedTrait::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I16IntoFixed of Into<i16, Fixed> {
    fn into(self: i16) -> Fixed {
        if 0 <= self {
            return FixedTrait::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return FixedTrait::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I32IntoFixed of Into<i32, Fixed> {
    fn into(self: i32) -> Fixed {
        if 0 <= self {
            return FixedTrait::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return FixedTrait::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I64IntoFixed of Into<i64, Fixed> {
    fn into(self: i64) -> Fixed {
        if 0 <= self {
            return FixedTrait::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return FixedTrait::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl I128IntoFixed of Into<i128, Fixed> {
    fn into(self: i128) -> Fixed {
        if 0 <= self {
            return FixedTrait::new_unscaled(self.try_into().unwrap(), false);
        } else {
            return FixedTrait::new_unscaled((-self).try_into().unwrap(), true);
        }
    }
}

impl FixedPartialEq of PartialEq<Fixed> {
    #[inline(always)]
    fn eq(lhs: @Fixed, rhs: @Fixed) -> bool {
        return ops::eq(lhs, rhs);
    }

    #[inline(always)]
    fn ne(lhs: @Fixed, rhs: @Fixed) -> bool {
        return ops::ne(lhs, rhs);
    }
}

impl FixedAdd of Add<Fixed> {
    fn add(lhs: Fixed, rhs: Fixed) -> Fixed {
        return ops::add(lhs, rhs);
    }
}

impl FixedAddEq of AddEq<Fixed> {
    #[inline(always)]
    fn add_eq(ref self: Fixed, other: Fixed) {
        self = Add::add(self, other);
    }
}

impl FixedSub of Sub<Fixed> {
    fn sub(lhs: Fixed, rhs: Fixed) -> Fixed {
        return ops::sub(lhs, rhs);
    }
}

impl FixedSubEq of SubEq<Fixed> {
    #[inline(always)]
    fn sub_eq(ref self: Fixed, other: Fixed) {
        self = Sub::sub(self, other);
    }
}

impl FixedMul of Mul<Fixed> {
    fn mul(lhs: Fixed, rhs: Fixed) -> Fixed {
        return ops::mul(lhs, rhs);
    }
}

impl FixedMulEq of MulEq<Fixed> {
    #[inline(always)]
    fn mul_eq(ref self: Fixed, other: Fixed) {
        self = Mul::mul(self, other);
    }
}

impl FixedDiv of Div<Fixed> {
    fn div(lhs: Fixed, rhs: Fixed) -> Fixed {
        return ops::div(lhs, rhs);
    }
}

impl FixedDivEq of DivEq<Fixed> {
    #[inline(always)]
    fn div_eq(ref self: Fixed, other: Fixed) {
        self = Div::div(self, other);
    }
}

impl FixedPartialOrd of PartialOrd<Fixed> {
    #[inline(always)]
    fn ge(lhs: Fixed, rhs: Fixed) -> bool {
        return ops::ge(lhs, rhs);
    }

    #[inline(always)]
    fn gt(lhs: Fixed, rhs: Fixed) -> bool {
        return ops::gt(lhs, rhs);
    }

    #[inline(always)]
    fn le(lhs: Fixed, rhs: Fixed) -> bool {
        return ops::le(lhs, rhs);
    }

    #[inline(always)]
    fn lt(lhs: Fixed, rhs: Fixed) -> bool {
        return ops::lt(lhs, rhs);
    }
}

impl FixedNeg of Neg<Fixed> {
    #[inline(always)]
    fn neg(a: Fixed) -> Fixed {
        return ops::neg(a);
    }
}

impl FixedRem of Rem<Fixed> {
    #[inline(always)]
    fn rem(lhs: Fixed, rhs: Fixed) -> Fixed {
        return ops::rem(lhs, rhs);
    }
}

impl PackFixed of StorePacking<Fixed, felt252> {
    fn pack(value: Fixed) -> felt252 {
        let MAX_MAG_PLUS_ONE = 0x100000000000000000000000000000000; // 2**128
        let packed_sign = MAX_MAG_PLUS_ONE * value.sign.into();
        value.mag.into() + packed_sign
    }

    fn unpack(value: felt252) -> Fixed {
        let (q, r) = U256DivRem::div_rem(
            value.into(), u256_as_non_zero(0x100000000000000000000000000000000)
        );
        let mag: u128 = r.try_into().unwrap();
        let sign: bool = q.into() == 1;
        Fixed { mag: mag, sign: sign }
    }
}


impl FixedZero of core::num::traits::Zero<Fixed> {
    fn zero() -> Fixed {
        Fixed { mag: 0, sign: false }
    }
    #[inline(always)]
    fn is_zero(self: @Fixed) -> bool {
        *self.mag == 0
    }
    #[inline(always)]
    fn is_non_zero(self: @Fixed) -> bool {
        !self.is_zero()
    }
}

// One trait implementations
impl FixedOne of core::num::traits::One<Fixed> {
    fn one() -> Fixed {
        Fixed { mag: ONE_u128, sign: false }
    }
    #[inline(always)]
    fn is_one(self: @Fixed) -> bool {
        *self == Self::one()
    }
    #[inline(always)]
    fn is_non_one(self: @Fixed) -> bool {
        !self.is_one()
    }
}


// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use core::traits::Into;
    use cubit::f128::test::helpers::assert_precise;

    use super::{FixedTrait, ops, ONE, HALF, Fixed64, ONE_u128, PackFixed, ONE_u64};

    #[test]
    #[available_gas(10000000)]
    fn test_ceil() {
        let a = FixedTrait::from_felt(53495557813757699680); // 2.9
        assert(ops::ceil(a).into() == 3 * ONE, 'invalid pos decimal');

        let a = FixedTrait::from_felt(-53495557813757699680); // -2.9
        assert(ops::ceil(a).into() == -2 * ONE, 'invalid neg decimal');

        let a = FixedTrait::from_unscaled_felt(4);
        assert(ops::ceil(a).into() == 4 * ONE, 'invalid pos integer');

        let a = FixedTrait::from_unscaled_felt(-4);
        assert(ops::ceil(a).into() == -4 * ONE, 'invalid neg integer');

        let a = FixedTrait::from_unscaled_felt(0);
        assert(ops::ceil(a).into() == 0, 'invalid zero');

        let a = FixedTrait::from_felt(HALF);
        assert(ops::ceil(a).into() == 1 * ONE, 'invalid pos half');

        let a = FixedTrait::from_felt(-1 * HALF);
        assert(ops::ceil(a).into() == 0, 'invalid neg half');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_floor() {
        let a = FixedTrait::from_felt(53495557813757699680); // 2.9
        assert(ops::floor(a).into() == 2 * ONE, 'invalid pos decimal');

        let a = FixedTrait::from_felt(-53495557813757699680); // -2.9
        assert(ops::floor(a).into() == -3 * ONE, 'invalid neg decimal');

        let a = FixedTrait::from_unscaled_felt(4);
        assert(ops::floor(a).into() == 4 * ONE, 'invalid pos integer');

        let a = FixedTrait::from_unscaled_felt(-4);
        assert(ops::floor(a).into() == -4 * ONE, 'invalid neg integer');

        let a = FixedTrait::from_unscaled_felt(0);
        assert(ops::floor(a).into() == 0, 'invalid zero');

        let a = FixedTrait::from_felt(HALF);
        assert(ops::floor(a).into() == 0, 'invalid pos half');

        let a = FixedTrait::from_felt(-1 * HALF);
        assert(ops::floor(a).into() == -1 * ONE, 'invalid neg half');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_round() {
        let a = FixedTrait::from_felt(53495557813757699680); // 2.9
        assert(ops::round(a).into() == 3 * ONE, 'invalid pos decimal');

        let a = FixedTrait::from_felt(-53495557813757699680); // -2.9
        assert(ops::round(a).into() == -3 * ONE, 'invalid neg decimal');

        let a = FixedTrait::from_unscaled_felt(4);
        assert(ops::round(a).into() == 4 * ONE, 'invalid pos integer');

        let a = FixedTrait::from_unscaled_felt(-4);
        assert(ops::round(a).into() == -4 * ONE, 'invalid neg integer');

        let a = FixedTrait::from_unscaled_felt(0);
        assert(ops::round(a).into() == 0, 'invalid zero');

        let a = FixedTrait::from_felt(HALF);
        assert(ops::round(a).into() == 1 * ONE, 'invalid pos half');

        let a = FixedTrait::from_felt(-1 * HALF);
        assert(ops::round(a).into() == -1 * ONE, 'invalid neg half');
    }

    #[test]
    #[should_panic]
    fn test_sqrt_fail() {
        let a = FixedTrait::from_unscaled_felt(-25);
        ops::sqrt(a);
    }

    #[test]
    #[available_gas(10000000)]
    fn test_sqrt() {
        let a = FixedTrait::from_unscaled_felt(0);
        assert(ops::sqrt(a).into() == 0, 'invalid zero root');

        let a = FixedTrait::from_unscaled_felt(1);
        assert(ops::sqrt(a).into() == ONE, 'invalid one root');

        let a = FixedTrait::from_unscaled_felt(25);
        assert_precise(ops::sqrt(a), 5 * ONE, 'invalid 25 root', Option::None(())); // 5

        let a = FixedTrait::from_unscaled_felt(81);
        assert_precise(ops::sqrt(a), 9 * ONE, 'invalid 81 root', Option::None(())); // 9

        let a = FixedTrait::from_felt(1152921504606846976); // 0.0625
        assert_precise(
            ops::sqrt(a), 4611686018427387904, 'invalid decimal root', Option::None(())
        ); // 0.25
    }

    #[test]
    #[available_gas(2750000)]
    fn test_pow_int() {
        let a = FixedTrait::from_unscaled_felt(3);
        let b = FixedTrait::from_unscaled_felt(4);
        assert(ops::pow(a, b).into() == 81 * ONE, 'invalid pos base power');

        let a = FixedTrait::from_unscaled_felt(50);
        let b = FixedTrait::from_unscaled_felt(5);
        assert(ops::pow(a, b).into() == 312500000 * ONE, 'invalid big power');

        let a = FixedTrait::from_unscaled_felt(-3);
        let b = FixedTrait::from_unscaled_felt(2);
        assert(ops::pow(a, b).into() == 9 * ONE, 'invalid neg base');

        let a = FixedTrait::from_unscaled_felt(3);
        let b = FixedTrait::from_unscaled_felt(-2);
        assert_precise(
            ops::pow(a, b), 2049638230412172401, 'invalid neg power', Option::None(())
        ); // 0.1111111111111111

        let a = FixedTrait::from_unscaled_felt(-3);
        let b = FixedTrait::from_unscaled_felt(-2);
        assert_precise(
            ops::pow(a, b), 2049638230412172401, 'invalid neg base power', Option::None(())
        );

        let a = FixedTrait::from_felt(9223372036854775808);
        let b = FixedTrait::from_unscaled_felt(2);
        assert_precise(
            ops::pow(a, b), 4611686018427387904, 'invalid frac base power', Option::None(())
        );
    }

    #[test]
    #[available_gas(10000000)]
    fn test_pow_frac() {
        let a = FixedTrait::from_unscaled_felt(3);
        let b = FixedTrait::from_felt(9223372036854775808); // 0.5
        assert_precise(
            ops::pow(a, b), 31950697969885030000, 'invalid pos base power', Option::None(())
        ); // 1.7320508075688772

        let a = FixedTrait::from_felt(2277250555899444146995); // 123.45
        let b = FixedTrait::from_felt(-27670116110564327424); // -1.5
        assert_precise(
            ops::pow(a, b), 13448785939318150, 'invalid pos base power', Option::None(())
        ); // 0.0007290601466350622
    }

    #[test]
    #[available_gas(1000000)]
    fn test_exp() {
        let a = FixedTrait::new_unscaled(2_u128, false);
        assert_precise(
            ops::exp(a), 136304026803256380000, 'invalid exp of 2', Option::None(())
        ); // 7.3890560989306495

        let a = FixedTrait::new_unscaled(0_u128, false);
        assert(ops::exp(a).into() == ONE, 'invalid exp of 0');

        let a = FixedTrait::new_unscaled(2_u128, true);
        assert_precise(
            ops::exp(a), 2496495334008789000, 'invalid exp of -2', Option::None(())
        ); // 0.1353352832366127
    }

    #[test]
    #[available_gas(1400000)]
    fn test_exp2() {
        let a = FixedTrait::new(27670116110564327424_u128, false); // 1.5
        assert_precise(
            ops::exp2(a), 52175271301331124000, 'invalid exp2 of 1.5', Option::None(())
        ); // 2.82842712474619

        let a = FixedTrait::new_unscaled(2_u128, false);
        assert(ops::exp2(a).into() == 4 * ONE, 'invalid exp2 of 2'); // 4

        let a = FixedTrait::new_unscaled(0_u128, false);
        assert(ops::exp2(a).into() == ONE, 'invalid exp2 of 0');

        let a = FixedTrait::new_unscaled(2_u128, true);
        assert_precise(
            ops::exp2(a), 4611686018427387904, 'invalid exp2 of -2', Option::None(())
        ); // 0.25

        let a = FixedTrait::new(27670116110564327424_u128, true); // -1.5
        assert_precise(
            ops::exp2(a), 6521908912666391000, 'invalid exp2 of -1.5', Option::None(())
        ); // 0.35355339059327373
    }

    #[test]
    #[available_gas(1200000)]
    fn test_ln() {
        let a = FixedTrait::from_unscaled_felt(1);
        assert(ops::ln(a).into() == 0, 'invalid ln of 1');

        let a = FixedTrait::from_felt(50143449209799256683); // e
        assert_precise(ops::ln(a), ONE, 'invalid ln of e', Option::None(()));

        let a = FixedTrait::from_felt(9223372036854775808); // 0.5
        assert_precise(
            ops::ln(a), -12786308645202655000, 'invalid ln of 0.5', Option::None(())
        ); // -0.6931471805599453
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log2() {
        let a = FixedTrait::from_unscaled_felt(32);
        assert_precise(ops::log2(a), 5 * ONE, 'invalid log2 32', Option::None(()));

        let a = FixedTrait::from_unscaled_felt(1234);
        assert_precise(
            ops::log2(a), 189431951710772170000, 'invalid log2 1234', Option::None(())
        ); // 10.269126679149418

        let a = FixedTrait::from_felt(1035286617648801165344); // 56.123
        assert_precise(
            ops::log2(a), 107185179502756360000, 'invalid log2 56.123', Option::None(())
        ); // 5.8105202237568605
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log10() {
        let a = FixedTrait::from_unscaled_felt(100);
        assert_precise(ops::log10(a), 2 * ONE, 'invalid log10', Option::None(()));

        let a = FixedTrait::from_unscaled_felt(1);
        assert(ops::log10(a).into() == 0, 'invalid log10');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_eq() {
        let a = FixedTrait::from_unscaled_felt(42);
        let b = FixedTrait::from_unscaled_felt(42);
        let c = ops::eq(@a, @b);
        assert(c == true, 'invalid result');

        let a = FixedTrait::from_unscaled_felt(42);
        let b = FixedTrait::from_unscaled_felt(-42);
        let c = ops::eq(@a, @b);
        assert(c == false, 'invalid result');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_ne() {
        let a = FixedTrait::from_unscaled_felt(42);
        let b = FixedTrait::from_unscaled_felt(42);
        let c = ops::ne(@a, @b);
        assert(c == false, 'invalid result');

        let a = FixedTrait::from_unscaled_felt(42);
        let b = FixedTrait::from_unscaled_felt(-42);
        let c = ops::ne(@a, @b);
        assert(c == true, 'invalid result');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_add() {
        let a = FixedTrait::from_unscaled_felt(1);
        let b = FixedTrait::from_unscaled_felt(2);
        assert(ops::add(a, b) == FixedTrait::from_unscaled_felt(3), 'invalid result');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_sub() {
        let a = FixedTrait::from_unscaled_felt(5);
        let b = FixedTrait::from_unscaled_felt(2);
        let c = ops::sub(a, b);
        assert(c.into() == 3 * ONE, 'false result invalid');

        let c = ops::sub(b, a);
        assert(c.into() == -3 * ONE, 'true result invalid');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_mul_pos() {
        let a = FixedTrait::from_unscaled_felt(5);
        let b = FixedTrait::from_unscaled_felt(2);
        let c = ops::mul(a, b);
        assert(c.into() == 10 * ONE, 'invalid result');

        let a = FixedTrait::from_unscaled_felt(9);
        let b = FixedTrait::from_unscaled_felt(9);
        let c = ops::mul(a, b);
        assert(c.into() == 81 * ONE, 'invalid result');

        let a = FixedTrait::from_unscaled_felt(4294967295);
        let b = FixedTrait::from_unscaled_felt(4294967295);
        let c = ops::mul(a, b);
        assert(c.into() == 18446744065119617025 * ONE, 'invalid huge mul');

        let a = FixedTrait::from_felt(23058430092136939520); // 1.25
        let b = FixedTrait::from_felt(42427511369531968716); // 2.3
        let c = ops::mul(a, b);
        assert(c.into() == 53034389211914960895, 'invalid result'); // 2.875

        let a = FixedTrait::from_unscaled_felt(0);
        let b = FixedTrait::from_felt(42427511369531968716); // 2.3
        let c = ops::mul(a, b);
        assert(c.into() == 0, 'invalid result');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_mul_neg() {
        let a = FixedTrait::from_unscaled_felt(5);
        let b = FixedTrait::from_unscaled_felt(-2);
        let c = ops::mul(a, b);
        assert(c.into() == -10 * ONE, 'true result invalid');

        let a = FixedTrait::from_unscaled_felt(-5);
        let b = FixedTrait::from_unscaled_felt(-2);
        let c = ops::mul(a, b);
        assert(c.into() == 10 * ONE, 'false result invalid');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_div() {
        let a = FixedTrait::from_unscaled_felt(10);
        let b = FixedTrait::from_felt(53495557813757699680); // 2.9
        let c = ops::div(a, b);
        assert_precise(
            c, 63609462323136390000, 'invalid pos decimal', Option::None(())
        ); // 3.4482758620689657

        let a = FixedTrait::from_unscaled_felt(10);
        let b = FixedTrait::from_unscaled_felt(5);
        let c = ops::div(a, b);
        assert(c.into() == 2 * ONE, 'invalid pos integer'); // 2

        let a = FixedTrait::from_unscaled_felt(-2);
        let b = FixedTrait::from_unscaled_felt(5);
        let c = ops::div(a, b);
        assert(c.into() == -7378697629483820646, 'invalid neg decimal'); // 0.4

        let a = FixedTrait::from_unscaled_felt(-1000);
        let b = FixedTrait::from_unscaled_felt(12500);
        let c = ops::div(a, b);
        assert(c.into() == -1475739525896764129, 'invalid neg decimal'); // 0.08

        let a = FixedTrait::from_unscaled_felt(-10);
        let b = FixedTrait::from_unscaled_felt(123456789);
        let c = ops::div(a, b);
        assert_precise(
            c, -1494186283568, 'invalid neg decimal', Option::None(())
        ); // 8.100000073706917e-8

        let a = FixedTrait::from_unscaled_felt(123456789);
        let b = FixedTrait::from_unscaled_felt(-10);
        let c = ops::div(a, b);
        assert_precise(
            c, -227737579084496056114112102, 'invalid neg decimal', Option::None(())
        ); // -12345678.9
    }

    #[test]
    #[available_gas(10000000)]
    fn test_le() {
        let a = FixedTrait::from_unscaled_felt(1);
        let b = FixedTrait::from_unscaled_felt(0);
        let c = FixedTrait::from_unscaled_felt(-1);

        assert(ops::le(a, a), 'a <= a');
        assert(ops::le(a, b) == false, 'a <= b');
        assert(ops::le(a, c) == false, 'a <= c');

        assert(ops::le(b, a), 'b <= a');
        assert(ops::le(b, b), 'b <= b');
        assert(ops::le(b, c) == false, 'b <= c');

        assert(ops::le(c, a), 'c <= a');
        assert(ops::le(c, b), 'c <= b');
        assert(ops::le(c, c), 'c <= c');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_lt() {
        let a = FixedTrait::from_unscaled_felt(1);
        let b = FixedTrait::from_unscaled_felt(0);
        let c = FixedTrait::from_unscaled_felt(-1);

        assert(ops::lt(a, a) == false, 'a < a');
        assert(ops::lt(a, b) == false, 'a < b');
        assert(ops::lt(a, c) == false, 'a < c');

        assert(ops::lt(b, a), 'b < a');
        assert(ops::lt(b, b) == false, 'b < b');
        assert(ops::lt(b, c) == false, 'b < c');

        assert(ops::lt(c, a), 'c < a');
        assert(ops::lt(c, b), 'c < b');
        assert(ops::lt(c, c) == false, 'c < c');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_ge() {
        let a = FixedTrait::from_unscaled_felt(1);
        let b = FixedTrait::from_unscaled_felt(0);
        let c = FixedTrait::from_unscaled_felt(-1);

        assert(ops::ge(a, a), 'a >= a');
        assert(ops::ge(a, b), 'a >= b');
        assert(ops::ge(a, c), 'a >= c');

        assert(ops::ge(b, a) == false, 'b >= a');
        assert(ops::ge(b, b), 'b >= b');
        assert(ops::ge(b, c), 'b >= c');

        assert(ops::ge(c, a) == false, 'c >= a');
        assert(ops::ge(c, b) == false, 'c >= b');
        assert(ops::ge(c, c), 'c >= c');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_gt() {
        let a = FixedTrait::from_unscaled_felt(1);
        let b = FixedTrait::from_unscaled_felt(0);
        let c = FixedTrait::from_unscaled_felt(-1);

        assert(ops::gt(a, a) == false, 'a > a');
        assert(ops::gt(a, b), 'a > b');
        assert(ops::gt(a, c), 'a > c');

        assert(ops::gt(b, a) == false, 'b > a');
        assert(ops::gt(b, b) == false, 'b > b');
        assert(ops::gt(b, c), 'b > c');

        assert(ops::gt(c, a) == false, 'c > a');
        assert(ops::gt(c, b) == false, 'c > b');
        assert(ops::gt(c, c) == false, 'c > c');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_rem() {
        let a = FixedTrait::new_unscaled(10_u128, false);
        let b = FixedTrait::new_unscaled(3_u128, false);
        assert(ops::rem(a, b).into() == 1 * ONE, 'invalid remainder');

        let a = FixedTrait::new_unscaled(10_u128, false);
        let b = FixedTrait::new_unscaled(3_u128, true);
        assert(ops::rem(a, b) == FixedTrait::new(2_u128 * ONE_u128, true), 'invalid remainder');
    }

    #[test]
    fn test_try_into() {
        let mut a = FixedTrait::new_unscaled(42, false);
        assert(a.try_into().unwrap() == 42_u128, 'invalid u128 conversion');
        assert(a.try_into().unwrap() == 42_u64, 'invalid u64 conversion');
        assert(a.try_into().unwrap() == 42_u32, 'invalid u32 conversion');
        assert(a.try_into().unwrap() == 42_u16, 'invalid u16 conversion');
        assert(a.try_into().unwrap() == 42_u8, 'invalid u8 conversion');
    }

    fn test_reverse_try() {
        let a = FixedTrait::new_unscaled(42, false);
        let b = FixedTrait::new_unscaled(42, true);
        assert(42_u128.into() == a, 'invalid conversion from u128');
        assert(42_u64.into() == a, 'invalid conversion from u64');
        assert(42_u32.into() == a, 'invalid conversion from u32');
        assert(42_u16.into() == a, 'invalid conversion from u16');
        assert(42_u8.into() == a, 'invalid conversion from u8');

        assert(42_i128.into() == a, 'invalid conversion from i128');
        assert(42_i64.into() == a, 'invalid conversion from i64');
        assert(42_i32.into() == a, 'invalid conversion from i32');
        assert(42_i16.into() == a, 'invalid conversion from i16');
        assert(42_i8.into() == a, 'invalid conversion from i8');

        assert((-42_i128).into() == b, 'invalid conversion from - i128');
        assert((-42_i64).into() == b, 'invalid conversion from - i64');
        assert((-42_i32).into() == b, 'invalid conversion from - i32');
        assert((-42_i16).into() == b, 'invalid conversion from - i16');
        assert((-42_i8).into() == b, 'invalid conversion from - i8');
    }

    fn test_reverse_try_into() {
        let mut a = FixedTrait::new_unscaled(42, false);
        assert(a == 42_u256.try_into().unwrap(), 'conversion from invalid u256');
    }

    #[test]
    #[should_panic]
    fn test_try_into_fail() {
        let mut a = FixedTrait::new_unscaled(42, true);
        let _b: u128 = a.try_into().unwrap();
    }

    #[test]
    fn test_try_into_f64() {
        let a = FixedTrait::new_unscaled(42, true);
        let b: Fixed64 = a.try_into().unwrap();
        assert(b.mag == 42 * ONE_u64, 'invalid conversion');
    }

    #[test]
    #[should_panic]
    fn test_try_into_f64_fail() {
        let a = FixedTrait::new_unscaled(ONE_u64.into(), true);
        let _b: Fixed64 = a.try_into().unwrap();
    }

    #[available_gas(10000000)]
    #[test]
    fn test_packing() {
        let num1 = FixedTrait::new_unscaled(1500, true);
        let num2 = FixedTrait::new_unscaled(1500, false);
        let num3 = FixedTrait::new_unscaled(1900, true);
        let num4 = FixedTrait::new_unscaled(1900, false);
        let num5 = FixedTrait::new(20813682699295371264, true); // 1.128312 * 2**64
        let num6 = FixedTrait::new(20813682699295371264, false);
        let num7 = FixedTrait::new(2079202843536212642234368, true); // 112_713.812 * 2**64
        let num8 = FixedTrait::new(2079202843536212642234368, false);

        // Test packing
        let pack1 = PackFixed::pack(num1);
        let pack2 = PackFixed::pack(num2);
        let pack3 = PackFixed::pack(num3);
        let pack4 = PackFixed::pack(num4);
        let pack5 = PackFixed::pack(num5);
        let pack6 = PackFixed::pack(num6);
        let pack7 = PackFixed::pack(num7);
        let pack8 = PackFixed::pack(num8);

        assert(pack1 == 340282366920938491133490717996095635456, 'Pack 1 Failed');
        assert(pack2 == 27670116110564327424000, 'Pack 2 failed');
        assert(pack3 == 340282366920938498512188347479916281856, 'Pack 3 failed');
        assert(pack4 == 35048813740048148070400, 'Pack 4 failed');
        assert(pack5 == 340282366920938463484188290131063582720, 'Pack 5 failed');
        assert(pack6 == 20813682699295371264, 'Pack 6 failed');
        assert(pack7 == 340282366920940542666218143644410445824, 'Pack 7 failed');
        assert(pack8 == 2079202843536212642234368, 'Pack 8 failed');

        // Test unpacking
        let unpack1 = PackFixed::unpack(pack1);
        let unpack2 = PackFixed::unpack(pack2);
        let unpack3 = PackFixed::unpack(pack3);
        let unpack4 = PackFixed::unpack(pack4);
        let unpack5 = PackFixed::unpack(pack5);
        let unpack6 = PackFixed::unpack(pack6);
        let unpack7 = PackFixed::unpack(pack7);
        let unpack8 = PackFixed::unpack(pack8);

        assert(unpack1 == num1, 'unpack 1 failed');
        assert(unpack2 == num2, 'unpack 2 failed');
        assert(unpack3 == num3, 'unpack 3 failed');
        assert(unpack4 == num4, 'unpack 4 failed');
        assert(unpack5 == num5, 'unpack 5 failed');
        assert(unpack6 == num6, 'unpack 6 failed');
        assert(unpack7 == num7, 'unpack 7 failed');
        assert(unpack8 == num8, 'unpack 8 failed');
    }
}
