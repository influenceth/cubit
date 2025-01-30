use cubit::f64::types::fixed::{Fixed, FixedTrait, HALF, ONE, TWO};
use core::debug::PrintTrait;

// Calculates hyperbolic cosine of a (fixed point)
fn cosh(a: Fixed) -> Fixed {
    let ea = a.exp();
    return (ea + (FixedTrait::ONE() / ea)) / FixedTrait::new(TWO, false);
}

// Calculates hyperbolic sine of a (fixed point)
fn sinh(a: Fixed) -> Fixed {
    let ea = a.exp();
    return (ea - (FixedTrait::ONE() / ea)) / FixedTrait::new(TWO, false);
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
    return ln_arg.ln() / FixedTrait::new(TWO, false);
}

// Tests
// --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use core::option::OptionTrait;
    use core::traits::Into;

    use cubit::f64::test::helpers::assert_precise;

    use super::{FixedTrait, TWO, cosh, sinh, ONE, tanh, acosh, asinh, atanh, HALF};

    #[test]
    #[available_gas(10000000)]
    fn test_cosh() {
        let a = FixedTrait::new(TWO, false);
        assert_precise(cosh(a), 16158507454, 'invalid two', Option::None(())); // 3.762195691016423

        let a = FixedTrait::ONE();
        assert_precise(cosh(a), 6627480862, 'invalid one', Option::None(())); // 1.5430806347841253

        let a = FixedTrait::ZERO();
        assert_precise(cosh(a), ONE.into(), 'invalid zero', Option::None(()));

        let a = FixedTrait::ONE();
        assert_precise(
            cosh(a), 6627480862, 'invalid neg one', Option::None(()),
        ); // 1.5430806347841253

        let a = FixedTrait::new(TWO, true);
        assert_precise(
            cosh(a), 16158507454, 'invalid neg two', Option::None(()),
        ); // 3.762195691016423
    }

    #[test]
    #[available_gas(10000000)]
    fn test_sinh() {
        let a = FixedTrait::new(TWO, false);
        assert_precise(sinh(a), 15577246839, 'invalid two', Option::None(())); // 3.6268604077773023

        let a = FixedTrait::ONE();
        assert_precise(sinh(a), 5047450693, 'invalid one', Option::None(())); // 1.1752011936029418

        let a = FixedTrait::ZERO();
        assert(sinh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE, true);
        assert_precise(
            sinh(a), -5047450693, 'invalid neg one', Option::None(()),
        ); // -1.1752011936029418

        let a = FixedTrait::new(TWO, true);
        assert_precise(
            sinh(a), -15577246839, 'invalid neg two', Option::None(()),
        ); // -3.6268604077773023
    }

    #[test]
    #[available_gas(10000000)]
    fn test_tanh() {
        let a = FixedTrait::new(TWO, false);
        assert_precise(tanh(a), 4140466929, 'invalid two', Option::None(())); // 0.9640275800745076

        let a = FixedTrait::ONE();
        assert_precise(tanh(a), 3271021993, 'invalid one', Option::None(())); // 0.7615941559446443

        let a = FixedTrait::ZERO();
        assert(tanh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(ONE, true);
        assert_precise(
            tanh(a), -3271021993, 'invalid neg one', Option::None(()),
        ); // -0.7615941559446443

        let a = FixedTrait::new(TWO, true);
        assert_precise(
            tanh(a), -4140466929, 'invalid neg two', Option::None(()),
        ); // 0.9640275800745076
    }

    #[test]
    #[available_gas(10000000)]
    fn test_acosh() {
        let a = FixedTrait::new(16158507454, false); // 3.762195691016423
        assert_precise(acosh(a), TWO.into(), 'invalid two', Option::None(()));

        let a = FixedTrait::new(6627480862, false); // 1.5430806347841253
        assert_precise(acosh(a), ONE.into(), 'invalid one', Option::None(()));

        let a = FixedTrait::ONE(); // 1
        assert(acosh(a).into() == 0, 'invalid zero');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_asinh() {
        let a = FixedTrait::new(15577246839, false); // 3.6268604077773023
        assert_precise(asinh(a), TWO.into(), 'invalid two', Option::None(()));

        let a = FixedTrait::new(5047450693, false); // 1.1752011936029418
        assert_precise(asinh(a), ONE.into(), 'invalid one', Option::None(()));

        let a = FixedTrait::ZERO();
        assert(asinh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(5047450693, true); // -1.1752011936029418
        assert_precise(asinh(a), -ONE.into(), 'invalid neg one', Option::None(()));

        let a = FixedTrait::new(15577246839, true); // -3.6268604077773023
        assert_precise(asinh(a), -TWO.into(), 'invalid neg two', Option::None(()));
    }

    #[test]
    #[available_gas(10000000)]
    fn test_atanh() {
        let a = FixedTrait::new(3865470566, false); // 0.9
        assert_precise(atanh(a), 6323134560, 'invalid 0.9', Option::None(())); // 1.4722194895832204

        let a = FixedTrait::new(HALF, false); // 0.5
        assert_precise(
            atanh(a), 2359251925, 'invalid half', Option::None(()),
        ); // 0.5493061443340548

        let a = FixedTrait::ZERO();
        assert(atanh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(HALF, true); // 0.5
        assert_precise(
            atanh(a), -2359251925, 'invalid neg half', Option::None(()),
        ); // 0.5493061443340548

        let a = FixedTrait::new(3865470566, true); // 0.9
        assert_precise(
            atanh(a), -6323134560, 'invalid -0.9', Option::None(()),
        ); // 1.4722194895832204
    }
}
