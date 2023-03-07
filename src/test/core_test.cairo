use option::OptionTrait;
use traits::Into;

use cubit::core::ONE;
use cubit::core::HALF;
use cubit::core::_felt_abs;
use cubit::core::_felt_sign;
use cubit::core::Fixed;
use cubit::core::FixedInto;
use cubit::core::FixedPartialEq;
use cubit::core::FixedAdd;
use cubit::core::FixedAddEq;
use cubit::core::FixedSub;
use cubit::core::FixedSubEq;
use cubit::core::FixedMul;
use cubit::core::FixedMulEq;
use cubit::core::FixedDiv;


#[test]
fn test_into() {
    let a = Fixed::from_int(5);
    assert(a.into() == 5 * ONE, 'invalid result');
}

#[test]
#[should_panic]
fn test_overflow_large() {
    let too_large = 0x100000000000000000000000000000000;
    Fixed::from_felt(too_large);
}

#[test]
#[should_panic]
fn test_overflow_small() {
    let too_small = -0x100000000000000000000000000000000;
    Fixed::from_felt(too_small);
}

#[test]
fn test_sign() {
    let min = -1809251394333065606848661391547535052811553607665798349986546028067936010240;
    let max = 1809251394333065606848661391547535052811553607665798349986546028067936010240;
    assert(_felt_sign(min) == -1, 'invalid result');
    assert(_felt_sign(-1) == -1, 'invalid result');
    assert(_felt_sign(0) == 0, 'invalid result');
    assert(_felt_sign(1) == 1, 'invalid result');
    assert(_felt_sign(max) == 1, 'invalid result');
}

#[test]
fn test_abs() {
    assert(_felt_abs(5) == 5, 'abs of pos should be pos');
    assert(_felt_abs(-5) == 5, 'abs of neg should be pos');
    assert(_felt_abs(0) == 0, 'abs of 0 should be 0');
}

