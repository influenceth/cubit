use cubit::f128::types::fixed::{
    Fixed, FixedTrait, FixedAdd, FixedSub, FixedMul, FixedDiv, ONE_u128,
};

// Calculates hyperbolic cosine of a (fixed point)
fn cosh(a: Fixed) -> Fixed {
    let ea = a.exp();
    let num = ea + (FixedTrait::ONE() / ea);
    let den = FixedTrait::new_unscaled(2_u128, false);
    return num / den;
}

// Calculates hyperbolic sine of a (fixed point)
fn sinh(a: Fixed) -> Fixed {
    let ea = a.exp();
    let num = ea - (FixedTrait::ONE() / ea);
    let den = FixedTrait::new_unscaled(2_u128, false);
    return num / den;
}

// Calculates hyperbolic tangent of a (fixed point)
fn tanh(a: Fixed) -> Fixed {
    let ea = a.exp();
    let ea_i = FixedTrait::ONE() / ea;
    return (ea - ea_i) / (ea + ea_i);
}

// Calculates inverse hyperbolic cosine of a (fixed point)
fn acosh(a: Fixed) -> Fixed {
    let root = (a * a - FixedTrait::ONE()).sqrt();
    return (a + root).ln();
}

// Calculates inverse hyperbolic sine of a (fixed point)
fn asinh(a: Fixed) -> Fixed {
    let root = (a * a + FixedTrait::ONE()).sqrt();
    return (a + root).ln();
}

// Calculates inverse hyperbolic tangent of a (fixed point)
fn atanh(a: Fixed) -> Fixed {
    let one = FixedTrait::ONE();
    let ln_arg = (one + a) / (one - a);
    return ln_arg.ln() / FixedTrait::new_unscaled(2_u128, false);
}

// Tests
// --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use core::option::OptionTrait;
    use core::traits::Into;

    use cubit::f128::test::helpers::assert_precise;
    use cubit::f128::types::fixed::{FixedInto, FixedPartialEq, ONE};

    use super::{FixedTrait, cosh, ONE_u128, sinh, tanh, acosh, asinh, atanh};

    #[test]
    #[available_gas(10000000)]
    fn test_cosh() {
        let a = FixedTrait::new_unscaled(2_u128, false);
        assert_precise(
            cosh(a), 69400261068632590000, 'invalid two', Option::None(()),
        ); // 3.762195691016423

        let a = FixedTrait::ONE();
        assert_precise(
            cosh(a), 28464813555534070000, 'invalid one', Option::None(()),
        ); // 1.5430806347841253

        let a = FixedTrait::new(0_u128, false);
        assert_precise(cosh(a), ONE, 'invalid zero', Option::None(()));

        let a = FixedTrait::new(ONE_u128, true);
        assert_precise(
            cosh(a), 28464813555534070000, 'invalid neg one', Option::None(()),
        ); // 1.5430806347841253

        let a = FixedTrait::new_unscaled(2_u128, true);
        assert_precise(
            cosh(a), 69400261068632590000, 'invalid neg two', Option::None(()),
        ); // 3.762195691016423
    }

    #[test]
    #[available_gas(10000000)]
    fn test_sinh() {
        let a = FixedTrait::new_unscaled(2_u128, false);
        assert_precise(
            sinh(a), 66903765734623805000, 'invalid two', Option::None(()),
        ); // 3.6268604077773023

        let a = FixedTrait::ONE();
        assert_precise(
            sinh(a), 21678635654265184000, 'invalid one', Option::None(()),
        ); // 1.1752011936029418

        let a = FixedTrait::new(0_u128, false);
        assert(sinh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE_u128, true);
        assert_precise(
            sinh(a), -21678635654265184000, 'invalid neg one', Option::None(()),
        ); // -1.1752011936029418

        let a = FixedTrait::new_unscaled(2_u128, true);
        assert_precise(
            sinh(a), -66903765734623805000, 'invalid neg two', Option::None(()),
        ); // -3.6268604077773023
    }

    #[test]
    #[available_gas(10000000)]
    fn test_tanh() {
        let a = FixedTrait::new_unscaled(2_u128, false);
        assert_precise(
            tanh(a), 17783170049656136000, 'invalid two', Option::None(()),
        ); // 0.9640275800745076

        let a = FixedTrait::ONE();
        assert_precise(
            tanh(a), 14048932482948833000, 'invalid one', Option::None(()),
        ); // 0.7615941559446443

        let a = FixedTrait::new(0_u128, false);
        assert(tanh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE_u128, true);
        assert_precise(
            tanh(a), -14048932482948833000, 'invalid neg one', Option::None(()),
        ); // -0.7615941559446443

        let a = FixedTrait::new_unscaled(2_u128, true);
        assert_precise(
            tanh(a), -17783170049656136000, 'invalid neg two', Option::None(()),
        ); // 0.9640275800745076
    }

    #[test]
    #[available_gas(10000000)]
    fn test_acosh() {
        let a = FixedTrait::new(69400261067392811864_u128, false); // 3.762195691016423
        assert_precise(acosh(a), 2 * ONE, 'invalid two', Option::None(()));

        let a = FixedTrait::new(28464813554960036081_u128, false); // 1.5430806347841253
        assert_precise(acosh(a), ONE, 'invalid one', Option::None(()));

        let a = FixedTrait::ONE(); // 1
        assert(acosh(a).into() == 0, 'invalid zero');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_asinh() {
        let a = FixedTrait::new(66903765733337761105_u128, false); // 3.6268604077773023
        assert_precise(asinh(a), 2 * ONE, 'invalid two', Option::None(()));

        let a = FixedTrait::new(21678635653511457631_u128, false); // 1.1752011936029418
        assert_precise(asinh(a), ONE, 'invalid one', Option::None(()));

        let a = FixedTrait::new(0_u128, false);
        assert(asinh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::from_felt(-21678635653511457633); // -1.1752011936029418
        assert_precise(asinh(a), -ONE, 'invalid neg one', Option::None(()));

        let a = FixedTrait::from_felt(-66903765733337761123); // -3.6268604077773023
        assert_precise(asinh(a), -2 * ONE, 'invalid neg two', Option::None(()));
    }

    #[test]
    #[available_gas(10000000)]
    fn test_atanh() {
        let a = FixedTrait::new(16602069666338597000, false); // 0.9
        assert_precise(
            atanh(a), 27157656144668970000, 'invalid 0.9', Option::None(()),
        ); // 1.4722194895832204

        let a = FixedTrait::new(9223372036854776000, false); // 0.5
        assert_precise(
            atanh(a), 10132909862646469000, 'invalid half', Option::None(()),
        ); // 0.5493061443340548

        let a = FixedTrait::new(0_u128, false);
        assert(atanh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(9223372036854776000, true); // 0.5
        assert_precise(
            atanh(a), -10132909862646469000, 'invalid neg half', Option::None(()),
        ); // 0.5493061443340548

        let a = FixedTrait::new(16602069666338597000, true); // 0.9
        assert_precise(
            atanh(a), -27157656144668970000, 'invalid -0.9', Option::None(()),
        ); // 1.4722194895832204
    }
}
