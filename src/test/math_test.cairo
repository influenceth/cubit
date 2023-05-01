use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;

use cubit::types::fixed::ONE;
use cubit::types::fixed::ONE_u128;
use cubit::types::fixed::HALF;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedInto;
use cubit::types::fixed::FixedPartialEq;
use cubit::types::fixed::FixedPartialOrd;
use cubit::types::fixed::FixedAdd;
use cubit::types::fixed::FixedAddEq;
use cubit::types::fixed::FixedSub;
use cubit::types::fixed::FixedSubEq;
use cubit::types::fixed::FixedMul;
use cubit::types::fixed::FixedMulEq;
use cubit::types::fixed::FixedDiv;

use cubit::math::core;

#[test]
fn test_ceil() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(core::ceil(a).into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(core::ceil(a).into() == -2 * ONE, 'invalid neg decimal');

    let a = Fixed::from_unscaled_felt(4);
    assert(core::ceil(a).into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_unscaled_felt(-4);
    assert(core::ceil(a).into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_unscaled_felt(0);
    assert(core::ceil(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(core::ceil(a).into() == 1 * ONE, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(core::ceil(a).into() == 0, 'invalid neg half');
}

#[test]
fn test_floor() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(core::floor(a).into() == 2 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(core::floor(a).into() == -3 * ONE, 'invalid neg decimal');

    let a = Fixed::from_unscaled_felt(4);
    assert(core::floor(a).into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_unscaled_felt(-4);
    assert(core::floor(a).into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_unscaled_felt(0);
    assert(core::floor(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(core::floor(a).into() == 0, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(core::floor(a).into() == -1 * ONE, 'invalid neg half');
}

#[test]
fn test_round() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(core::round(a).into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(core::round(a).into() == -3 * ONE, 'invalid neg decimal');

    let a = Fixed::from_unscaled_felt(4);
    assert(core::round(a).into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_unscaled_felt(-4);
    assert(core::round(a).into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_unscaled_felt(0);
    assert(core::round(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(core::round(a).into() == 1 * ONE, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(core::round(a).into() == -1 * ONE, 'invalid neg half');
}

#[test]
#[should_panic]
fn test_sqrt_fail() {
    let a = Fixed::from_unscaled_felt(-25);
    core::sqrt(a);
}

#[test]
fn test_sqrt() {
    let a = Fixed::from_unscaled_felt(0);
    assert(core::sqrt(a).into() == 0, 'invalid zero root');

    let a = Fixed::from_unscaled_felt(1);
    assert(core::sqrt(a).into() == ONE, 'invalid one root');

    let a = Fixed::from_unscaled_felt(25);
    assert_precise(core::sqrt(a), 5 * ONE, 'invalid 25 root', Option::None(())); // 5

    let a = Fixed::from_unscaled_felt(81);
    assert_precise(core::sqrt(a), 9 * ONE, 'invalid 81 root', Option::None(())); // 9

    let a = Fixed::from_felt(1152921504606846976); // 0.0625
    assert_precise(
        core::sqrt(a), 4611686018427387904, 'invalid decimal root', Option::None(())
    ); // 0.25
}

#[test]
#[available_gas(10000000)]
fn test_pow_int() {
    let a = Fixed::from_unscaled_felt(3);
    let b = Fixed::from_unscaled_felt(4);
    assert(core::pow(a, b).into() == 81 * ONE, 'invalid pos base power');

    let a = Fixed::from_unscaled_felt(50);
    let b = Fixed::from_unscaled_felt(5);
    assert(core::pow(a, b).into() == 312500000 * ONE, 'invalid big power');

    let a = Fixed::from_unscaled_felt(-3);
    let b = Fixed::from_unscaled_felt(2);
    assert(core::pow(a, b).into() == 9 * ONE, 'invalid neg base');

    let a = Fixed::from_unscaled_felt(3);
    let b = Fixed::from_unscaled_felt(-2);
    assert_precise(
        core::pow(a, b), 2049638230412172401, 'invalid neg power', Option::None(())
    ); // 0.1111111111111111

    let a = Fixed::from_unscaled_felt(-3);
    let b = Fixed::from_unscaled_felt(-2);
    assert_precise(
        core::pow(a, b), 2049638230412172401, 'invalid neg base power', Option::None(())
    );

    let a = Fixed::from_felt(9223372036854775808);
    let b = Fixed::from_unscaled_felt(2);
    assert_precise(
        core::pow(a, b), 4611686018427387904, 'invalid frac base power', Option::None(())
    );
}

#[test]
#[available_gas(10000000)]
fn test_pow_frac() {
    let a = Fixed::from_unscaled_felt(3);
    let b = Fixed::from_felt(9223372036854775808); // 0.5
    assert_precise(
        core::pow(a, b), 31950697969885030000, 'invalid pos base power', Option::None(())
    ); // 1.7320508075688772

    let a = Fixed::from_felt(2277250555899444146995); // 123.45
    let b = Fixed::from_felt(-27670116110564327424); // -1.5
    assert_precise(
        core::pow(a, b), 13448785939318150, 'invalid pos base power', Option::None(())
    ); // 0.0007290601466350622
}

#[test]
#[available_gas(10000000)]
fn test_exp() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(
        core::exp(a), 136304026803256380000, 'invalid exp of 2', Option::None(())
    ); // 7.3890560989306495

    let a = Fixed::new_unscaled(0_u128, false);
    assert(core::exp(a).into() == ONE, 'invalid exp of 0');

    let a = Fixed::new_unscaled(2_u128, true);
    assert_precise(
        core::exp(a), 2496495334008789000, 'invalid exp of -2', Option::None(())
    ); // 0.1353352832366127
}

#[test]
#[available_gas(10000000)]
fn test_exp2() {
    let a = Fixed::new(27670116110564327424_u128, false); // 1.5
    assert_precise(
        core::exp2(a), 52175271301331124000, 'invalid exp2 of 1.5', Option::None(())
    ); // 2.82842712474619

    let a = Fixed::new_unscaled(2_u128, false);
    assert(core::exp2(a).into() == 4 * ONE, 'invalid exp2 of 2'); // 4

    let a = Fixed::new_unscaled(0_u128, false);
    assert(core::exp2(a).into() == ONE, 'invalid exp2 of 0');

    let a = Fixed::new_unscaled(2_u128, true);
    assert_precise(
        core::exp2(a), 4611686018427387904, 'invalid exp2 of -2', Option::None(())
    ); // 0.25

    let a = Fixed::new(27670116110564327424_u128, true); // -1.5
    assert_precise(
        core::exp2(a), 6521908912666391000, 'invalid exp2 of -1.5', Option::None(())
    ); // 0.35355339059327373
}

#[test]
#[available_gas(10000000)]
fn test_ln() {
    let a = Fixed::from_unscaled_felt(1);
    assert(core::ln(a).into() == 0, 'invalid ln of 1');

    let a = Fixed::from_felt(50143449209799256683); // e
    assert_precise(core::ln(a), ONE, 'invalid ln of e', Option::None(()));

    let a = Fixed::from_felt(9223372036854775808); // 0.5
    assert_precise(
        core::ln(a), -12786308645202655000, 'invalid ln of 0.5', Option::None(())
    ); // -0.6931471805599453
}

#[test]
#[available_gas(10000000)]
fn test_log2() {
    let a = Fixed::from_unscaled_felt(32);
    assert_precise(core::log2(a), 5 * ONE, 'invalid log2 32', Option::None(()));

    let a = Fixed::from_unscaled_felt(1234);
    assert_precise(
        core::log2(a), 189431951710772170000, 'invalid log2 1234', Option::None(())
    ); // 10.269126679149418

    let a = Fixed::from_felt(1035286617648801165344); // 56.123
    assert_precise(
        core::log2(a), 107185179502756360000, 'invalid log2 56.123', Option::None(())
    ); // 5.8105202237568605
}

#[test]
#[available_gas(10000000)]
fn test_log10() {
    let a = Fixed::from_unscaled_felt(100);
    assert_precise(core::log10(a), 2 * ONE, 'invalid log10', Option::None(()));

    let a = Fixed::from_unscaled_felt(1);
    assert(core::log10(a).into() == 0, 'invalid log10');
}

#[test]
fn test_eq() {
    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(42);
    let c = core::eq(a, b);
    assert(c == true, 'invalid result');

    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(-42);
    let c = core::eq(a, b);
    assert(c == false, 'invalid result');
}

#[test]
fn test_ne() {
    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(42);
    let c = core::ne(a, b);
    assert(c == false, 'invalid result');

    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(-42);
    let c = core::ne(a, b);
    assert(c == true, 'invalid result');
}

#[test]
fn test_add() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(2);
    assert(core::add(a, b) == Fixed::from_unscaled_felt(3), 'invalid result');
}

#[test]
fn test_sub() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(2);
    let c = core::sub(a, b);
    assert(c.into() == 3 * ONE, 'false result invalid');

    let c = core::sub(b, a);
    assert(c.into() == -3 * ONE, 'true result invalid');
}

#[test]
fn test_mul_pos() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(2);
    let c = core::mul(a, b);
    assert(c.into() == 10 * ONE, 'invalid result');

    let a = Fixed::from_unscaled_felt(9);
    let b = Fixed::from_unscaled_felt(9);
    let c = core::mul(a, b);
    assert(c.into() == 81 * ONE, 'invalid result');

    let a = Fixed::from_unscaled_felt(4294967295);
    let b = Fixed::from_unscaled_felt(4294967295);
    let c = core::mul(a, b);
    assert(c.into() == 18446744065119617025 * ONE, 'invalid huge mul');

    let a = Fixed::from_felt(23058430092136939520); // 1.25
    let b = Fixed::from_felt(42427511369531968716); // 2.3
    let c = core::mul(a, b);
    assert(c.into() == 53034389211914960895, 'invalid result'); // 2.875

    let a = Fixed::from_unscaled_felt(0);
    let b = Fixed::from_felt(42427511369531968716); // 2.3
    let c = core::mul(a, b);
    assert(c.into() == 0, 'invalid result');
}

#[test]
fn test_mul_neg() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(-2);
    let c = core::mul(a, b);
    assert(c.into() == -10 * ONE, 'true result invalid');

    let a = Fixed::from_unscaled_felt(-5);
    let b = Fixed::from_unscaled_felt(-2);
    let c = core::mul(a, b);
    assert(c.into() == 10 * ONE, 'false result invalid');
}

#[test]
fn test_div() {
    let a = Fixed::from_unscaled_felt(10);
    let b = Fixed::from_felt(53495557813757699680); // 2.9
    let c = core::div(a, b);
    assert_precise(
        c, 63609462323136390000, 'invalid pos decimal', Option::None(())
    ); // 3.4482758620689657

    let a = Fixed::from_unscaled_felt(10);
    let b = Fixed::from_unscaled_felt(5);
    let c = core::div(a, b);
    assert(c.into() == 2 * ONE, 'invalid pos integer'); // 2

    let a = Fixed::from_unscaled_felt(-2);
    let b = Fixed::from_unscaled_felt(5);
    let c = core::div(a, b);
    assert(c.into() == -7378697629483820646, 'invalid neg decimal'); // 0.4

    let a = Fixed::from_unscaled_felt(-1000);
    let b = Fixed::from_unscaled_felt(12500);
    let c = core::div(a, b);
    assert(c.into() == -1475739525896764129, 'invalid neg decimal'); // 0.08

    let a = Fixed::from_unscaled_felt(-10);
    let b = Fixed::from_unscaled_felt(123456789);
    let c = core::div(a, b);
    assert_precise(
        c, -1494186283568, 'invalid neg decimal', Option::None(())
    ); // 8.100000073706917e-8

    let a = Fixed::from_unscaled_felt(123456789);
    let b = Fixed::from_unscaled_felt(-10);
    let c = core::div(a, b);
    assert_precise(
        c, -227737579084496056114112102, 'invalid neg decimal', Option::None(())
    ); // -12345678.9
}

#[test]
fn test_le() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

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
fn test_lt() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

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
fn test_ge() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

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
fn test_gt() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

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
