use core::debug::PrintTrait;

use core::integer::{U128DivRem, u128_as_non_zero};
use core::option::OptionTrait;
use core::result::{ResultTrait, ResultTraitImpl};
use core::traits::{TryInto, Into};

use starknet::storage_access::StorePacking;

use cubit::utils;
use cubit::f64::math::{ops, hyp, trig};
use cubit::f128::{Fixed as Fixed128, FixedTrait as FixedTrait128, ONE_u128};

// CONSTANTS

const TWO: u64 = 8589934592; // 2 ** 33
const ONE: u64 = 4294967296; // 2 ** 32
const HALF: u64 = 2147483648; // 2 ** 31
const MAX_u64: u128 = 18_446_744_073_709_551_615; //2**64 - 1

// STRUCTS

#[derive(Copy, Drop, Serde)]
struct Fixed {
    mag: u64,
    sign: bool
}

// TRAITS

trait FixedTrait {
    fn ZERO() -> Fixed;
    fn ONE() -> Fixed;

    // Constructors
    fn new(mag: u64, sign: bool) -> Fixed;
    fn new_unscaled(mag: u64, sign: bool) -> Fixed;
    fn from_felt(val: felt252) -> Fixed;
    fn from_unscaled_felt(val: felt252) -> Fixed;

    // // Math
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

impl FixedImpl of FixedTrait {
    fn ZERO() -> Fixed {
        return core::num::traits::Zero::zero();
    }

    fn ONE() -> Fixed {
        return core::num::traits::One::one();
    }

    fn new(mag: u64, sign: bool) -> Fixed {
        return Fixed { mag: mag, sign: sign };
    }

    fn new_unscaled(mag: u64, sign: bool) -> Fixed {
        return Fixed { mag: mag * ONE, sign: sign };
    }

    fn from_felt(val: felt252) -> Fixed {
        let mag = core::integer::u64_try_from_felt252(utils::felt_abs(val)).unwrap();
        return Self::new(mag, utils::felt_sign(val));
    }

    fn from_unscaled_felt(val: felt252) -> Fixed {
        return Self::from_felt(val * ONE.into());
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

impl FixedPrint of PrintTrait<Fixed> {
    fn print(self: Fixed) {
        self.sign.print();
        self.mag.print();
    }
}

impl Fixed64IntoFixed128 of Into<Fixed, Fixed128> {
    fn into(self: Fixed) -> Fixed128 {
        return FixedTrait128::new(self.mag.into() * ONE.into(), self.sign);
    }
}

// Into a raw felt without unscaling
impl FixedIntoFelt252 of Into<Fixed, felt252> {
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
            return Option::Some((self.mag / ONE).into());
        }
    }
}

impl FixedTryIntoU64 of TryInto<Fixed, u64> {
    fn try_into(self: Fixed) -> Option<u64> {
        if self.sign {
            return Option::None(());
        } else {
            // Unscale the magnitude and round down
            return Option::Some(self.mag / ONE);
        }
    }
}

impl FixedTryIntoU32 of TryInto<Fixed, u32> {
    fn try_into(self: Fixed) -> Option<u32> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return (self.mag / ONE).try_into();
        }
    }
}

impl FixedTryIntoU16 of TryInto<Fixed, u16> {
    fn try_into(self: Fixed) -> Option<u16> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return (self.mag / ONE).try_into();
        }
    }
}

impl FixedTryIntoU8 of TryInto<Fixed, u8> {
    fn try_into(self: Fixed) -> Option<u8> {
        if self.sign {
            Option::None(())
        } else {
            // Unscale the magnitude and round down
            return (self.mag / ONE).try_into();
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

impl U128TryIntoFixed of TryInto<u128, Fixed> {
    fn try_into(self: u128) -> Option<Fixed> {
        if self > 18_446_744_073_709_551_615 {
            return Option::None(());
        } else {
            return Option::Some(FixedTrait::new_unscaled(self.try_into().unwrap(), false));
        }
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

impl I128TryIntoFixed of TryInto<i128, Fixed> {
    fn try_into(self: i128) -> Option<Fixed> {
        let sign = self < 0;
        let value: u128 = if sign {
            (-self).try_into().unwrap()
        } else {
            self.try_into().unwrap()
        };
        if value > MAX_u64 {
            return Option::None(());
        } else {
            return Option::Some(FixedTrait::new_unscaled(value.try_into().unwrap(), sign));
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
        let MAX_MAG_PLUS_ONE = 0x10000000000000000; // 2**64
        let packed_sign = MAX_MAG_PLUS_ONE * value.sign.into();
        value.mag.into() + packed_sign
    }

    fn unpack(value: felt252) -> Fixed {
        let value_u128: u128 = value.try_into().unwrap();
        let (q, r) = U128DivRem::div_rem(value_u128, u128_as_non_zero(0x10000000000000000));
        let mag: u64 = r.try_into().unwrap();
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
        Fixed { mag: ONE, sign: false }
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

#[cfg(test)]
mod tests {
    use super::{FixedTrait, Fixed128, ONE_u128};

    #[test]
    fn test_into_f128() {
        let a = FixedTrait::new_unscaled(42, true);
        let b: Fixed128 = a.into();
        assert(b.mag == 42 * ONE_u128, 'invalid conversion');
    }

    fn test_reverse_try() {
        let a = FixedTrait::new_unscaled(42, false);
        let b = FixedTrait::new_unscaled(42, true);
        assert(42_u64.into() == a, 'invalid conversion from u64');
        assert(42_u32.into() == a, 'invalid conversion from u32');
        assert(42_u16.into() == a, 'invalid conversion from u16');
        assert(42_u8.into() == a, 'invalid conversion from u8');

        assert(42_i64.into() == a, 'invalid conversion from i64');
        assert(42_i32.into() == a, 'invalid conversion from i32');
        assert(42_i16.into() == a, 'invalid conversion from i16');
        assert(42_i8.into() == a, 'invalid conversion from i8');

        assert((-42_i64).into() == b, 'invalid conversion from - i64');
        assert((-42_i32).into() == b, 'invalid conversion from - i32');
        assert((-42_i16).into() == b, 'invalid conversion from - i16');
        assert((-42_i8).into() == b, 'invalid conversion from - i8');
    }

    fn test_reverse_try_into() {
        let mut a = FixedTrait::new_unscaled(42, false);
        let b = FixedTrait::new_unscaled(42, true);
        assert(a == 42_u256.try_into().unwrap(), 'conversion from invalid u256');
        assert(42_u128.try_into().unwrap() == a, 'invalid conversion from u128');
        assert(42_i128.try_into().unwrap() == a, 'invalid conversion from i128');
        assert((-42_i128).try_into().unwrap() == b, 'invalid conversion from - i128');
    }
}
