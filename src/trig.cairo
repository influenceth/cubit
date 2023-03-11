use gas::try_fetch_gas;
use option::OptionTrait;
use traits::Into;

use cubit::core::ONE_u128;
use cubit::core::Fixed;
use cubit::core::FixedType;
use cubit::core::FixedImpl;
use cubit::core::FixedInto;
use cubit::core::FixedAdd;
use cubit::core::FixedSub;
use cubit::core::FixedMul;
use cubit::core::FixedDiv;


// CONSTANTS

const PI_u128: u128 = 57952155664616982739_u128;
const HALF_PI_u128: u128 = 28976077832308491370_u128;

// PUBLIC

// Calculates cos(x) with x in radians (fixed point)
fn cos(a: FixedType) -> FixedType {
    return sin(Fixed::new(HALF_PI_u128, false) - a);
}

fn sin(a: FixedType) -> FixedType {
    let a1_u128 = a.mag % (2_u128 * PI_u128);
    let whole_rem = a1_u128 / PI_u128;
    let a2 = FixedType { mag: a1_u128 % PI_u128, sign: false };
    let mut partial_sign = false;

    if (whole_rem == 1_u128) {
        partial_sign = true;
    }

    let acc = FixedType { mag: ONE_u128, sign: false };
    let loop_res = a2 * _sin_loop(a2, 6_u128, acc);
    let res_sign = a.sign ^ partial_sign;
    return FixedType { mag: loop_res.mag, sign: res_sign };
}

// Calculates tan(x) with x in radians (fixed point)
fn tan(a: FixedType) -> FixedType {
    let sinx = sin(a);
    let cosx = cos(a);
    assert(cosx.mag != 0_u128, 'tan undefined');
    return sinx / cosx;
}

// INTERNAL

// Helper function to calculate Taylor series for sin
fn _sin_loop(a: FixedType, i: u128, acc: FixedType) -> FixedType   {
    match try_fetch_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt>();
            array_append::<felt>(ref data, 'OOG');
            panic(data);
        },
    }

    let div_u128 = (2_u128 * i + 2_u128) * (2_u128 * i + 3_u128);
    let term = a * a * acc / Fixed::new_unscaled(div_u128, false);
    let new_acc = Fixed::new(ONE_u128, false) - term;

    if (i == 0_u128) {
        return new_acc;
    }

    return _sin_loop(a, i - 1_u128, new_acc);
}
