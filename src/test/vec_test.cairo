use debug::PrintTrait;

use cubit::types::fixed::Fixed;
use cubit::types::vec3::Vec3;
use cubit::types::vec3::Vec3Print;


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
    let a = Vec3::new(Fixed::new(1_u128, false), Fixed::new(1_u128, false), Fixed::new(1_u128, false));
    let b = Vec3::new(Fixed::new(4_u128, false), Fixed::new(4_u128, false), Fixed::new(4_u128, false));
    let c = a.cross(b);
    assert(c.x == Fixed::new(0_u128, false), 'invalid cross');
    assert(c.y == Fixed::new(0_u128, false), 'invalid cross');
    assert(c.z == Fixed::new(0_u128, false), 'invalid cross');
}
