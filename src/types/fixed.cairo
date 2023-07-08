use debug::PrintTrait;
use integer::{u256_safe_divmod, u256_as_non_zero, u256_from_felt252};

// TODO: https://github.com/BibliothecaDAO/loot-survivor/blob/main/contracts/pack/src/pack.cairo#L10

use option::OptionTrait;
use result::{ResultTrait, ResultTraitImpl};
use traits::{TryInto, Into};

use cubit::math::{core, hyp, trig};

// CONSTANTS

const PRIME: felt252 = 3618502788666131213697322783095070105623107215331596699973092056135872020480;
const HALF_PRIME: felt252 =
    1809251394333065606848661391547535052811553607665798349986546028067936010240;
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
    fn zero() -> Fixed;
    fn one() -> Fixed;

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
    fn zero() -> Fixed {
        return Fixed { mag: 0, sign: false };
    }

    fn one() -> Fixed {
        return Fixed { mag: ONE_u128, sign: false };
    }

    fn new(mag: u128, sign: bool) -> Fixed {
        return Fixed { mag: mag, sign: sign };
    }

    fn new_unscaled(mag: u128, sign: bool) -> Fixed {
        return FixedTrait::new(mag * ONE_u128, sign);
    }

    fn from_felt(val: felt252) -> Fixed {
        let mag = integer::u128_try_from_felt252(_felt_abs(val)).unwrap();
        return FixedTrait::new(mag, _felt_sign(val));
    }

    fn from_unscaled_felt(val: felt252) -> Fixed {
        return FixedTrait::from_felt(val * ONE);
    }

    fn abs(self: Fixed) -> Fixed {
        return core::abs(self);
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
        return core::ceil(self);
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
        return core::floor(self);
    }

    // Calculates the natural exponent of x: e^x
    fn exp(self: Fixed) -> Fixed {
        return core::exp(self);
    }

    // Calculates the binary exponent of x: 2^x
    fn exp2(self: Fixed) -> Fixed {
        return core::exp2(self);
    }

    // Calculates the natural logarithm of x: ln(x)
    // self must be greater than zero
    fn ln(self: Fixed) -> Fixed {
        return core::ln(self);
    }

    // Calculates the binary logarithm of x: log2(x)
    // self must be greather than zero
    fn log2(self: Fixed) -> Fixed {
        return core::log2(self);
    }

    // Calculates the base 10 log of x: log10(x)
    // self must be greater than zero
    fn log10(self: Fixed) -> Fixed {
        return core::log10(self);
    }

    // Calclates the value of x^y and checks for overflow before returning
    // self is a fixed point value
    // b is a fixed point value
    fn pow(self: Fixed, b: Fixed) -> Fixed {
        return core::pow(self, b);
    }

    fn round(self: Fixed) -> Fixed {
        return core::round(self);
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
        return core::sqrt(self);
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

impl FixedPartialEq of PartialEq<Fixed> {
    #[inline(always)]
    fn eq(lhs: @Fixed, rhs: @Fixed) -> bool {
        return core::eq(lhs, rhs);
    }

    #[inline(always)]
    fn ne(lhs: @Fixed, rhs: @Fixed) -> bool {
        return core::ne(lhs, rhs);
    }
}

impl FixedAdd of Add<Fixed> {
    fn add(lhs: Fixed, rhs: Fixed) -> Fixed {
        return core::add(lhs, rhs);
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
        return core::sub(lhs, rhs);
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
        return core::mul(lhs, rhs);
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
        return core::div(lhs, rhs);
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
        return core::ge(lhs, rhs);
    }

    #[inline(always)]
    fn gt(lhs: Fixed, rhs: Fixed) -> bool {
        return core::gt(lhs, rhs);
    }

    #[inline(always)]
    fn le(lhs: Fixed, rhs: Fixed) -> bool {
        return core::le(lhs, rhs);
    }

    #[inline(always)]
    fn lt(lhs: Fixed, rhs: Fixed) -> bool {
        return core::lt(lhs, rhs);
    }
}

impl FixedNeg of Neg<Fixed> {
    #[inline(always)]
    fn neg(a: Fixed) -> Fixed {
        return core::neg(a);
    }
}

impl FixedRem of Rem<Fixed> {
    #[inline(always)]
    fn rem(lhs: Fixed, rhs: Fixed) -> Fixed {
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
        return a * 1;
    }
}

// Tests --------------------------------------------------------------------------------------------------------------

use cubit::test::helpers::assert_precise;

#[test]
#[available_gas(10000000)]
fn test_ceil() {
    let a = FixedTrait::from_felt(53495557813757699680); // 2.9
    assert(core::ceil(a).into() == 3 * ONE, 'invalid pos decimal');

    let a = FixedTrait::from_felt(-53495557813757699680); // -2.9
    assert(core::ceil(a).into() == -2 * ONE, 'invalid neg decimal');

    let a = FixedTrait::from_unscaled_felt(4);
    assert(core::ceil(a).into() == 4 * ONE, 'invalid pos integer');

    let a = FixedTrait::from_unscaled_felt(-4);
    assert(core::ceil(a).into() == -4 * ONE, 'invalid neg integer');

    let a = FixedTrait::from_unscaled_felt(0);
    assert(core::ceil(a).into() == 0, 'invalid zero');

    let a = FixedTrait::from_felt(HALF);
    assert(core::ceil(a).into() == 1 * ONE, 'invalid pos half');

    let a = FixedTrait::from_felt(-1 * HALF);
    assert(core::ceil(a).into() == 0, 'invalid neg half');
}

#[test]
#[available_gas(10000000)]
fn test_floor() {
    let a = FixedTrait::from_felt(53495557813757699680); // 2.9
    assert(core::floor(a).into() == 2 * ONE, 'invalid pos decimal');

    let a = FixedTrait::from_felt(-53495557813757699680); // -2.9
    assert(core::floor(a).into() == -3 * ONE, 'invalid neg decimal');

    let a = FixedTrait::from_unscaled_felt(4);
    assert(core::floor(a).into() == 4 * ONE, 'invalid pos integer');

    let a = FixedTrait::from_unscaled_felt(-4);
    assert(core::floor(a).into() == -4 * ONE, 'invalid neg integer');

    let a = FixedTrait::from_unscaled_felt(0);
    assert(core::floor(a).into() == 0, 'invalid zero');

    let a = FixedTrait::from_felt(HALF);
    assert(core::floor(a).into() == 0, 'invalid pos half');

    let a = FixedTrait::from_felt(-1 * HALF);
    assert(core::floor(a).into() == -1 * ONE, 'invalid neg half');
}

#[test]
#[available_gas(10000000)]
fn test_round() {
    let a = FixedTrait::from_felt(53495557813757699680); // 2.9
    assert(core::round(a).into() == 3 * ONE, 'invalid pos decimal');

    let a = FixedTrait::from_felt(-53495557813757699680); // -2.9
    assert(core::round(a).into() == -3 * ONE, 'invalid neg decimal');

    let a = FixedTrait::from_unscaled_felt(4);
    assert(core::round(a).into() == 4 * ONE, 'invalid pos integer');

    let a = FixedTrait::from_unscaled_felt(-4);
    assert(core::round(a).into() == -4 * ONE, 'invalid neg integer');

    let a = FixedTrait::from_unscaled_felt(0);
    assert(core::round(a).into() == 0, 'invalid zero');

    let a = FixedTrait::from_felt(HALF);
    assert(core::round(a).into() == 1 * ONE, 'invalid pos half');

    let a = FixedTrait::from_felt(-1 * HALF);
    assert(core::round(a).into() == -1 * ONE, 'invalid neg half');
}

#[test]
#[should_panic]
fn test_sqrt_fail() {
    let a = FixedTrait::from_unscaled_felt(-25);
    core::sqrt(a);
}

#[test]
#[available_gas(10000000)]
fn test_sqrt() {
    let a = FixedTrait::from_unscaled_felt(0);
    assert(core::sqrt(a).into() == 0, 'invalid zero root');

    let a = FixedTrait::from_unscaled_felt(1);
    assert(core::sqrt(a).into() == ONE, 'invalid one root');

    let a = FixedTrait::from_unscaled_felt(25);
    assert_precise(core::sqrt(a), 5 * ONE, 'invalid 25 root', Option::None(())); // 5

    let a = FixedTrait::from_unscaled_felt(81);
    assert_precise(core::sqrt(a), 9 * ONE, 'invalid 81 root', Option::None(())); // 9

    let a = FixedTrait::from_felt(1152921504606846976); // 0.0625
    assert_precise(
        core::sqrt(a), 4611686018427387904, 'invalid decimal root', Option::None(())
    ); // 0.25
}

#[test]
#[available_gas(2750000)]
fn test_pow_int() {
    let a = FixedTrait::from_unscaled_felt(3);
    let b = FixedTrait::from_unscaled_felt(4);
    assert(core::pow(a, b).into() == 81 * ONE, 'invalid pos base power');

    let a = FixedTrait::from_unscaled_felt(50);
    let b = FixedTrait::from_unscaled_felt(5);
    assert(core::pow(a, b).into() == 312500000 * ONE, 'invalid big power');

    let a = FixedTrait::from_unscaled_felt(-3);
    let b = FixedTrait::from_unscaled_felt(2);
    assert(core::pow(a, b).into() == 9 * ONE, 'invalid neg base');

    let a = FixedTrait::from_unscaled_felt(3);
    let b = FixedTrait::from_unscaled_felt(-2);
    assert_precise(
        core::pow(a, b), 2049638230412172401, 'invalid neg power', Option::None(())
    ); // 0.1111111111111111

    let a = FixedTrait::from_unscaled_felt(-3);
    let b = FixedTrait::from_unscaled_felt(-2);
    assert_precise(
        core::pow(a, b), 2049638230412172401, 'invalid neg base power', Option::None(())
    );

    let a = FixedTrait::from_felt(9223372036854775808);
    let b = FixedTrait::from_unscaled_felt(2);
    assert_precise(
        core::pow(a, b), 4611686018427387904, 'invalid frac base power', Option::None(())
    );
}

#[test]
#[available_gas(10000000)]
fn test_pow_frac() {
    let a = FixedTrait::from_unscaled_felt(3);
    let b = FixedTrait::from_felt(9223372036854775808); // 0.5
    assert_precise(
        core::pow(a, b), 31950697969885030000, 'invalid pos base power', Option::None(())
    ); // 1.7320508075688772

    let a = FixedTrait::from_felt(2277250555899444146995); // 123.45
    let b = FixedTrait::from_felt(-27670116110564327424); // -1.5
    assert_precise(
        core::pow(a, b), 13448785939318150, 'invalid pos base power', Option::None(())
    ); // 0.0007290601466350622
}

#[test]
#[available_gas(1000000)]
fn test_exp() {
    let a = FixedTrait::new_unscaled(2_u128, false);
    assert_precise(
        core::exp(a), 136304026803256380000, 'invalid exp of 2', Option::None(())
    ); // 7.3890560989306495

    let a = FixedTrait::new_unscaled(0_u128, false);
    assert(core::exp(a).into() == ONE, 'invalid exp of 0');

    let a = FixedTrait::new_unscaled(2_u128, true);
    assert_precise(
        core::exp(a), 2496495334008789000, 'invalid exp of -2', Option::None(())
    ); // 0.1353352832366127
}

#[test]
#[available_gas(1400000)]
fn test_exp2() {
    let a = FixedTrait::new(27670116110564327424_u128, false); // 1.5
    assert_precise(
        core::exp2(a), 52175271301331124000, 'invalid exp2 of 1.5', Option::None(())
    ); // 2.82842712474619

    let a = FixedTrait::new_unscaled(2_u128, false);
    assert(core::exp2(a).into() == 4 * ONE, 'invalid exp2 of 2'); // 4

    let a = FixedTrait::new_unscaled(0_u128, false);
    assert(core::exp2(a).into() == ONE, 'invalid exp2 of 0');

    let a = FixedTrait::new_unscaled(2_u128, true);
    assert_precise(
        core::exp2(a), 4611686018427387904, 'invalid exp2 of -2', Option::None(())
    ); // 0.25

    let a = FixedTrait::new(27670116110564327424_u128, true); // -1.5
    assert_precise(
        core::exp2(a), 6521908912666391000, 'invalid exp2 of -1.5', Option::None(())
    ); // 0.35355339059327373
}

#[test]
#[available_gas(1200000)]
fn test_ln() {
    let a = FixedTrait::from_unscaled_felt(1);
    assert(core::ln(a).into() == 0, 'invalid ln of 1');

    let a = FixedTrait::from_felt(50143449209799256683); // e
    assert_precise(core::ln(a), ONE, 'invalid ln of e', Option::None(()));

    let a = FixedTrait::from_felt(9223372036854775808); // 0.5
    assert_precise(
        core::ln(a), -12786308645202655000, 'invalid ln of 0.5', Option::None(())
    ); // -0.6931471805599453
}

#[test]
#[available_gas(1000000)]
fn test_log2() {
    let a = FixedTrait::from_unscaled_felt(32);
    assert_precise(core::log2(a), 5 * ONE, 'invalid log2 32', Option::None(()));

    let a = FixedTrait::from_unscaled_felt(1234);
    assert_precise(
        core::log2(a), 189431951710772170000, 'invalid log2 1234', Option::None(())
    ); // 10.269126679149418

    let a = FixedTrait::from_felt(1035286617648801165344); // 56.123
    assert_precise(
        core::log2(a), 107185179502756360000, 'invalid log2 56.123', Option::None(())
    ); // 5.8105202237568605
}

#[test]
#[available_gas(1000000)]
fn test_log10() {
    let a = FixedTrait::from_unscaled_felt(100);
    assert_precise(core::log10(a), 2 * ONE, 'invalid log10', Option::None(()));

    let a = FixedTrait::from_unscaled_felt(1);
    assert(core::log10(a).into() == 0, 'invalid log10');
}

#[test]
#[available_gas(10000000)]
fn test_eq() {
    let a = FixedTrait::from_unscaled_felt(42);
    let b = FixedTrait::from_unscaled_felt(42);
    let c = core::eq(@a, @b);
    assert(c == true, 'invalid result');

    let a = FixedTrait::from_unscaled_felt(42);
    let b = FixedTrait::from_unscaled_felt(-42);
    let c = core::eq(@a, @b);
    assert(c == false, 'invalid result');
}

#[test]
#[available_gas(10000000)]
fn test_ne() {
    let a = FixedTrait::from_unscaled_felt(42);
    let b = FixedTrait::from_unscaled_felt(42);
    let c = core::ne(@a, @b);
    assert(c == false, 'invalid result');

    let a = FixedTrait::from_unscaled_felt(42);
    let b = FixedTrait::from_unscaled_felt(-42);
    let c = core::ne(@a, @b);
    assert(c == true, 'invalid result');
}

#[test]
#[available_gas(10000000)]
fn test_add() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(2);
    assert(core::add(a, b) == FixedTrait::from_unscaled_felt(3), 'invalid result');
}

