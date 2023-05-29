use cubit::types::fixed::{Fixed, FixedTrait, ONE_u128};

// Tolerance for stopping the Newton-Raphson method
const TOLERANCE: u128 = 1844674407370_u128;

// Converts from true anomaly to parabolic eccentric anomaly
//
// @param nu True anomaly (rad)
fn nu_to_D(nu: Fixed) -> Fixed {
    return (nu / FixedTrait::new(36893488147419103232, false)).tan(); // 2
}

// Converts true anomaly to eccentric anomaly
//
// @param nu True anomaly (rad)
// @param ecc Eccentricity
fn nu_to_E(nu: Fixed, ecc: Fixed) -> Fixed {
    let one = FixedTrait::new(ONE_u128, false);
    let two = FixedTrait::new(36893488147419103232, false); // 2
    return two * (((one - ecc) / (one + ecc)).sqrt() * (nu / two).tan()).atan();
}

// Converts from true anomaly to hyperbolic eccentric anomaly
//
// @param nu True anomaly (rad)
// @param ecc Eccentricity
fn nu_to_F(nu: Fixed, ecc: Fixed) -> Fixed {
    let one = FixedTrait::new(ONE_u128, false);
    let two = FixedTrait::new(36893488147419103232, false); // 2
    return two * (((ecc - one) / (ecc + one)).sqrt() * (nu / two).tan()).atanh();
}

// Converts from parabolic eccentric anomaly to true anomaly
//
// @param D Parabolic eccentric anomaly (rad)
// @param ecc Eccentricity
fn D_to_M(D: Fixed) -> Fixed {
    let three = FixedTrait::new(55340232221128654848, false); // 3
    return D + D.pow(three) / three;
}

// Convert from parabolic eccentric anomaly to mean anomaly near parabolic orbit
//
// @param D Parabolic eccentric anomaly (rad)
// @param ecc Eccentricity
fn D_to_M_near_parabolic(D: Fixed, ecc: Fixed) -> Fixed {
    let one = FixedTrait::new(ONE_u128, false);
    let two = FixedTrait::new(36893488147419103232, false); // 2
    let three = FixedTrait::new(55340232221128654848, false); // 3

    let x = (ecc - one) / (ecc + one) * D.pow(two);
    assert(x.abs() < FixedTrait::new(ONE_u128, false), 'abs(x) must be less than 1');
    let S = _S_x(ecc, x);

    return (two / (one + ecc)).sqrt() * D + (two / (one + ecc).pow(three)).sqrt() * D.pow(three) * S;
}

// Converts from eccentric anomaly to mean anomaly
//
// @param E Eccentric anomaly (rad)
// @param ecc Eccentricity
fn E_to_M(E: Fixed, ecc: Fixed) -> Fixed {
    return E - ecc * E.sin();
}

// Converts from hyperbolic eccentric anomaly to true anomaly
//
// @param F Hyperbolic eccentric anomaly (rad)
// @param ecc Eccentricity
fn F_to_M(F: Fixed, ecc: Fixed) -> Fixed {
    return ecc * F.sinh() - F;
}

