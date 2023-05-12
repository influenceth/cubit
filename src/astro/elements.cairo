use gas::withdraw_gas_all;

use cubit::types::fixed::{Fixed, FixedType};
use cubit::types::vec3::{Vec3, Vec3Type};
use cubit::types::fixed::ONE_u128;


// Converts from classical orbital elements to state vectors
//
// @param mu Standard gravitational parameter (km^3 / s^2)
// @param p Semi latus rectum or parameter (km)
// @param ecc Eccentricity
// @param inc Inclination (rad)
// @param raan Longitude of ascending node (rad)
// @param argp Argument of periapsis (rad)
// @param nu True anomaly (rad)
fn coe2rv(
    mu: FixedType, p: FixedType, ecc: FixedType, inc: FixedType, raan: FixedType, argp: FixedType, nu: FixedType
) -> (Vec3Type, Vec3Type) {
    let one = Fixed::new(ONE_u128, false);
    let zero = Fixed::new(0, false);

    // Calculate pqw r & v vectors
    let sin_nu = nu.sin();
    let cos_nu = nu.cos();
    let radius = p / (one + ecc * cos_nu);
    let sqrt_mu_p = (mu / p).sqrt();

    let pqw_1_1 = cos_nu * radius;
    let pqw_1_2 = sin_nu * radius;
    let pqw_1_3 = zero;
    let pqw_2_1 = -sin_nu * sqrt_mu_p;
    let pqw_2_2 = (ecc + cos_nu) * sqrt_mu_p;
    let pqw_2_3 = zero;

    // Precompute angle trig values
    let sin_raan = raan.sin();
    let cos_raan = raan.cos();
    let sin_inc = inc.sin();
    let cos_inc = inc.cos();
    let sin_argp = argp.sin();
    let cos_argp = argp.cos();

    withdraw_gas_all(get_builtin_costs()); // TODO: Why is this needed?

    // Transposed rotation matrix
    let rm_1_1 = cos_raan * cos_argp + -sin_raan * cos_inc * sin_argp;
    let rm_1_2 = sin_raan * cos_argp +  cos_raan * cos_inc * sin_argp;
    let rm_1_3 = sin_inc * sin_argp;
    let rm_2_1 = cos_raan * -sin_argp + -sin_raan * cos_inc * cos_argp;
    let rm_2_2 = sin_raan * -sin_argp +  cos_raan * cos_inc * cos_argp;
    let rm_2_3 = sin_inc * cos_argp;
    let rm_3_1 = -sin_raan * -sin_inc;
    let rm_3_2 = cos_raan * -sin_inc;
    let rm_3_3 = cos_inc;

    // Apply rotation matrix to pqw vectors
    let r_1 = pqw_1_1 * rm_1_1 + pqw_1_2 * rm_2_1 + pqw_1_3 * rm_3_1;
    let r_2 = pqw_1_1 * rm_1_2 + pqw_1_2 * rm_2_2 + pqw_1_3 * rm_3_2;
    let r_3 = pqw_1_1 * rm_1_3 + pqw_1_2 * rm_2_3 + pqw_1_3 * rm_3_3;
    let v_1 = pqw_2_1 * rm_1_1 + pqw_2_2 * rm_2_1 + pqw_2_3 * rm_3_1;
    let v_2 = pqw_2_1 * rm_1_2 + pqw_2_2 * rm_2_2 + pqw_2_3 * rm_3_2;
    let v_3 = pqw_2_1 * rm_1_3 + pqw_2_2 * rm_2_3 + pqw_2_3 * rm_3_3;

    return (
        Vec3::new(r_1, r_2, r_3),
        Vec3::new(v_1, v_2, v_3)
    );
}