#[test]
#[available_gas(10000000)]
fn test_sub() {
    let a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(2);
    let c = core::sub(a, b);
    assert(c.into() == 3 * ONE, 'false result invalid');

    let c = core::sub(b, a);
    assert(c.into() == -3 * ONE, 'true result invalid');
}

#[test]
#[available_gas(10000000)]
fn test_mul_pos() {
    let a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(2);
    let c = core::mul(a, b);
    assert(c.into() == 10 * ONE, 'invalid result');

    let a = FixedTrait::from_unscaled_felt(9);
    let b = FixedTrait::from_unscaled_felt(9);
    let c = core::mul(a, b);
    assert(c.into() == 81 * ONE, 'invalid result');

    let a = FixedTrait::from_unscaled_felt(4294967295);
    let b = FixedTrait::from_unscaled_felt(4294967295);
    let c = core::mul(a, b);
    assert(c.into() == 18446744065119617025 * ONE, 'invalid huge mul');

    let a = FixedTrait::from_felt(23058430092136939520); // 1.25
    let b = FixedTrait::from_felt(42427511369531968716); // 2.3
    let c = core::mul(a, b);
    assert(c.into() == 53034389211914960895, 'invalid result'); // 2.875

    let a = FixedTrait::from_unscaled_felt(0);
    let b = FixedTrait::from_felt(42427511369531968716); // 2.3
    let c = core::mul(a, b);
    assert(c.into() == 0, 'invalid result');
}

