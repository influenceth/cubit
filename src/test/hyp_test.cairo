use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;

use cubit::types::fixed::ONE;
use cubit::types::fixed::ONE_u128;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedInto;
use cubit::types::fixed::FixedPartialEq;

use cubit::math::hyp;


#[test]
#[available_gas(10000000)]
fn test_cosh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(hyp::cosh(a), 69400261068632590000, 'invalid two'); // 3.762195691016423

    let a = Fixed::new(ONE_u128, false);
    assert_precise(hyp::cosh(a), 28464813555534070000, 'invalid one'); // 1.5430806347841253

    let a = Fixed::new(0_u128, false);
    assert_precise(hyp::cosh(a), ONE, 'invalid zero');

    let a = Fixed::new(ONE_u128, true);
    assert_precise(hyp::cosh(a), 28464813555534070000, 'invalid neg one'); // 1.5430806347841253

    let a = Fixed::new_unscaled(2_u128, true);
    assert_precise(hyp::cosh(a), 69400261068632590000, 'invalid neg two'); // 3.762195691016423
}

#[test]
#[available_gas(10000000)]
fn test_sinh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(hyp::sinh(a), 66903765734623805000, 'invalid two'); // 3.6268604077773023

    let a = Fixed::new(ONE_u128, false);
    assert_precise(hyp::sinh(a), 21678635654265184000, 'invalid one'); // 1.1752011936029418

    let a = Fixed::new(0_u128, false);
    assert(hyp::sinh(a).into() == 0, 'invalid zero');

    let a = Fixed::new(ONE_u128, true);
    assert_precise(hyp::sinh(a), -21678635654265184000, 'invalid neg one'); // -1.1752011936029418

    let a = Fixed::new_unscaled(2_u128, true);
    assert_precise(hyp::sinh(a), -66903765734623805000, 'invalid neg two'); // -3.6268604077773023
}

#[test]
#[available_gas(10000000)]
fn test_tanh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert_precise(hyp::tanh(a), 17783170049656136000, 'invalid two'); // 0.9640275800745076

    let a = Fixed::new(ONE_u128, false);
    assert_precise(hyp::tanh(a), 14048932482948833000, 'invalid one'); // 0.7615941559446443

    let a = Fixed::new(0_u128, false);
    assert(hyp::tanh(a).into() == 0, 'invalid zero');

    let a = Fixed::new(ONE_u128, true);
    assert_precise(hyp::tanh(a), -14048932482948833000, 'invalid neg one'); // -0.7615941559446443

    let a = Fixed::new_unscaled(2_u128, true);
    assert_precise(hyp::tanh(a), -17783170049656136000, 'invalid neg two'); // 0.9640275800745076
}

#[test]
#[available_gas(10000000)]
fn test_acosh() {
    let a = Fixed::new(69400261067392811864_u128, false); // 3.762195691016423
    assert_precise(hyp::acosh(a), 2 * ONE, 'invalid two');

    let a = Fixed::new(28464813554960036081_u128, false); // 1.5430806347841253
    assert_precise(hyp::acosh(a), ONE, 'invalid one');

    let a = Fixed::new(ONE_u128, false);  // 1
    assert(hyp::acosh(a).into() == 0, 'invalid zero');
}

#[test]
#[available_gas(10000000)]
fn test_asinh() {
    let a = Fixed::new(66903765733337761105_u128, false); // 3.6268604077773023
    assert_precise(hyp::asinh(a), 2 * ONE, 'invalid two');

    let a = Fixed::new(21678635653511457631_u128, false); // 1.1752011936029418
    assert_precise(hyp::asinh(a), ONE, 'invalid one');

    let a = Fixed::new(0_u128, false);
    assert(hyp::asinh(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(-21678635653511457633); // -1.1752011936029418
    assert_precise(hyp::asinh(a), -ONE, 'invalid neg one');

    let a = Fixed::from_felt(-66903765733337761123); // -3.6268604077773023
    assert_precise(hyp::asinh(a), -2 * ONE, 'invalid neg two');
}

#[test]
#[available_gas(10000000)]
fn test_atanh() {
    let a = Fixed::new(16602069666338597000, false); // 0.9
    assert_precise(hyp::atanh(a), 27157656144668970000, 'invalid 0.9'); // 1.4722194895832204

    let a = Fixed::new(9223372036854776000, false); // 0.5
    assert_precise(hyp::atanh(a), 10132909862646469000, 'invalid half'); // 0.5493061443340548

    let a = Fixed::new(0_u128, false);
    assert(hyp::atanh(a).into() == 0, 'invalid zero');

    let a = Fixed::new(9223372036854776000, true); // 0.5
    assert_precise(hyp::atanh(a), -10132909862646469000, 'invalid neg half'); // 0.5493061443340548

    let a = Fixed::new(16602069666338597000, true); // 0.9
    assert_precise(hyp::atanh(a), -27157656144668970000, 'invalid -0.9'); // 1.4722194895832204
}
