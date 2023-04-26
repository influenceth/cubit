use cubit::procgen::simplex3;
use cubit::types::fixed::Fixed;
use cubit::types::vec3::Vec3;


#[test]
fn test_simplex3() {
    let coord = Vec3::new(
        Fixed::new_unscaled(1_u128, false),
        Fixed::new_unscaled(1_u128, false),
        Fixed::new_unscaled(1_u128, false)
    );

    simplex3::noise(coord);
}