#[test]
#[available_gas(10000000)]
fn test_mul_neg() {
    let a = FixedTrait::from_unscaled_felt(5);
    let b = FixedTrait::from_unscaled_felt(-2);
    let c = core::mul(a, b);
    assert(c.into() == -10 * ONE, 'true result invalid');

    let a = FixedTrait::from_unscaled_felt(-5);
    let b = FixedTrait::from_unscaled_felt(-2);
    let c = core::mul(a, b);
    assert(c.into() == 10 * ONE, 'false result invalid');
}

#[test]
#[available_gas(10000000)]
fn test_div() {
    let a = FixedTrait::from_unscaled_felt(10);
    let b = FixedTrait::from_felt(53495557813757699680); // 2.9
    let c = core::div(a, b);
    assert_precise(
        c, 63609462323136390000, 'invalid pos decimal', Option::None(())
    ); // 3.4482758620689657

    let a = FixedTrait::from_unscaled_felt(10);
    let b = FixedTrait::from_unscaled_felt(5);
    let c = core::div(a, b);
    assert(c.into() == 2 * ONE, 'invalid pos integer'); // 2

    let a = FixedTrait::from_unscaled_felt(-2);
    let b = FixedTrait::from_unscaled_felt(5);
    let c = core::div(a, b);
    assert(c.into() == -7378697629483820646, 'invalid neg decimal'); // 0.4

    let a = FixedTrait::from_unscaled_felt(-1000);
    let b = FixedTrait::from_unscaled_felt(12500);
    let c = core::div(a, b);
    assert(c.into() == -1475739525896764129, 'invalid neg decimal'); // 0.08

    let a = FixedTrait::from_unscaled_felt(-10);
    let b = FixedTrait::from_unscaled_felt(123456789);
    let c = core::div(a, b);
    assert_precise(
        c, -1494186283568, 'invalid neg decimal', Option::None(())
    ); // 8.100000073706917e-8

    let a = FixedTrait::from_unscaled_felt(123456789);
    let b = FixedTrait::from_unscaled_felt(-10);
    let c = core::div(a, b);
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

    assert(core::le(a, a), 'a <= a');
    assert(core::le(a, b) == false, 'a <= b');
    assert(core::le(a, c) == false, 'a <= c');

    assert(core::le(b, a), 'b <= a');
    assert(core::le(b, b), 'b <= b');
    assert(core::le(b, c) == false, 'b <= c');

    assert(core::le(c, a), 'c <= a');
    assert(core::le(c, b), 'c <= b');
    assert(core::le(c, c), 'c <= c');
}

