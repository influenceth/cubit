use debug::PrintTrait;
use gas::withdraw_gas_all;
use option::OptionTrait;
use traits::Into;

use cubit::test::helpers::assert_precise;

use cubit::types::fixed::{Fixed, FixedInto, ONE_u128};
use cubit::astro::angles::{M_to_E, E_to_nu, D_to_M_near_parabolic, nu_to_E};


#[test]
#[available_gas(100000000)]
fn test_M_to_E() {
    let mut E = M_to_E(Fixed::new_unscaled(1, false), Fixed::new(9223372036854775808, false));
    assert_precise(E, 27646155634686984192, 'invalid E1', Option::None(())); // 1.4987011
    E = M_to_E(Fixed::new_unscaled(3, false), Fixed::new(2305843009213693952, false));
    assert_precise(E, 55629764937411969024, 'invalid E2', Option::None(())); // 3.0156956
    E = M_to_E(Fixed::new_unscaled(4, false), Fixed::new(16602069666338596864, false));
    assert_precise(E, 66425956180200218624, 'invalid E3', Option::None(())); // 3.6009583
    E = M_to_E(Fixed::new_unscaled(5, false), Fixed::new(18262276632972455936, false));
    assert_precise(E, 76704957904068280320, 'invalid E4', Option::None(())); // 4.1581841
    E = M_to_E(Fixed::new_unscaled(4, true), Fixed::new(9223372036854775808, false));
    assert_precise(E, -68708454834788638720, 'invalid E5', Option::None(())); // -3.7246928
}

#[test]
#[available_gas(100000000)]
fn test_E_to_nu() {
    let mut nu = E_to_nu(Fixed::new_unscaled(4, true), Fixed::new(2305843009213693952, false));
    assert_precise(nu, 43799085820993306624, 'invalid nu', Option::None(())); // 2.3743532
    nu = E_to_nu(Fixed::new_unscaled(2, true), Fixed::new(9223372036854775808, false));
    assert_precise(nu, -44854733954750668800, 'invalid nu', Option::None(())); // -2.4315800
    nu = E_to_nu(Fixed::new_unscaled(0, false), Fixed::new(13835058055282163712, false));
    assert_precise(nu, 0, 'invalid nu', Option::None(())); // 0.0000000
    nu = E_to_nu(Fixed::new_unscaled(2, false), Fixed::new(16602069666338596864, false));
    assert_precise(nu, 52556323392500703232, 'invalid nu', Option::None(())); // 2.8490840
    nu = E_to_nu(Fixed::new_unscaled(4, false), Fixed::new(18262276632972455936, false));
    assert_precise(nu, -56755658272602021888, 'invalid nu', Option::None(())); // -3.0767304
}

#[test]
#[available_gas(100000000)]
fn test_D_to_M_near_parabolic() {
     // 0.5, 0.995
    let mut M = D_to_M_near_parabolic(Fixed::new(9223372036854775808, false), Fixed::new(18354510353341003857, false));
    assert_precise(M, 10000066228410604000, 'invalid M1', Option::None(())); // 0.542104676492085

    withdraw_gas_all(get_builtin_costs()); // TODO: Why is this needed?

    // 0.5, 1.005
    M = D_to_M_near_parabolic(Fixed::new(9223372036854775808, false), Fixed::new(18538977794078099374, false));
    assert_precise(M, 9983925304577888000, 'invalid M1', Option::None(())); // 0.5412296752578174
}
