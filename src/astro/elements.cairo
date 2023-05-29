use cubit::types::fixed::{Fixed, FixedTrait, ONE_u128};
use cubit::types::vec3::{Vec3, Vec3Trait};

// Converts from classical orbital elements to state vectors
//
// @param mu Standard gravitational parameter (km^3 / s^2)
// @param p Semi latus rectum or parameter (km)
// @param ecc Eccentricity
// @param inc Inclination (rad)
// @param raan Longitude of ascending node (rad)
// @param argp Argument of periapsis (rad)
// @param nu True anomaly (rad)
fn coe2rv(mu: Fixed, p: Fixed, ecc: Fixed, inc: Fixed, raan: Fixed, argp: Fixed, nu: Fixed) -> (Vec3, Vec3) {
    let one = FixedTrait::new(ONE_u128, false);
    let zero = FixedTrait::new(0, false);

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
        Vec3Trait::new(r_1, r_2, r_3),
        Vec3Trait::new(v_1, v_2, v_3)
    );
}

// Tests --------------------------------------------------------------------------------------------------------------

use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;
use cubit::types::fixed::{FixedInto, FixedPartialEq};


#[test]
#[available_gas(10000000)]
fn test_coe2rv_ellipctical() {
    let mu = FixedTrait::new(7352880337552158511595520, false); // 398600.4418
    let p = FixedTrait::new(204164689591561854386176, false); // 11067.790
    let ecc = FixedTrait::new(15363370801788999680, false); // 0.83285
    let inc = FixedTrait::new(28290310656438095872, false); // 1.5336208137
    let ran = FixedTrait::new(73370648636164349952, false); // 3.9774308324
    let argp = FixedTrait::new(17186033718493698048, false); // 0.9316567547
    let nu = FixedTrait::new(29727846073312419840, false); // 1.6115497648
    let (r, v) = coe2rv(mu, p, ecc, inc, ran, argp, nu);

    let r_tol = 184467440737095_u128; // 0.00001

    assert_precise(r.x, 120371795696383239913472, 'invalid r.x', Option::Some((r_tol))); // 6525.36812
    assert_precise(r.y, 126572921621621952741376, 'invalid r.y', Option::Some((r_tol))); // 6861.53183
    assert_precise(r.z, 118965240499667489259520, 'invalid r.z', Option::Some((r_tol))); // 6449.11861

    assert_precise(v.x, 90431079634560368640, 'invalid v.x', Option::None(())); // 4.90227865
    assert_precise(v.y, 102068409571905323008, 'invalid v.y', Option::None(())); // 5.53313957
    assert_precise(v.z, -36445418578543104000, 'invalid v.z', Option::None(())); // -1.9757101
}

#[test]
#[available_gas(10000000)]
fn test_coe2rv_hyperbolic() {
    let mu = FixedTrait::new(7352880857750341917626859520000000, false); // 3.9860047e14
    let p = FixedTrait::new(901096946328627757539393536, false); // 4.884856334147761e7
    let ecc = FixedTrait::new(31933158665998606336, false); // 1.7311
    let inc = FixedTrait::new(2253048427674737152, false); // 0.122138
    let ran = FixedTrait::new(18572366400851513344, false); // 1.00681
    let argp = FixedTrait::new(57311451292845260800, false); // 3.10686
    let nu = FixedTrait::new(2350410669365469696, false); // 0.12741601769795755
    let (r, v) = coe2rv(mu, p, ecc, inc, ran, argp, nu);

    let r_tol = ONE_u128; // 1.0
    let v_tol = 18446744073709551_u128; // 0.001

    assert_precise(r.x, -150775065987045491923222528, 'invalid r.x', Option::Some((r_tol))); // -8173532.70499
    assert_precise(r.y, -295364435306627703184031744, 'invalid r.y', Option::Some((r_tol))); // -16011738.12172
    assert_precise(r.z, -3739568560635961126420480, 'invalid r.z', Option::Some((r_tol))); // -202722.41788

    assert_precise(v.x, 121397180839683029991424, 'invalid v.x', Option::Some((v_tol))); // 6580.95436
    assert_precise(v.y, -74763278525974121021440, 'invalid v.y', Option::Some((v_tol))); // -4052.92545
    assert_precise(v.z, -17499331288467477889024, 'invalid v.z', Option::Some((v_tol))); // -948.64065
}
