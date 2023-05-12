use array::array_append;
use array::array_new;
use gas::withdraw_gas_all;
use cubit::types::fixed::{Fixed, FixedType};
use cubit::types::fixed::ONE_u128;


// Tolerance for stopping the Newton-Raphson method
const TOLERANCE: u128 = 1844674407370_u128;

// Converts from true anomaly to parabolic eccentric anomaly
//
// @param nu True anomaly (rad)
fn nu_to_D(nu: FixedType) -> FixedType {
    return (nu / Fixed::new(36893488147419103232, false)).tan(); // 2
}

// Converts true anomaly to eccentric anomaly
//
// @param nu True anomaly (rad)
// @param ecc Eccentricity
fn nu_to_E(nu: FixedType, ecc: FixedType) -> FixedType {
    let one = Fixed::new(ONE_u128, false);
    let two = Fixed::new(36893488147419103232, false); // 2
    return two * (((one - ecc) / (one + ecc)).sqrt() * (nu / two).tan()).atan();
}

// Converts from true anomaly to hyperbolic eccentric anomaly
//
// @param nu True anomaly (rad)
// @param ecc Eccentricity
fn nu_to_F(nu: FixedType, ecc: FixedType) -> FixedType {
    let cos_nu = nu.cos();
    return ((ecc + cos_nu) / (Fixed::new(ONE_u128, false) + ecc * cos_nu)).acosh();
}

// Converts from parabolic eccentric anomaly to true anomaly
//
// @param D Parabolic eccentric anomaly (rad)
// @param ecc Eccentricity
fn D_to_M(D: FixedType) -> FixedType {
    let three = Fixed::new(55340232221128654848, false); // 3
    return D + D.pow(three) / three;
}

// Convert from parabolic eccentric anomaly to mean anomaly near parabolic orbit
//
// @param D Parabolic eccentric anomaly (rad)
// @param ecc Eccentricity
fn D_to_M_near_parabolic(D: FixedType, ecc: FixedType) -> FixedType {
    let one = Fixed::new(ONE_u128, false);
    let two = Fixed::new(36893488147419103232, false); // 2
    let three = Fixed::new(55340232221128654848, false); // 3

    let x = (ecc - one) / (ecc + one) * D.pow(two);
    assert(x.abs() < Fixed::new(ONE_u128, false), 'abs(x) must be less than 1');
    let S = _S_x(ecc, x);

    return (two / (one + ecc)).sqrt() * D + (two / (one + ecc).pow(three)).sqrt() * D.pow(three) * S;
}

// Converts from eccentric anomaly to mean anomaly
//
// @param E Eccentric anomaly (rad)
// @param ecc Eccentricity
fn E_to_M(E: FixedType, ecc: FixedType) -> FixedType {
    return E - ecc * E.sin();
}

// Converts from hyperbolic eccentric anomaly to true anomaly
//
// @param F Hyperbolic eccentric anomaly (rad)
// @param ecc Eccentricity
fn F_to_M(F: FixedType, ecc: FixedType) -> FixedType {
    return ecc * F.sinh() - F;
}

// Converts mean anomaly to eccentric anomaly
//
// @param M Mean anomaly (rad)
// @param ecc Eccentricity
fn M_to_E(M: FixedType, ecc: FixedType) -> FixedType {
    let zero = Fixed::new(0, false);
    let mut E = M;

    if M < Fixed::new(0, false) {
        E = E - ecc;
    } else {
        E = E + ecc;
    }

    let tol = Fixed::new(TOLERANCE, false);
    let E1 = loop {
        let f_val = E_to_M(E, ecc) - M;
        let f_der = Fixed::new(ONE_u128, false) - ecc * E.cos();
        let step = f_val / f_der;
        let E1 = E - step;

        if (E - E1).abs() < tol {
            break E1;
        }

        E = E1;
    };

    return E1;
}

// Converts from eccentric anomaly to true anomaly
//
// @param E Eccentric anomaly (rad)
// @param ecc Eccentricity
fn E_to_nu(E: FixedType, ecc: FixedType) -> FixedType {
    let one = Fixed::new(ONE_u128, false);
    let two = Fixed::new(36893488147419103232, false); // 2
    return two * (((one + ecc) / (one - ecc)).sqrt() * (E / two).tan()).atan();
}

fn _S_x(ecc: FixedType, x: FixedType) -> FixedType {
    match withdraw_gas_all(get_builtin_costs()) {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt252>();
            array_append::<felt252>(ref data, 'OOG');
            panic(data);
        },
    }

    assert(x.abs() < Fixed::new(ONE_u128, false), 'abs(x) must be less than 1');
    let mut S = Fixed::new(0, false);
    let mut k = Fixed::new(0, false);
    let one = Fixed::new(ONE_u128, false);

    let result = loop {
        let diff = (ecc - one / (Fixed::new_unscaled(2, false) * k + Fixed::new_unscaled(3, false))) * x.pow(k);

        if diff.abs() < Fixed::new(18446744, false) {
            break S + diff;
        }

        S += diff;
        k += one;
    };

    return result;
}
