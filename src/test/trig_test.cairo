use option::OptionTrait;
use traits::Into;

use cubit::core::ONE;
use cubit::core::Fixed;
use cubit::core::FixedInto;
use cubit::core::FixedPartialEq;

use cubit::trig::HALF_PI_u128;
use cubit::trig::PI_u128;
use cubit::trig;


#[test]
#[available_gas(10000000)]
fn test_cos() {
    let a = Fixed::new(HALF_PI_u128, false);
    assert(trig::cos(a).into() == 0, 'invalid half pi');

    let a = Fixed::new(HALF_PI_u128 / 2_u128, false);
    assert(trig::cos(a).into() == 13043817825332781360, 'invalid quarter pi'); // 0.7071067811865475

    let a = Fixed::new(PI_u128, false);
    assert(trig::cos(a).into() == -18446744073598439113, 'invalid pi');

    let a = Fixed::new(HALF_PI_u128, true);
    assert(trig::cos(a).into() == -1, 'invalid neg half pi'); // -0.000...

    let a = Fixed::new_unscaled(17_u128, false);
    assert(trig::cos(a).into() == -5075864723929312153, 'invalid 17'); // -0.2751631780463348

    let a = Fixed::new_unscaled(17_u128, true);
    assert(trig::cos(a).into() == -5075864723929312150, 'invalid -17'); // -0.2751631780463348
}

#[test]
#[available_gas(10000000)]
fn test_sin() {
    let a = Fixed::new(HALF_PI_u128, false);
    assert(trig::sin(a).into() == 18446744073598439112, 'invalid half pi'); // 0.9999999999939766

    let a = Fixed::new(HALF_PI_u128 / 2_u128, false);
    assert(trig::sin(a).into() == 13043817825332781360, 'invalid quarter pi'); // 0.7071067811865475

    let a = Fixed::new(PI_u128, false);
    assert(trig::sin(a).into() == 0, 'invalid pi');

    let a = Fixed::new(HALF_PI_u128, true);
    assert(trig::sin(a).into() == -18446744073598439112, 'invalid neg half pi'); // 0.9999999999939766

    let a = Fixed::new_unscaled(17_u128, false);
    assert(trig::sin(a).into() == -17734653485804420554, 'invalid 17'); // -0.9613974918793389

    let a = Fixed::new_unscaled(17_u128, true);
    assert(trig::sin(a).into() == 17734653485804420554, 'invalid -17'); // 0.9613974918793389
}

#[test]
#[available_gas(100000000)]
fn test_tan() {
    let a = Fixed::new(HALF_PI_u128 / 2_u128, false);
    assert(trig::tan(a).into() == ONE, 'invalid quarter pi');

    let a = Fixed::new(PI_u128, false);
    assert(trig::tan(a).into() == 0, 'invalid pi');

    let a = Fixed::new_unscaled(17_u128, false);
    assert(trig::tan(a).into() == 64451405205161859944, 'invalid 17'); // 3.493917677159002

    let a = Fixed::new_unscaled(17_u128, true);
    assert(trig::tan(a).into() == -64451405205161859982, 'invalid -17'); // -3.493917677159002
}
