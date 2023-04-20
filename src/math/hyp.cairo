use option::OptionTrait;
use traits::Into;

use cubit::types::fixed::ONE_u128;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::FixedImpl;
use cubit::types::fixed::FixedInto;
use cubit::types::fixed::FixedAdd;
use cubit::types::fixed::FixedSub;
use cubit::types::fixed::FixedMul;
use cubit::types::fixed::FixedDiv;


// PUBLIC

// Calculates hyperbolic cosine of a (fixed point)
fn cosh(a: FixedType) -> FixedType {
    let ea = a.exp();
    let num = ea + (Fixed::new(ONE_u128, false) / ea);
    let den = Fixed::new_unscaled(2_u128, false);
    return num / den;
}

// Calculates hyperbolic sine of a (fixed point)
fn sinh(a: FixedType) -> FixedType {
    let ea = a.exp();
    let num = ea - (Fixed::new(ONE_u128, false) / ea);
    let den = Fixed::new_unscaled(2_u128, false);
    return num / den;
}

// Calculates hyperbolic tangent of a (fixed point)
fn tanh(a: FixedType) -> FixedType {
    let ea = a.exp();
    let ea_i = Fixed::new(ONE_u128, false) / ea;
    return (ea - ea_i) / (ea + ea_i);
}

// Calculates inverse hyperbolic cosine of a (fixed point)
fn acosh(a: FixedType) -> FixedType {
    let root = (a * a - Fixed::new(ONE_u128, false)).sqrt();
    return (a + root).ln();
}

// Calculates inverse hyperbolic sine of a (fixed point)
fn asinh(a: FixedType) -> FixedType {
    let root = (a * a + Fixed::new(ONE_u128, false)).sqrt();
    return (a + root).ln();
}

// Calculates inverse hyperbolic tangent of a (fixed point)
fn atanh(a: FixedType) -> FixedType {
    let one = Fixed::new(ONE_u128, false);
    let ln_arg = (one + a) / (one - a);
    return ln_arg.ln() / Fixed::new_unscaled(2_u128, false);
}
