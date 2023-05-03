use debug::PrintTrait;

use cubit::test::helpers::assert_precise;

use cubit::procgen::simplex3;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedPrint;
use cubit::types::vec3::Vec3;


#[test]
#[available_gas(10000000)]
fn test_simplex3_1() {
    let r = simplex3::noise(Vec3::splat(Fixed::new(0_u128, false))); // [ 0, 0, 0 ]
    assert_precise(r, -8040438090352662000, '0,0,0 out of bounds', Option::None(())); // -0.43587
}

#[test]
#[available_gas(10000000)]
fn test_simplex3_2() {
    // [0.5, -1.23, 1.63]
    let r = simplex3::noise(
        Vec3::new(
            Fixed::from_felt(9223372036854776000),
            Fixed::from_felt(-22689495210662750000),
            Fixed::from_felt(30068192840146567000)
        )
    );
    assert_precise(r, 13375152626318328000, '0.5... out of bounds', Option::None(())); // 0.72507
}

#[test]
#[available_gas(10000000)]
fn test_simplex3_3() {
    // [-1.94, -1.25, -1.63]
    let r = simplex3::noise(
        Vec3::new(
            Fixed::from_felt(-35786683502996530000),
            Fixed::from_felt(-23058430092136940000),
            Fixed::from_felt(-30068192840146567000)
        )
    );
    assert_precise(r, 2842256034349449700, '-1.94... out of bounds', Option::None(())); // 0.15408
}

#[test]
#[available_gas(10000000)]
fn test_simplex3_4() {
    // [-9.99, 8.25, 6.98]
    let r = simplex3::noise(
        Vec3::new(
            Fixed::from_felt(-184282973296358420000),
            Fixed::from_felt(152185638608103800000),
            Fixed::from_felt(128758273634492680000)
        )
    );
    assert_precise(
        r, -14610501553210167000, '-9.99... out of bounds', Option::None(())
    ); // -0.79204
}

#[test]
#[available_gas(10000000)]
fn test_simplex3_5() {
    // [-0.005, 12.578, -2.87]
    let r = simplex3::noise(
        Vec3::new(
            Fixed::from_felt(-92233720368547760),
            Fixed::from_felt(232023146959118730000),
            Fixed::from_felt(-52942155491546415000)
        )
    );
    assert_precise(
        r, -7380847965597703000, '-0.005... out of bounds', Option::None(())
    ); // -0.40012
}

#[test]
#[available_gas(20000000)]
fn test_simplex3_octaves_1() {
    // [0.0, 0.0, 0.0]
    let r = simplex3::noise_octaves(
        Vec3::splat(Fixed::new(0_u128, false)), 2_u128, Fixed::new(9223372036854775808_u128, false)
    );
    assert_precise(r, -8040438090352662000, '... out of bounds', Option::None(())); // -0.4359
}

#[test]
#[available_gas(30000000)]
fn test_simplex3_octaves_2() {
    // [0.5, -1.23, 1.63]
    let r = simplex3::noise_octaves(
        Vec3::new(
            Fixed::from_felt(9223372036854776000),
            Fixed::from_felt(-22689495210662750000),
            Fixed::from_felt(30068192840146567000),
        ),
        3_u128,
        Fixed::new(9223372036854775808_u128, false)
    );
    assert_precise(r, 6054457010196317000, '... out of bounds', Option::None(())); // 0.3282
}

#[test]
#[available_gas(40000000)]
fn test_simplex3_octaves_3() {
    // [-1.94, -1.25, -1.63]
    let r = simplex3::noise_octaves(
        Vec3::new(
            Fixed::from_felt(-35786683502996530000),
            Fixed::from_felt(-23058430092136940000),
            Fixed::from_felt(-30068192840146567000)
        ),
        4_u128,
        Fixed::new(9223372036854775808_u128, false)
    );
    assert_precise(r, 2498284309949725700, '... out of bounds', Option::None(())); // 0.1354
}

#[test]
#[available_gas(50000000)]
fn test_simplex3_octaves_4() {
    // [-9.99, 8.25, 6.98]
    let r = simplex3::noise_octaves(
        Vec3::new(
            Fixed::from_felt(-184282973296358420000),
            Fixed::from_felt(152185638608103800000),
            Fixed::from_felt(128758273634492680000)
        ),
        5_u128,
        Fixed::new(9223372036854775808_u128, false)
    );
    assert_precise(r, -6784442150430373000, '... out of bounds', Option::None(())); // -0.3678
}

#[test]
#[available_gas(60000000)]
fn test_simplex3_octaves_5() {
    // [-0.005, 12.578, -2.87]
    let r = simplex3::noise_octaves(
        Vec3::new(
            Fixed::from_felt(-92233720368547760),
            Fixed::from_felt(232023146959118730000),
            Fixed::from_felt(-52942155491546415000)
        ),
        6_u128,
        Fixed::new(9223372036854775808_u128, false)
    );
    assert_precise(r, -3360150313341259000, '... out of bounds', Option::None(())); // -0.1822
}
