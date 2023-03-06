use option::OptionTrait;
use traits::Into;

use cubit::core::ONE;
use cubit::core::Fixed;
use cubit::core::FixedInto;
use cubit::math::FixedPartialEq;
use cubit::math::FixedAdd;
use cubit::math::FixedAddEq;
use cubit::math::FixedSub;
use cubit::math::FixedSubEq;
use cubit::math::FixedMul;
use cubit::math::FixedMulEq;
use cubit::math::FixedDiv;

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
    assert(c.into() == 7951182790392048111, 'invalid result'); // 3.4482758620689657

    let a = Fixed::from_int(10);
    let b = Fixed::from_int(5);
    let c = a / b;
    assert(c.into() == 2 * ONE, 'invalid result');
}