#[test]
#[available_gas(10000000)]
fn test_lt() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(0);
    let c = FixedTrait::from_unscaled_felt(-1);

    assert(core::lt(a, a) == false, 'a < a');
    assert(core::lt(a, b) == false, 'a < b');
    assert(core::lt(a, c) == false, 'a < c');

    assert(core::lt(b, a), 'b < a');
    assert(core::lt(b, b) == false, 'b < b');
    assert(core::lt(b, c) == false, 'b < c');

    assert(core::lt(c, a), 'c < a');
    assert(core::lt(c, b), 'c < b');
    assert(core::lt(c, c) == false, 'c < c');
}

#[test]
#[available_gas(10000000)]
fn test_ge() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(0);
    let c = FixedTrait::from_unscaled_felt(-1);

    assert(core::ge(a, a), 'a >= a');
    assert(core::ge(a, b), 'a >= b');
    assert(core::ge(a, c), 'a >= c');

    assert(core::ge(b, a) == false, 'b >= a');
    assert(core::ge(b, b), 'b >= b');
    assert(core::ge(b, c), 'b >= c');

    assert(core::ge(c, a) == false, 'c >= a');
    assert(core::ge(c, b) == false, 'c >= b');
    assert(core::ge(c, c), 'c >= c');
}

#[test]
#[available_gas(10000000)]
fn test_gt() {
    let a = FixedTrait::from_unscaled_felt(1);
    let b = FixedTrait::from_unscaled_felt(0);
    let c = FixedTrait::from_unscaled_felt(-1);

    assert(core::gt(a, a) == false, 'a > a');
    assert(core::gt(a, b), 'a > b');
    assert(core::gt(a, c), 'a > c');

    assert(core::gt(b, a) == false, 'b > a');
    assert(core::gt(b, b) == false, 'b > b');
    assert(core::gt(b, c), 'b > c');

    assert(core::gt(c, a) == false, 'c > a');
    assert(core::gt(c, b) == false, 'c > b');
    assert(core::gt(c, c) == false, 'c > c');
}

#[test]
#[available_gas(10000000)]
fn test_rem() {
    let a = FixedTrait::new_unscaled(10_u128, false);
    let b = FixedTrait::new_unscaled(3_u128, false);
    assert(core::rem(a, b).into() == 1 * ONE, 'invalid remainder');

    let a = FixedTrait::new_unscaled(10_u128, false);
    let b = FixedTrait::new_unscaled(3_u128, true);
    assert(core::rem(a, b) == FixedTrait::new(2_u128 * ONE_u128, true), 'invalid remainder');
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

#[test]
#[should_panic]
fn test_try_into_fail() {
    let mut a = FixedTrait::new_unscaled(42, true);
    let b: u128 = a.try_into().unwrap();
}
