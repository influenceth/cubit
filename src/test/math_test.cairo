use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;

use cubit::core::ONE;
use cubit::core::ONE_u128;
use cubit::core::HALF;
use cubit::core::Fixed;
use cubit::core::FixedInto;
use cubit::core::FixedPartialEq;
use cubit::core::FixedPartialOrd;
use cubit::core::FixedAdd;
use cubit::core::FixedAddEq;
use cubit::core::FixedSub;
use cubit::core::FixedSubEq;
use cubit::core::FixedMul;
use cubit::core::FixedMulEq;
use cubit::core::FixedDiv;

use cubit::math;


#[test]
fn test_ceil() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(math::ceil(a).into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(math::ceil(a).into() == -2 * ONE, 'invalid neg decimal');

    let a = Fixed::from_unscaled_felt(4);
    assert(math::ceil(a).into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_unscaled_felt(-4);
    assert(math::ceil(a).into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_unscaled_felt(0);
    assert(math::ceil(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(math::ceil(a).into() == 1 * ONE, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(math::ceil(a).into() == 0, 'invalid neg half');
}

#[test]
fn test_floor() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(math::floor(a).into() == 2 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(math::floor(a).into() == -3 * ONE, 'invalid neg decimal');

    let a = Fixed::from_unscaled_felt(4);
    assert(math::floor(a).into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_unscaled_felt(-4);
    assert(math::floor(a).into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_unscaled_felt(0);
    assert(math::floor(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(math::floor(a).into() == 0, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(math::floor(a).into() == -1 * ONE, 'invalid neg half');
}

#[test]
fn test_round() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(math::round(a).into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(math::round(a).into() == -3 * ONE, 'invalid neg decimal');

    let a = Fixed::from_unscaled_felt(4);
    assert(math::round(a).into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_unscaled_felt(-4);
    assert(math::round(a).into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_unscaled_felt(0);
    assert(math::round(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(math::round(a).into() == 1 * ONE, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(math::round(a).into() == -1 * ONE, 'invalid neg half');
}

#[test]
#[should_panic]
fn test_sqrt_fail() {
    let a = Fixed::from_unscaled_felt(-25);
    math::sqrt(a);
}

#[test]
fn test_sqrt() {
    let a = Fixed::from_unscaled_felt(0);
    assert(math::sqrt(a).into() == 0, 'invalid zero root');

    let a = Fixed::from_unscaled_felt(1);
    assert(math::sqrt(a).into() == ONE, 'invalid one root');

    let a = Fixed::from_unscaled_felt(25);
    assert_precise(math::sqrt(a), 5 * ONE, 'invalid 25 root'); // 5

    let a = Fixed::from_unscaled_felt(81);
    assert_precise(math::sqrt(a), 9 * ONE, 'invalid 81 root'); // 5

    let a = Fixed::from_felt(1152921504606846976); // 0.0625
    assert_precise(math::sqrt(a), 4611686018427387904, 'invalid decimal root'); // 0.25
}

#[test]
#[available_gas(10000000)]
fn test_pow_int() {
    let a = Fixed::from_unscaled_felt(3);
    let b = Fixed::from_unscaled_felt(4);
    assert(math::pow(a, b).into() == 81 * ONE, 'invalid pos base power');

    let a = Fixed::from_unscaled_felt(50);
    let b = Fixed::from_unscaled_felt(5);
    assert(math::pow(a, b).into() == 312500000 * ONE, 'invalid big power');

    let a = Fixed::from_unscaled_felt(-3);
    let b = Fixed::from_unscaled_felt(2);
    assert(math::pow(a, b).into() == 9 * ONE, 'invalid neg base');

    let a = Fixed::from_unscaled_felt(3);
    let b = Fixed::from_unscaled_felt(-2);
    assert_precise(math::pow(a, b), 2049638230412172401, 'invalid neg power'); // 0.1111111111111111

    let a = Fixed::from_unscaled_felt(-3);
    let b = Fixed::from_unscaled_felt(-2);
    assert_precise(math::pow(a, b), 2049638230412172401, 'invalid neg base power');

    let a = Fixed::from_felt(9223372036854775808);
    let b = Fixed::from_unscaled_felt(2);
    assert_precise(math::pow(a, b), 4611686018427387904, 'invalid frac base power');
}

#[test]
#[available_gas(10000000)]
fn test_pow_frac() {
    let a = Fixed::from_unscaled_felt(3);
    let b = Fixed::from_felt(9223372036854775808); // 0.5
    assert_precise(math::pow(a, b), 31950697969885030000, 'invalid pos base power'); // 1.7320508075688772

    let a = Fixed::from_felt(2277250555899444146995); // 123.45
    let b = Fixed::from_felt(-27670116110564327424); // -1.5
    assert_precise(math::pow(a, b), 13448785939318150, 'invalid pos base power'); // 0.0007290601466350622
}

#[test]
#[available_gas(10000000)]
fn test_exp() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(math::exp(a), 136304026803256380000, 'invalid exp of 2'); // 7.3890560989306495

    let a = Fixed::new_unscaled(0_u128, false);
    assert(math::exp(a).into() == ONE, 'invalid exp of 0');

    let a = Fixed::new_unscaled(2_u128, true);
    assert_precise(math::exp(a), 2496495334008789000, 'invalid exp of -2'); // 0.1353352832366127
}

#[test]
#[available_gas(10000000)]
fn test_exp2() {
    let a = Fixed::new(27670116110564327424_u128, false); // 1.5
    assert_precise(math::exp2(a), 52175271301331124000, 'invalid exp2 of 1.5'); // 2.82842712474619

    let a = Fixed::new_unscaled(2_u128, false);
    assert(math::exp2(a).into() == 4 * ONE, 'invalid exp2 of 2'); // 4

    let a = Fixed::new_unscaled(0_u128, false);
    assert(math::exp2(a).into() == ONE, 'invalid exp2 of 0');

    let a = Fixed::new_unscaled(2_u128, true);
    assert_precise(math::exp2(a), 4611686018427387904, 'invalid exp2 of -2'); // 0.25

    let a = Fixed::new(27670116110564327424_u128, true); // -1.5
    assert_precise(math::exp2(a), 6521908912666391000, 'invalid exp2 of -1.5'); // 0.35355339059327373
}

#[test]
#[available_gas(10000000)]
fn test_ln() {
    let a = Fixed::from_unscaled_felt(1);
    assert(math::ln(a).into() == 0, 'invalid ln of 1');

    let a = Fixed::from_felt(50143449209799256683); // e
    assert_precise(math::ln(a), ONE, 'invalid ln of e');

    let a = Fixed::from_felt(9223372036854775808); // 0.5
    assert_precise(math::ln(a), -12786308645202655000, 'invalid ln of 0.5'); // -0.6931471805599453
}

#[test]
#[available_gas(10000000)]
fn test_log2() {
    let a = Fixed::from_unscaled_felt(32);
    assert_precise(math::log2(a), 5 * ONE, 'invalid log2 32');

    let a = Fixed::from_unscaled_felt(1234);
    assert_precise(math::log2(a), 189431951710772170000, 'invalid log2 1234'); // 10.269126679149418

    let a = Fixed::from_felt(1035286617648801165344); // 56.123
    assert_precise(math::log2(a), 107185179502756360000, 'invalid log2 56.123'); // 5.8105202237568605
}

#[test]
#[available_gas(10000000)]
fn test_log10() {
    let a = Fixed::from_unscaled_felt(100);
    assert_precise(math::log10(a), 2 * ONE, 'invalid log10');

    let a = Fixed::from_unscaled_felt(1);
    assert(math::log10(a).into() == 0, 'invalid log10');
}

#[test]
fn test_eq() {
    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(42);
    let c = math::eq(a, b);
    assert(c == true, 'invalid result');

    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(-42);
    let c = math::eq(a, b);
    assert(c == false, 'invalid result');
}

#[test]
fn test_ne() {
    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(42);
    let c = math::ne(a, b);
    assert(c == false, 'invalid result');

    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(-42);
    let c = math::ne(a, b);
    assert(c == true, 'invalid result');
}

#[test]
fn test_add() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(2);
    assert(math::add(a, b) == Fixed::from_unscaled_felt(3), 'invalid result');
}

#[test]
fn test_sub() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(2);
    let c = math::sub(a, b);
    assert(c.into() == 3 * ONE, 'false result invalid');

    let c = math::sub(b, a);
    assert(c.into() == -3 * ONE, 'true result invalid');
}

#[test]
fn test_mul_pos() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(2);
    let c = math::mul(a, b);
    assert(c.into() == 10 * ONE, 'invalid result');

    let a = Fixed::from_unscaled_felt(9);
    let b = Fixed::from_unscaled_felt(9);
    let c = math::mul(a, b);
    assert(c.into() == 81 * ONE, 'invalid result');

    let a = Fixed::from_unscaled_felt(4294967295);
    let b = Fixed::from_unscaled_felt(4294967295);
    let c = math::mul(a, b);
    assert(c.into() == 18446744065119617025 * ONE, 'invalid huge mul');

    let a = Fixed::from_felt(23058430092136939520); // 1.25
    let b = Fixed::from_felt(42427511369531968716); // 2.3
    let c = math::mul(a, b);
    assert(c.into() == 53034389211914960895, 'invalid result'); // 2.875

    let a = Fixed::from_unscaled_felt(0);
    let b = Fixed::from_felt(42427511369531968716); // 2.3
    let c = math::mul(a, b);
    assert(c.into() == 0, 'invalid result');
}

#[test]
fn test_mul_neg() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(-2);
    let c = math::mul(a, b);
    assert(c.into() == -10 * ONE, 'true result invalid');

    let a = Fixed::from_unscaled_felt(-5);
    let b = Fixed::from_unscaled_felt(-2);
    let c = math::mul(a, b);
    assert(c.into() == 10 * ONE, 'false result invalid');
}

#[test]
fn test_div() {
    let a = Fixed::from_unscaled_felt(10);
    let b = Fixed::from_felt(53495557813757699680); // 2.9
    let c = math::div(a, b);
    assert_precise(c, 63609462323136390000, 'invalid pos decimal'); // 3.4482758620689657

    let a = Fixed::from_unscaled_felt(10);
    let b = Fixed::from_unscaled_felt(5);
    let c = math::div(a, b);
    assert(c.into() == 2 * ONE, 'invalid pos integer'); // 2

    let a = Fixed::from_unscaled_felt(-2);
    let b = Fixed::from_unscaled_felt(5);
    let c = math::div(a, b);
    assert(c.into() == -7378697629483820646, 'invalid neg decimal'); // 0.4

    let a = Fixed::from_unscaled_felt(-1000);
    let b = Fixed::from_unscaled_felt(12500);
    let c = math::div(a, b);
    assert(c.into() == -1475739525896764129, 'invalid neg decimal'); // 0.08

    let a = Fixed::from_unscaled_felt(-10);
    let b = Fixed::from_unscaled_felt(123456789);
    let c = math::div(a, b);
    assert_precise(c, -1494186283568, 'invalid neg decimal'); // 8.100000073706917e-8

    let a = Fixed::from_unscaled_felt(123456789);
    let b = Fixed::from_unscaled_felt(-10);
    let c = math::div(a, b);
    assert_precise(c, -227737579084496056114112102, 'invalid neg decimal'); // -12345678.9
}

#[test]
fn test_le() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(math::le(a, a), 'a <= a');
    assert(math::le(a, b) == false, 'a <= b');
    assert(math::le(a, c) == false, 'a <= c');

    assert(math::le(b, a), 'b <= a');
    assert(math::le(b, b), 'b <= b');
    assert(math::le(b, c) == false, 'b <= c');

    assert(math::le(c, a), 'c <= a');
    assert(math::le(c, b), 'c <= b');
    assert(math::le(c, c), 'c <= c');
}

#[test]
fn test_lt() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(math::lt(a, a) == false, 'a < a');
    assert(math::lt(a, b) == false, 'a < b');
    assert(math::lt(a, c) == false, 'a < c');

    assert(math::lt(b, a), 'b < a');
    assert(math::lt(b, b) == false, 'b < b');
    assert(math::lt(b, c) == false, 'b < c');

    assert(math::lt(c, a), 'c < a');
    assert(math::lt(c, b), 'c < b');
    assert(math::lt(c, c) == false, 'c < c');
}

#[test]
fn test_ge() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(math::ge(a, a), 'a >= a');
    assert(math::ge(a, b), 'a >= b');
    assert(math::ge(a, c), 'a >= c');

    assert(math::ge(b, a) == false, 'b >= a');
    assert(math::ge(b, b), 'b >= b');
    assert(math::ge(b, c), 'b >= c');

    assert(math::ge(c, a) == false, 'c >= a');
    assert(math::ge(c, b) == false, 'c >= b');
    assert(math::ge(c, c), 'c >= c');
}

#[test]
fn test_gt() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(math::gt(a, a) == false, 'a > a');
    assert(math::gt(a, b), 'a > b');
    assert(math::gt(a, c), 'a > c');

    assert(math::gt(b, a) == false, 'b > a');
    assert(math::gt(b, b) == false, 'b > b');
    assert(math::gt(b, c), 'b > c');

    assert(math::gt(c, a) == false, 'c > a');
    assert(math::gt(c, b) == false, 'c > b');
    assert(math::gt(c, c) == false, 'c > c');
}
