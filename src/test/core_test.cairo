use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;

use cubit::types::fixed::ONE;
use cubit::types::fixed::ONE_u128;
use cubit::types::fixed::HALF;
use cubit::types::fixed::_felt_abs;
use cubit::types::fixed::_felt_sign;
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

use cubit::math::trig::HALF_PI_u128;
use cubit::math::trig::PI_u128;


#[test]
fn test_into() {
    let a = Fixed::from_unscaled_felt(5);
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
    assert(_felt_sign(min) == true, 'invalid result');
    assert(_felt_sign(-1) == true, 'invalid result');
    assert(_felt_sign(0) == false, 'invalid result');
    assert(_felt_sign(1) == false, 'invalid result');
    assert(_felt_sign(max) == false, 'invalid result');
}

#[test]
fn test_abs() {
    assert(_felt_abs(5) == 5, 'abs of pos should be pos');
    assert(_felt_abs(-5) == 5, 'abs of neg should be pos');
    assert(_felt_abs(0) == 0, 'abs of 0 should be 0');
}

#[test]
#[available_gas(10000000)]
fn test_acos() {
    let a = Fixed::new(ONE_u128, false);
    assert(a.acos().into() == 0, 'invalid one');
}

#[test]
#[available_gas(10000000)]
fn test_asin() {
    let a = Fixed::new(ONE_u128, false);
    assert(a.asin().into() == 28976077832308491370, 'invalid one'); // PI / 2
}

#[test]
#[available_gas(10000000)]
fn test_atan() {
    let a = Fixed::new(2_u128 * ONE_u128, false);
    assert_precise(a.atan(), 20423289048683266000, 'invalid two');
}

#[test]
fn test_ceil() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(a.ceil().into() == 3 * ONE, 'invalid pos decimal');
}

#[test]
fn test_floor() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(a.floor().into() == 2 * ONE, 'invalid pos decimal');
}

#[test]
fn test_round() {
    let a = Fixed::from_felt(53495557813757699680); // 2.9
    assert(a.round().into() == 3 * ONE, 'invalid pos decimal');
}

#[test]
#[should_panic]
fn test_sqrt_fail() {
    let a = Fixed::from_unscaled_felt(-25);
    a.sqrt();
}

#[test]
fn test_sqrt() {
    let a = Fixed::from_unscaled_felt(0);
    assert(a.sqrt().into() == 0, 'invalid zero root');
}

#[test]
#[available_gas(10000000)]
fn test_pow() {
    let a = Fixed::from_unscaled_felt(3);
    let b = Fixed::from_unscaled_felt(4);
    assert(a.pow(b).into() == 81 * ONE, 'invalid pos base power');
}

#[test]
#[available_gas(10000000)]
fn test_exp() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert(a.exp().into() == 136304026800730572984, 'invalid exp of 2'); // 7.389056098793725
}

#[test]
#[available_gas(10000000)]
fn test_exp2() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert(a.exp2().into() == 73786976294838206464, 'invalid exp2 of 2'); // 4
}

#[test]
#[available_gas(10000000)]
fn test_ln() {
    let a = Fixed::from_unscaled_felt(1);
    assert(a.ln().into() == 0, 'invalid ln of 1');
}

#[test]
#[available_gas(10000000)]
fn test_log2() {
    let a = Fixed::from_unscaled_felt(32);
    assert_precise(a.log2(), 5 * ONE, 'invalid log2 32');
}

#[test]
#[available_gas(10000000)]
fn test_log10() {
    let a = Fixed::from_unscaled_felt(100);
    assert_precise(a.log10(), 2 * ONE, 'invalid log10');
}

#[test]
fn test_eq() {
    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(42);
    let c = a == b;
    assert(c == true, 'invalid result');
}

#[test]
fn test_ne() {
    let a = Fixed::from_unscaled_felt(42);
    let b = Fixed::from_unscaled_felt(42);
    let c = a != b;
    assert(c == false, 'invalid result');
}

#[test]
fn test_add() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(2);
    assert(a + b == Fixed::from_unscaled_felt(3), 'invalid result');
}

#[test]
fn test_add_eq() {
    let mut a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(2);
    a += b;
    assert(a.into() == 3 * ONE, 'invalid result');
}

#[test]
fn test_sub() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(2);
    let c = a - b;
    assert(c.into() == 3 * ONE, 'false result invalid');
}

#[test]
fn test_sub_eq() {
    let mut a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(2);
    a -= b;
    assert(a.into() == 3 * ONE, 'invalid result');
}

