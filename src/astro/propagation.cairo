use core::gas::withdraw_gas_all;
use core::integer::u256_sqrt;

use cubit::astro::angles;
use cubit::math::trig::PI_u128;
use cubit::types::fixed::{Fixed, FixedType};
use cubit::types::fixed::ONE_u128;

use debug::PrintTrait;

// Time elapsed since periapsis for given true anomaly.
//
// @param nu True anomaly (rad)
// @param ecc Eccentricity
// @param mu Gravity parameter (km3 / sec^2)
// @param q Periapsis distance (km)
// @param delta Parameter that controls the size of the near parabolic region
fn delta_t_from_nu(nu: FixedType, ecc: FixedType, mu: FixedType, q: FixedType) -> FixedType {
    let pi = Fixed::new(PI_u128, false);
    let one = Fixed::new(ONE_u128, false);
    let two = Fixed::new(36893488147419103232, false);
    let three = Fixed::new(55340232221128654848, false);
    let delta = Fixed::new(184467440737095516, false); // 0.01

    assert(nu < pi, 'nu must be < pi');
    assert(nu >= -pi, 'nu must be >= -pi');
    assert(ecc >= Fixed::new(0, false), 'ecc must be > 0');
    assert(one + ecc * nu.cos() >= Fixed::new(0, false), 'unfeasible region');

    let mut M = Fixed::new(0, false);
    let mut n = Fixed::new(0, false);

    withdraw_gas_all(get_builtin_costs()); // TODO: Why is this needed?

    if ecc < one - delta {
        // Strong elliptic
        let E = angles::nu_to_E(nu, ecc);
        M = angles::E_to_M(E, ecc);
        n = _elliptical_n(mu, ecc, q);
    } else if ecc < one {
        let E = angles::nu_to_E(nu, ecc);

        if delta <= one - ecc * E.cos() {
            // Strong elliptic
            M = angles::E_to_M(E, ecc);
            n = _elliptical_n(mu, ecc, q);
        } else {
            // Near parabolic low
            let D = angles::nu_to_D(nu);
            M = angles::D_to_M_near_parabolic(D, ecc);
            n = _parabolic_n(mu, ecc, q);
        }
    } else if ecc == one {
        // Parabolic
        let D = angles::nu_to_D(nu);
        M = angles::D_to_M(D);
        n = (mu / (two * q.pow(three))).sqrt();
    } else if ecc <= one + delta {
        let F = angles::nu_to_F(nu, ecc);

        if delta <= ecc * F.cosh() - one {
            // Strong hyperbolic
            M = angles::F_to_M(F, ecc);
            n = _hyperbolic_n(mu, ecc, q);
        } else {
            // Near parabolic high
            let D = angles::nu_to_D(nu);
            M = angles::D_to_M_near_parabolic(D, ecc);
            n = _parabolic_n(mu, ecc, q);
        }
    } else {
        // Strong hyperbolic
        let F = angles::nu_to_F(nu, ecc);
        M = angles::F_to_M(F, ecc);
        n = _hyperbolic_n(mu, ecc, q);
    }

    let sec_hour = Fixed::new(66408278665354385817600, false); // 3600
    return M * sec_hour / n;
}

fn _elliptical_n(mu: FixedType, ecc: FixedType, q: FixedType) -> FixedType {
    let one = Fixed::new(ONE_u128, false);
    let one_ecc_q = (one - ecc) / q;
    let sec_hour_2 = Fixed::new(239069803195275788943360000, false); // 3600^2
    return (mu * sec_hour_2 * one_ecc_q * one_ecc_q * one_ecc_q).sqrt();
}

fn _parabolic_n(mu: FixedType, ecc: FixedType, q: FixedType) -> FixedType {
    let sec_hour_2 = Fixed::new(239069803195275788943360000, false); // 3600^2
    let two = Fixed::new(36893488147419103232, false);
    return (mu * sec_hour_2 / two / q / q / q).sqrt();
}

fn _hyperbolic_n(mu: FixedType, ecc: FixedType, q: FixedType) -> FixedType {
    let one = Fixed::new(ONE_u128, false);
    let one_ecc_q = (ecc - one) / q;
    let sec_hour_2 = Fixed::new(239069803195275788943360000, false); // 3600^2
    return (mu * sec_hour_2 * one_ecc_q * one_ecc_q * one_ecc_q).sqrt();
}
