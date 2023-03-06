use traits::Into;

use cubit::core::ONE;
use cubit::core::HALF;
use cubit::core::felt_abs;
use cubit::core::felt_sign;
use cubit::core::Fixed;
use cubit::core::FixedInto;


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
