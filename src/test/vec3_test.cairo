use cubit::test::helpers::assert_precise;

use cubit::types::fixed::Fixed;
use cubit::types::vec3::Vec3;


#[test]
fn test_add() {
    let a = Vec3::new(Fixed::new(1_u128, false), Fixed::new(2_u128, false), Fixed::new(3_u128, false));
    let b = Vec3::new(Fixed::new(4_u128, false), Fixed::new(5_u128, false), Fixed::new(6_u128, false));
    let c = a + b;
    assert(c.x == Fixed::new(5_u128, false), 'invalid add');
    assert(c.y == Fixed::new(7_u128, false), 'invalid add');
    assert(c.z == Fixed::new(9_u128, false), 'invalid add');
}

#[test]
fn test_mul() {
    let a = Vec3::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, false), Fixed::new_unscaled(3_u128, false));
    let b = Vec3::new(Fixed::new_unscaled(4_u128, false), Fixed::new_unscaled(5_u128, false), Fixed::new_unscaled(6_u128, false));
    let c = a * b;
    assert(c.x == Fixed::new_unscaled(4_u128, false), 'invalid mul');
    assert(c.y == Fixed::new_unscaled(10_u128, false), 'invalid mul');
    assert(c.z == Fixed::new_unscaled(18_u128, false), 'invalid mul');
}

#[test]
fn test_div() {
    let a = Vec3::new(Fixed::new(4_u128, false), Fixed::new(10_u128, false), Fixed::new(6_u128, false));
    let b = Vec3::new(Fixed::new(1_u128, false), Fixed::new(5_u128, false), Fixed::new(3_u128, false));
    let c = a / b;
    assert(c.x == Fixed::new_unscaled(4_u128, false), 'invalid div');
    assert(c.y == Fixed::new_unscaled(2_u128, false), 'invalid div');
    assert(c.z == Fixed::new_unscaled(2_u128, false), 'invalid div');
}

#[test]
fn test_dot() {
    let a = Vec3::new(Fixed::new_unscaled(4_u128, false), Fixed::new_unscaled(10_u128, false), Fixed::new_unscaled(6_u128, false));
    let b = Vec3::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(5_u128, false), Fixed::new_unscaled(3_u128, false));
    let c = a.dot(b);
    assert(c == Fixed::new_unscaled(72_u128, false), 'invalid dot');
}

#[test]
fn test_sub() {
    let a = Vec3::new(Fixed::new(4_u128, false), Fixed::new(10_u128, false), Fixed::new(6_u128, false));
    let b = Vec3::new(Fixed::new(1_u128, false), Fixed::new(5_u128, false), Fixed::new(3_u128, false));
    let c = a - b;
    assert(c.x == Fixed::new(3_u128, false), 'invalid sub');
    assert(c.y == Fixed::new(5_u128, false), 'invalid sub');
    assert(c.z == Fixed::new(3_u128, false), 'invalid sub');
}

#[test]
fn test_cross() {
    let a = Vec3::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, false), Fixed::new_unscaled(3_u128, false));
    let b = Vec3::new(Fixed::new_unscaled(4_u128, false), Fixed::new_unscaled(5_u128, false), Fixed::new_unscaled(6_u128, false));
    let c = a.cross(b);
    assert(c.x == Fixed::new_unscaled(3_u128, true), 'invalid cross1');
    assert(c.y == Fixed::new_unscaled(6_u128, false), 'invalid cross2');
    assert(c.z == Fixed::new_unscaled(3_u128, true), 'invalid cross3');
}

#[test]
fn test_norm() {
    let a = Vec3::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, false), Fixed::new_unscaled(3_u128, false));
    let b = a.norm();
    assert_precise(b, 69021396225323770000, 'invalid norm'); // sqrt(14)
}

#[test]
fn test_abs() {
    let a = Vec3::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, true), Fixed::new_unscaled(3_u128, true));
    let b = a.abs();
    assert(b.x == Fixed::new_unscaled(1_u128, false), 'invalid abs');
    assert(b.y == Fixed::new_unscaled(2_u128, false), 'invalid abs');
    assert(b.z == Fixed::new_unscaled(3_u128, false), 'invalid abs');
}

#[test]
fn test_floor() {
    let a = Vec3::new(
        Fixed::new(27670116110564327000_u128, false), // 1.5
        Fixed::new(59029581035870570000_u128, true), // -3.2
        Fixed::new(0_u128, false)
    );

    let b = a.floor();
    assert(b.x == Fixed::new_unscaled(1_u128, false), 'invalid floor');
    assert(b.y == Fixed::new_unscaled(4_u128, true), 'invalid floor');
    assert(b.z == Fixed::new(0_u128, false), 'invalid floor');
}