#[test]
fn test_mul_pos() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(2);
    let c = a * b;
    assert(c.into() == 10 * ONE, 'invalid result');
}

#[test]
fn test_mul_neg() {
    let a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(-2);
    let c = a * b;
    assert(c.into() == -10 * ONE, 'true result invalid');
}

#[test]
fn test_mul_eq() {
    let mut a = Fixed::from_unscaled_felt(5);
    let b = Fixed::from_unscaled_felt(-2);
    a *= b;
    assert(a.into() == -10 * ONE, 'invalid result');
}

#[test]
fn test_div() {
    let a = Fixed::from_unscaled_felt(10);
    let b = Fixed::from_felt(53495557813757699680); // 2.9
    let c = a / b;
    assert(c.into() == 63609462323136384890, 'invalid pos decimal'); // 3.4482758620689653
}

#[test]
fn test_le() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(a <= a, 'a <= a');
    assert(a <= b == false, 'a <= b');
    assert(a <= c == false, 'a <= c');

    assert(b <= a, 'b <= a');
    assert(b <= b, 'b <= b');
    assert(b <= c == false, 'b <= c');

    assert(c <= a, 'c <= a');
    assert(c <= b, 'c <= b');
    assert(c <= c, 'c <= c');
}

#[test]
fn test_lt() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(a < a == false, 'a < a');
    assert(a < b == false, 'a < b');
    assert(a < c == false, 'a < c');

    assert(b < a, 'b < a');
    assert(b < b == false, 'b < b');
    assert(b < c == false, 'b < c');

    assert(c < a, 'c < a');
    assert(c < b, 'c < b');
    assert(c < c == false, 'c < c');
}

#[test]
fn test_ge() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(a >= a, 'a >= a');
    assert(a >= b, 'a >= b');
    assert(a >= c, 'a >= c');

    assert(b >= a == false, 'b >= a');
    assert(b >= b, 'b >= b');
    assert(b >= c, 'b >= c');

    assert(c >= a == false, 'c >= a');
    assert(c >= b == false, 'c >= b');
    assert(c >= c, 'c >= c');
}

#[test]
fn test_gt() {
    let a = Fixed::from_unscaled_felt(1);
    let b = Fixed::from_unscaled_felt(0);
    let c = Fixed::from_unscaled_felt(-1);

    assert(a > a == false, 'a > a');
    assert(a > b, 'a > b');
    assert(a > c, 'a > c');

    assert(b > a == false, 'b > a');
    assert(b > b == false, 'b > b');
    assert(b > c, 'b > c');

    assert(c > a == false, 'c > a');
    assert(c > b == false, 'c > b');
    assert(c > c == false, 'c > c');
}

#[test]
#[available_gas(10000000)]
fn test_cos() {
    let a = Fixed::new(HALF_PI_u128, false);
    assert(a.cos().into() == 0, 'invalid half pi');
}

#[test]
#[available_gas(10000000)]
fn test_sin() {
    let a = Fixed::new(HALF_PI_u128, false);
    assert_precise(a.sin(), ONE, 'invalid half pi');
}

#[test]
#[available_gas(10000000)]
fn test_tan() {
    let a = Fixed::new(HALF_PI_u128 / 2_u128, false);
    assert(a.tan().into() == ONE, 'invalid quarter pi');
}

#[test]
#[available_gas(10000000)]
fn test_cosh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(a.cosh(), 69400261068632590000, 'invalid two'); // 3.762195691016423
}

#[test]
#[available_gas(10000000)]
fn test_sinh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(a.sinh(), 66903765734623805000, 'invalid two'); // 3.6268604077773023
}

#[test]
#[available_gas(10000000)]
fn test_tanh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(a.tanh(), 17783170049656136000, 'invalid two'); // 0.9640275800745076
}

#[test]
#[available_gas(10000000)]
fn test_acosh() {
    let a = Fixed::new(69400261067392811864_u128, false); // 3.762195691016423
    assert_precise(a.acosh(), 2 * ONE, 'invalid two');
}

#[test]
#[available_gas(10000000)]
fn test_asinh() {
    let a = Fixed::new(66903765733337761105_u128, false); // 3.6268604077773023
    assert_precise(a.asinh(), 2 * ONE, 'invalid two');
}

#[test]
#[available_gas(10000000)]
fn test_atanh() {
    let a = Fixed::new(16602069666338597000, false); // 0.9
    assert_precise(a.atanh(), 27157656144668970000, 'invalid 0.9'); // 1.4722194895832204
}
