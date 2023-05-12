use debug::PrintTrait;
use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;
use cubit::test::helpers::assert_relative;

use cubit::types::fixed::{Fixed, FixedInto, ONE_u128};
use cubit::astro::propagation::delta_t_from_nu;


#[test]
#[available_gas(100000000)]
fn test_delta_t_from_nu_elliptical() {
    let nu = Fixed::new(17488672759741688000, false);
    let ecc = Fixed::new(5995191823955604275, false);
    let mu = Fixed::new(2097177683003028457316679680000, false);
    let q = Fixed::new(5410100577969855036380938240, false) / (Fixed::new(ONE_u128, false) + ecc);
    let t = delta_t_from_nu(nu, ecc, mu, q);
    assert_relative(t, 159889915484693139365560320, 'invalid time', Option::Some((18446744073709))); // 8667657 sec
}

#[test]
#[available_gas(100000000)]
fn test_delta_t_from_nu_hyperbolic() {
    let nu = Fixed::new(2350410669365469696, false);
    let ecc = Fixed::new(31933158665998606336, false);
    let mu = Fixed::new(7352880304348019749289984, false);
    let q = Fixed::new(901096946328627742507008, false) / (Fixed::new(ONE_u128, false) + ecc);
    let t = delta_t_from_nu(nu, ecc, mu, q);
    assert_relative(t, 5407171959967992250368, 'invalid time', Option::Some((18446744073709))); // 293.1233793 sec
}

#[test]
#[available_gas(100000000)]
fn test_delta_t_from_nu_parabolic_low() {
    let nu = Fixed::new(9223372036854775808, false);
    let ecc = Fixed::new(18354510353341003776, false);
    let mu = Fixed::new(7352880304348019749289984, false);
    let q = Fixed::new(4899602799929846585622528, false) / (Fixed::new(ONE_u128, false) + ecc);
    let t = delta_t_from_nu(nu, ecc, mu, q);
    assert_relative(t, 524285997049854455447552, 'invalid time', Option::Some((18446744073709))); // 28421.60085 sec
}

#[test]
#[available_gas(100000000)]
fn test_delta_t_from_nu_parabolic_high() {
    let nu = Fixed::new(18446744073709551616, false);
    let ecc = Fixed::new(18538977794078097408, false);
    let mu = Fixed::new(7352880304348019749289984, false);
    let q = Fixed::new(4899602799929846585622528, false) / (Fixed::new(ONE_u128, false) + ecc);
    let t = delta_t_from_nu(nu, ecc, mu, q);
    assert_relative(t, 1195821455086349690339328, 'invalid time', Option::Some((18446744073709))); // 64825.610975 sec
}
