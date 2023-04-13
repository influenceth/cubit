use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;

use cubit::core::ONE;
use cubit::core::ONE_u128;
use cubit::core::Fixed;
use cubit::core::FixedInto;
use cubit::core::FixedPartialEq;

use cubit::hyp;

#[test]
#[available_gas(10000000)]
fn test_cosh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert(hyp::cosh(a).into() == 69400261067392811864, 'invalid two'); // 3.762195691016423

    let a = Fixed::new(ONE_u128, false);
    assert(hyp::cosh(a).into() == 28464813554960036081, 'invalid one'); // 1.5430806347841253

    let a = Fixed::new(0_u128, false);
    assert_precise(hyp::cosh(a), ONE, 'invalid zero');

    let a = Fixed::new(ONE_u128, true);
    assert(hyp::cosh(a).into() == 28464813554960036083, 'invalid neg one'); // 1.5430806347841253

    let a = Fixed::new_unscaled(2_u128, true);
    assert(hyp::cosh(a).into() == 69400261067392811882, 'invalid neg two'); // 3.762195691016423
}

#[test]
#[available_gas(10000000)]
fn test_sinh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert(hyp::sinh(a).into() == 66903765733337761105, 'invalid two'); // 3.6268604077773023

    let a = Fixed::new(ONE_u128, false);
    assert(hyp::sinh(a).into() == 21678635653511457631, 'invalid one'); // 1.1752011936029418

    let a = Fixed::new(0_u128, false);
    assert(hyp::sinh(a).into() == 0, 'invalid zero');

    let a = Fixed::new(ONE_u128, true);
    assert(hyp::sinh(a).into() == -21678635653511457633, 'invalid neg one'); // -1.1752011936029418

    let a = Fixed::new_unscaled(2_u128, true);
    assert(hyp::sinh(a).into() == -66903765733337761123, 'invalid neg two'); // -3.6268604077773023
}

#[test]
#[available_gas(10000000)]
fn test_tanh() {
    let a = Fixed::new_unscaled(2_u128, false);
    assert(hyp::tanh(a).into() == 17783170049631984588, 'invalid two'); // 0.9640275800745076

    let a = Fixed::new(ONE_u128, false);
    assert(hyp::tanh(a).into() == 14048932482743694683, 'invalid one'); // 0.7615941559446443

    let a = Fixed::new(0_u128, false);
    assert(hyp::tanh(a).into() == 0, 'invalid zero');

    let a = Fixed::new(ONE_u128, true);
    assert(hyp::tanh(a).into() == -14048932482743694683, 'invalid neg one'); // -0.7615941559446443

    let a = Fixed::new_unscaled(2_u128, true);
    assert(hyp::tanh(a).into() == -17783170049631984592, 'invalid neg two'); // 0.9640275800745076
}

#[test]
#[available_gas(10000000)]
fn test_acosh() {
    let a = Fixed::new(69400261067392811864_u128, false); // 3.762195691016423
    assert(hyp::acosh(a).into() == 36893487748848056145, 'invalid two');

    let a = Fixed::new(28464813554960036081_u128, false); // 1.5430806347841253
    assert(hyp::acosh(a).into() == 18446744488867702154, 'invalid one');

    let a = Fixed::new(ONE_u128, false);  // 1
    assert(hyp::acosh(a).into() == 0, 'invalid zero');
}

#[test]
#[available_gas(10000000)]
fn test_asinh() {
    let a = Fixed::new(66903765733337761105_u128, false); // 3.6268604077773023
    assert(hyp::asinh(a).into() == 36893487749134664002, 'invalid two');

    let a = Fixed::new(21678635653511457631_u128, false); // 1.1752011936029418
    assert(hyp::asinh(a).into() == 18446744489272286808, 'invalid one');

    let a = Fixed::new(0_u128, false);
    assert(hyp::asinh(a).into() == 0, 'invalid zero');

    let a = Fixed::from_felt(-21678635653511457633); // -1.1752011936029418
    assert(hyp::asinh(a).into() == -18446744495750494944, 'invalid neg one');

    let a = Fixed::from_felt(-66903765733337761123); // -3.6268604077773023
    assert(hyp::asinh(a).into() == -36893487751321156140, 'invalid neg two');
}

#[test]
#[available_gas(10000000)]
fn test_atanh() {
    let a = Fixed::new_unscaled(17783170049656136000_u128, false); // 0.9640275800745076
    // assert_precise(hyp::atanh(a), 2 * ONE, 'invalid zero');

    // let a = Fixed::new(ONE_u128, false);
    // assert(hyp::atanh(a).into() == 14048932482948833000, 'invalid one'); // 0.7615941559446443

    // let a = Fixed::new(0_u128, false);
    // assert(hyp::atanh(a).into() == 0, 'invalid zero');

    // let a = Fixed::new(ONE_u128, true);
    // assert(hyp::atanh(a).into() == -14048932482948833000, 'invalid neg one'); // -0.7615941559446443

    // let a = Fixed::new_unscaled(2_u128, true);
    // assert(hyp::atanh(a).into() == -17783170049656136000, 'invalid neg two'); // 0.9640275800745076
}
