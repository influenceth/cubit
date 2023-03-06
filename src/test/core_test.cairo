use option::OptionTrait;
use traits::Into;

use cubit::core::ONE;
use cubit::core::HALF;
use cubit::core::felt_abs;
use cubit::core::felt_sign;
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
    assert(felt_sign(min) == -1, 'invalid result');
    assert(felt_sign(-1) == -1, 'invalid result');
    assert(felt_sign(0) == 0, 'invalid result');
    assert(felt_sign(1) == 1, 'invalid result');
    assert(felt_sign(max) == 1, 'invalid result');
}

#[test]
fn test_abs() {
    assert(felt_abs(5) == 5, 'abs of pos should be pos');
    assert(felt_abs(-5) == 5, 'abs of neg should be pos');
    assert(felt_abs(0) == 0, 'abs of 0 should be 0');
}

#[test]
fn test_ceil() {
    let a = Fixed::from_felt(6686944726719712460); // 2.9
    assert(a.ceil().into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-6686944726719712460); // -2.9
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
    let a = Fixed::from_felt(6686944726719712460); // 2.9
    assert(a.floor().into() == 2 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-6686944726719712460); // -2.9
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
    let a = Fixed::from_felt(6686944726719712460); // 2.9
    assert(a.round().into() == 3 * ONE, 'invalid pos decimal');

    let a = Fixed::from_felt(-6686944726719712460); // -2.9
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

    let a = Fixed::from_felt(2882303761517117440); // 1.25
    let b = Fixed::from_felt(5303438921191496089); // 2.3
    let c = a * b;
    assert(c.into() == 6629298651489370111, 'invalid result'); // 2.875

    let a = Fixed::from_int(0);
    let b = Fixed::from_felt(5303438921191496089); // 2.3
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
    let b = Fixed::from_felt(6686944726719712460); // 2.9
    let c = a / b;
    assert(c.into() == 7951182790392048111, 'invalid pos decimal'); // 3.4482758620689657

    let a = Fixed::from_int(10);
    let b = Fixed::from_int(5);
    let c = a / b;
    assert(c.into() == 2 * ONE, 'invalid pos integer');

    let a = Fixed::from_int(-2);
    let b = Fixed::from_int(5);
    let c = a / b;
    assert(c.into() == -922337203685477580, 'invalid neg decimal'); // 0.4

    let a = Fixed::from_int(-1000);
    let b = Fixed::from_int(12500);
    let c = a / b;
    assert(c.into() == -184467440737095515, 'invalid neg decimal'); // 0.08

    let a = Fixed::from_int(-10);
    let b = Fixed::from_int(123456789);
    let c = a / b;
    assert(c.into() == -186773285445, 'invalid neg decimal');

    let a = Fixed::from_int(123456789);
    let b = Fixed::from_int(-10);
    let c = a / b;
    assert(c.into() == -28467197385562007012720803, 'invalid neg decimal'); // 0.08
}