// Converts mean anomaly to eccentric anomaly
//
// @param M Mean anomaly (rad)
// @param ecc Eccentricity
fn M_to_E(M: Fixed, ecc: Fixed) -> Fixed {
    let zero = FixedTrait::new(0, false);
    let mut E = M;

    if M < FixedTrait::new(0, false) {
        E = E - ecc;
    } else {
        E = E + ecc;
    }

    let tol = FixedTrait::new(TOLERANCE, false);
    let E1 = loop {
        let f_val = E_to_M(E, ecc) - M;
        let f_der = FixedTrait::new(ONE_u128, false) - ecc * E.cos();
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
fn E_to_nu(E: Fixed, ecc: Fixed) -> Fixed {
    let one = FixedTrait::new(ONE_u128, false);
    let two = FixedTrait::new(36893488147419103232, false); // 2
    return two * (((one + ecc) / (one - ecc)).sqrt() * (E / two).tan()).atan();
}

fn _S_x(ecc: Fixed, x: Fixed) -> Fixed {
    assert(x.abs() < FixedTrait::new(ONE_u128, false), 'abs(x) must be less than 1');
    let mut S = FixedTrait::new(0, false);
    let mut k = FixedTrait::new(0, false);
    let one = FixedTrait::new(ONE_u128, false);

    let result = loop {
        let diff = (ecc - one / (FixedTrait::new_unscaled(2, false) * k + FixedTrait::new_unscaled(3, false))) * x.pow(k);

        if diff.abs() < FixedTrait::new(18446744, false) {
            break S + diff;
        }

        S += diff;
        k += one;
    };

    return result;
}

// Tests --------------------------------------------------------------------------------------------------------------

use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;
use cubit::types::fixed::{FixedInto};


#[test]
#[available_gas(100000000)]
fn test_M_to_E() {
    let mut E = M_to_E(FixedTrait::new_unscaled(1, false), FixedTrait::new(9223372036854775808, false));
    assert_precise(E, 27646155634686984192, 'invalid E1', Option::None(())); // 1.4987011
    E = M_to_E(FixedTrait::new_unscaled(3, false), FixedTrait::new(2305843009213693952, false));
    assert_precise(E, 55629764937411969024, 'invalid E2', Option::None(())); // 3.0156956
    E = M_to_E(FixedTrait::new_unscaled(4, false), FixedTrait::new(16602069666338596864, false));
    assert_precise(E, 66425956180200218624, 'invalid E3', Option::None(())); // 3.6009583
    E = M_to_E(FixedTrait::new_unscaled(5, false), FixedTrait::new(18262276632972455936, false));
    assert_precise(E, 76704957904068280320, 'invalid E4', Option::None(())); // 4.1581841
    E = M_to_E(FixedTrait::new_unscaled(4, true), FixedTrait::new(9223372036854775808, false));
    assert_precise(E, -68708454834788638720, 'invalid E5', Option::None(())); // -3.7246928
}

#[test]
#[available_gas(100000000)]
fn test_E_to_nu() {
    let mut nu = E_to_nu(FixedTrait::new_unscaled(4, true), FixedTrait::new(2305843009213693952, false));
    assert_precise(nu, 43799085820993306624, 'invalid nu', Option::None(())); // 2.3743532
    nu = E_to_nu(FixedTrait::new_unscaled(2, true), FixedTrait::new(9223372036854775808, false));
    assert_precise(nu, -44854733954750668800, 'invalid nu', Option::None(())); // -2.4315800
    nu = E_to_nu(FixedTrait::new_unscaled(0, false), FixedTrait::new(13835058055282163712, false));
    assert_precise(nu, 0, 'invalid nu', Option::None(())); // 0.0000000
    nu = E_to_nu(FixedTrait::new_unscaled(2, false), FixedTrait::new(16602069666338596864, false));
    assert_precise(nu, 52556323392500703232, 'invalid nu', Option::None(())); // 2.8490840
    nu = E_to_nu(FixedTrait::new_unscaled(4, false), FixedTrait::new(18262276632972455936, false));
    assert_precise(nu, -56755658272602021888, 'invalid nu', Option::None(())); // -3.0767304
}

#[test]
#[available_gas(100000000)]
fn test_D_to_M_near_parabolic() {
     // 0.5, 0.995
    let mut M = D_to_M_near_parabolic(FixedTrait::new(9223372036854775808, false), FixedTrait::new(18354510353341003857, false));
    assert_precise(M, 10000066228410604000, 'invalid M1', Option::None(())); // 0.542104676492085
    // 0.5, 1.005
    M = D_to_M_near_parabolic(FixedTrait::new(9223372036854775808, false), FixedTrait::new(18538977794078099374, false));
    assert_precise(M, 9983925304577888000, 'invalid M1', Option::None(())); // 0.5412296752578174
}