#[test]
fn test_ceil() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(a.ceil().into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(a.ceil().into() == -2 * ONE, 'invalid neg decimal');

    let a = Fixed::from_int(4);
    assert(a.ceil().into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_int(-4);
    assert(a.ceil().into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_int(0);
    assert(a.ceil().into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(a.ceil().into() == 1 * ONE, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(a.ceil().into() == 0, 'invalid neg half');
}

#[test]
fn test_floor() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(a.floor().into() == 2 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(a.floor().into() == -3 * ONE, 'invalid neg decimal');

    let a = Fixed::from_int(4);
    assert(a.floor().into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_int(-4);
    assert(a.floor().into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_int(0);
    assert(a.floor().into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(a.floor().into() == 0, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(a.floor().into() == -1 * ONE, 'invalid neg half');
}

#[test]
fn test_round() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(a.round().into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-53495557813757699680); // -2.9
    assert(a.round().into() == -3 * ONE, 'invalid neg decimal');

    let a = Fixed::from_int(4);
    assert(a.round().into() == 4 * ONE, 'invalid pos integer');

    let a = Fixed::from_int(-4);
    assert(a.round().into() == -4 * ONE, 'invalid neg integer');

    let a = Fixed::from_int(0);
    assert(a.round().into() == 0, 'invalid zero');

    let a = Fixed::from_felt(HALF);
    assert(a.round().into() == 1 * ONE, 'invalid pos half');

    let a = Fixed::from_felt(-1 * HALF);
    assert(a.round().into() == -1 * ONE, 'invalid neg half');
}

#[test]
#[should_panic]
fn test_sqrt_fail() {
    let a = Fixed::from_int(-25);
    a.sqrt();
}

#[test]
fn test_sqrt() {
    let a = Fixed::from_int(0);
    assert(a.sqrt().into() == 0, 'invalid zero root');

    let a = Fixed::from_int(1);
    assert(a.sqrt().into() == ONE, 'invalid one root');

    let a = Fixed::from_int(25);
    assert(a.sqrt().into() == 92233720368547758080, 'invalid 25 root'); // 5

    let a = Fixed::from_int(81);
    assert(a.sqrt().into() == 166020696663385964544, 'invalid 81 root'); // 9

    let a = Fixed::from_felt(1152921504606846976); // 0.0625
    assert(a.sqrt().into() == 4611686018427387904, 'invalid decimal root'); // 0.25
}

#[test]
#[available_gas(10000000)]
fn test_pow_int() {
    let a = Fixed::from_int(3);
    let b = Fixed::from_int(4);
    assert(a.pow(b).into() == 81 * ONE, 'invalid pos base power');

    let a = Fixed::from_int(50);
    let b = Fixed::from_int(5);
    assert(a.pow(b).into() == 312500000 * ONE, 'invalid big power');

    let a = Fixed::from_int(-3);
    let b = Fixed::from_int(2);
    assert(a.pow(b).into() == 9 * ONE, 'invalid neg base');

    let a = Fixed::from_int(3);
    let b = Fixed::from_int(-2);
    assert(a.pow(b).into() == 2049638230412172401, 'invalid neg power'); // 0.1111111111111111

    let a = Fixed::from_int(-3);
    let b = Fixed::from_int(-2);
    assert(a.pow(b).into() == 2049638230412172401, 'invalid neg base power');

    let a = Fixed::from_felt(9223372036854775808);
    let b = Fixed::from_int(2);
    assert(a.pow(b).into() == 4611686018427387904, 'invalid frac base power');
}

#[test]
#[available_gas(10000000)]
fn test_pow_frac() {
    let a = Fixed::from_int(3);
    let b = Fixed::from_felt(9223372036854775808);
    assert(a.pow(b).into() == 31950696165187714181, 'invalid pos base power'); // 1.7320507097360398

    let a = Fixed::from_felt(2277250555899444146995); // 123.45
    let b = Fixed::from_felt(-27670116110564327424); // -1.5
    assert(a.pow(b).into() == 13448785356302935, 'invalid pos base power'); // 0.0007290601150297441
}

#[test]
#[available_gas(10000000)]
fn test_exp() {
    let a = Fixed::from_int(2);
    assert(a.exp().into() == 136304030830375888892, 'invalid exp of 2'); // 7.389056317241236

    let a = Fixed::from_int(0);
    assert(a.exp().into() == ONE, 'invalid exp of 0');

    let a = Fixed::from_int(-2);
    assert(a.exp().into() == 2496495260249524483, 'invalid exp of -2'); // 0.13533527923811497
}

#[test]
#[available_gas(10000000)]
fn test_exp2() {
    let a = Fixed::from_int(2);
    assert(a.exp2().into() == 73786968408486180064, 'invalid exp2 of 2'); // 3.99999957248 = 4

    let a = Fixed::from_int(0);
    assert(a.exp2().into() == ONE, 'invalid exp2 of 0');

    let a = Fixed::from_int(-2);
    assert(a.exp2().into() == 4611686511324442234, 'invalid exp of -2'); // 0.2500000267200029 = 0.25
}

#[test]
#[available_gas(10000000)]
fn test_ln() {
    let a = Fixed::from_int(1);
    assert(a.ln().into() == 0, 'invalid ln of 1');

    let a = Fixed::from_felt(50143449209799256683); // e
    assert(a.ln().into() == 18446744490532965082, 'invalid ln of e'); // 1.0000000225960426

    let a = Fixed::from_felt(9223372036854775808); // 0.5
    assert(a.ln().into() == -12786308104066639394, 'invalid ln of 0.5'); // -0.6931471512249031
}

#[test]
#[available_gas(10000000)]
fn test_log2() {
    let a = Fixed::from_int(32);
    assert(a.log2().into() == 92233719587853510925, 'invalid log2'); // 4.99999995767848

    let a = Fixed::from_int(1234);
    assert(a.log2().into() == 189431951110156820629, 'invalid log2'); // 10.269126646589994

    let a = Fixed::from_felt(1035286617648801165344); // 56.123
    assert(a.log2().into() == 107185180242499619003, 'invalid log2'); // 5.810520263858423
}

#[test]
#[available_gas(10000000)]
fn test_log10() {
    let a = Fixed::from_int(100);
    assert(a.log10().into() == 36893487914963460128, 'invalid log10'); // 1.9999999873985543

    let a = Fixed::from_int(1);
    assert(a.log10().into() == 0, 'invalid log10');
}

#[test]
fn test_eq() {
    let a = Fixed::from_int(42);
    let b = Fixed::from_int(42);
    let c = a == b;
    assert(c == true, 'invalid result');

    let a = Fixed::from_int(42);
    let b = Fixed::from_int(-42);
    let c = a == b;
    assert(c == false, 'invalid result');
}

#[test]
fn test_ne() {
    let a = Fixed::from_int(42);
    let b = Fixed::from_int(42);
    let c = a != b;
    assert(c == false, 'invalid result');

    let a = Fixed::from_int(42);
    let b = Fixed::from_int(-42);
    let c = a != b;
    assert(c == true, 'invalid result');
}

#[test]
fn test_add() {
    let a = Fixed::from_int(1);
    let b = Fixed::from_int(2);
    assert(a + b == Fixed::from_int(3), 'invalid result');
}

#[test]
fn test_add_eq() {
    let mut a = Fixed::from_int(1);
    let b = Fixed::from_int(2);
    a += b;
    assert(a.into() == 3 * ONE, 'invalid result');
}

#[test]
fn test_sub() {
    let a = Fixed::from_int(5);
    let b = Fixed::from_int(2);
    let c = a - b;
    assert(c.into() == 3 * ONE, 'positive result invalid');

    let c = b - a;
    assert(c.into() == -3 * ONE, 'negative result invalid');
}

#[test]
fn test_sub_eq() {
    let mut a = Fixed::from_int(5);
    let b = Fixed::from_int(2);
    a -= b;
    assert(a.into() == 3 * ONE, 'invalid result');
}

#[test]
fn test_mul_pos() {
    let a = Fixed::from_int(5);
    let b = Fixed::from_int(2);
    let c = a * b;
    assert(c.into() == 10 * ONE, 'invalid result');

    let a = Fixed::from_int(9);
    let b = Fixed::from_int(9);
    let c = a * b;
    assert(c.into() == 81 * ONE, 'invalid result');

    let a = Fixed::from_int(4294967295);
    let b = Fixed::from_int(4294967295);
    let c = a * b;
    assert(c.into() == 18446744065119617025 * ONE, 'invalid huge mul');

    let a = Fixed::from_felt(23058430092136939520); // 1.25
    let b = Fixed::from_felt(42427511369531968716); // 2.3
    let c = a * b;
    assert(c.into() == 53034389211914960895, 'invalid result'); // 2.875

    let a = Fixed::from_int(0);
    let b = Fixed::from_felt(42427511369531968716); // 2.3
    let c = a * b;
    assert(c.into() == 0, 'invalid result');
}

#[test]
fn test_mul_neg() {
    let a = Fixed::from_int(5);
    let b = Fixed::from_int(-2);
    let c = a * b;
    assert(c.into() == -10 * ONE, 'negative result invalid');

    let a = Fixed::from_int(-5);
    let b = Fixed::from_int(-2);
    let c = a * b;
    assert(c.into() == 10 * ONE, 'positive result invalid');
}

#[test]
fn test_mul_eq() {
    let mut a = Fixed::from_int(5);
    let b = Fixed::from_int(-2);
    a *= b;
    assert(a.into() == -10 * ONE, 'invalid result');
}

#[test]
fn test_div() {
    let a = Fixed::from_int(10);
    let b = Fixed::from_felt(53495557813757699680); // 2.9
    let c = a / b;
    assert(c.into() == 63609462323136384890, 'invalid pos decimal'); // 3.4482758620689653

    let a = Fixed::from_int(10);
    let b = Fixed::from_int(5);
    let c = a / b;
    assert(c.into() == 36893488147419103230, 'invalid pos integer'); // 2

    let a = Fixed::from_int(-2);
    let b = Fixed::from_int(5);
    let c = a / b;
    assert(c.into() == -7378697629483820646, 'invalid neg decimal'); // 0.4

    let a = Fixed::from_int(-1000);
    let b = Fixed::from_int(12500);
    let c = a / b;
    assert(c.into() == -1475739525896764000, 'invalid neg decimal'); // 0.08

    let a = Fixed::from_int(-10);
    let b = Fixed::from_int(123456789);
    let c = a / b;
    assert(c.into() == -1494186283560, 'invalid neg decimal'); // 8.100000073706917e-8

    let a = Fixed::from_int(123456789);
    let b = Fixed::from_int(-10);
    let c = a / b;
    assert(c.into() == -227737579084496056040038029, 'invalid neg decimal'); // -12345678.9
}
