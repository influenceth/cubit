use cubit::test::helpers::assert_precise;

use cubit::types::fixed::Fixed;
use cubit::types::vec4::Vec4;


#[test]
fn test_add() {
    let a = Vec4::new(Fixed::new(1_u128, false), Fixed::new(2_u128, false), Fixed::new(3_u128, false), Fixed::new(4_u128, false));
    let b = Vec4::new(Fixed::new(5_u128, false), Fixed::new(6_u128, false), Fixed::new(7_u128, false), Fixed::new(8_u128, false));
    let c = a + b;
    assert(c.x == Fixed::new(6_u128, false), 'invalid add');
    assert(c.y == Fixed::new(8_u128, false), 'invalid add');
    assert(c.z == Fixed::new(10_u128, false), 'invalid add');
    assert(c.w == Fixed::new(12_u128, false), 'invalid add');
}

#[test]
fn test_sub() {
    let a = Vec4::new(Fixed::new(1_u128, false), Fixed::new(2_u128, false), Fixed::new(3_u128, false), Fixed::new(4_u128, false));
    let b = Vec4::new(Fixed::new(5_u128, false), Fixed::new(6_u128, false), Fixed::new(7_u128, false), Fixed::new(8_u128, false));
    let c = a - b;
    assert(c.x == Fixed::new(4_u128, true), 'invalid sub');
    assert(c.y == Fixed::new(4_u128, true), 'invalid sub');
    assert(c.z == Fixed::new(4_u128, true), 'invalid sub');
    assert(c.w == Fixed::new(4_u128, true), 'invalid sub');
}

#[test]
fn test_mul() {
    let a = Vec4::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, false), Fixed::new_unscaled(3_u128, false), Fixed::new_unscaled(4_u128, false));
    let b = Vec4::new(Fixed::new_unscaled(5_u128, false), Fixed::new_unscaled(6_u128, false), Fixed::new_unscaled(7_u128, false), Fixed::new_unscaled(8_u128, false));
    let c = a * b;
    assert(c.x == Fixed::new_unscaled(5_u128, false), 'invalid mul');
    assert(c.y == Fixed::new_unscaled(12_u128, false), 'invalid mul');
    assert(c.z == Fixed::new_unscaled(21_u128, false), 'invalid mul');
    assert(c.w == Fixed::new_unscaled(32_u128, false), 'invalid mul');
}

#[test]
fn test_div() {
    let a = Vec4::new(Fixed::new(15_u128, false), Fixed::new(20_u128, false), Fixed::new(1_u128, false), Fixed::new(8_u128, false));
    let b = Vec4::new(Fixed::new(5_u128, false), Fixed::new(4_u128, false), Fixed::new(1_u128, false), Fixed::new(4_u128, false));
    let c = a / b;
    assert(c.x == Fixed::new_unscaled(3_u128, false), 'invalid div');
    assert(c.y == Fixed::new_unscaled(5_u128, false), 'invalid div');
    assert(c.z == Fixed::new_unscaled(1_u128, false), 'invalid div');
    assert(c.w == Fixed::new_unscaled(2_u128, false), 'invalid div');
}

#[test]
fn test_dot() {
    let a = Vec4::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, false), Fixed::new_unscaled(3_u128, false), Fixed::new_unscaled(4_u128, false));
    let b = Vec4::new(Fixed::new_unscaled(5_u128, false), Fixed::new_unscaled(6_u128, false), Fixed::new_unscaled(7_u128, false), Fixed::new_unscaled(8_u128, false));
    let c = a.dot(b);
    assert(c == Fixed::new_unscaled(70_u128, false), 'invalid dot');
}

#[test]
fn test_norm() {
    let a = Vec4::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, false), Fixed::new_unscaled(3_u128, false), Fixed::new_unscaled(4_u128, false));
    let b = a.norm();
    assert_precise(b, 101036978416954620000, 'invalid norm'); // sqrt(30)
}


#[test]
fn test_abs() {
    let a = Vec4::new(Fixed::new_unscaled(1_u128, false), Fixed::new_unscaled(2_u128, true), Fixed::new_unscaled(3_u128, true), Fixed::new_unscaled(4_u128, false));
    let b = a.abs();
    assert(b.x == Fixed::new_unscaled(1_u128, false), 'invalid abs');
    assert(b.y == Fixed::new_unscaled(2_u128, false), 'invalid abs');
    assert(b.z == Fixed::new_unscaled(3_u128, false), 'invalid abs');
    assert(b.w == Fixed::new_unscaled(4_u128, false), 'invalid abs');
}

#[test]
fn test_floor() {
    let a = Vec4::new(
        Fixed::new(27670116110564327000_u128, false), // 1.5
        Fixed::new(59029581035870570000_u128, true), // -3.2
        Fixed::new(0_u128, false),
        Fixed::new(0_u128, false)
    );

    let b = a.floor();
    assert(b.x == Fixed::new_unscaled(1_u128, false), 'invalid floor');
    assert(b.y == Fixed::new_unscaled(4_u128, true), 'invalid floor');
    assert(b.z == Fixed::new(0_u128, false), 'invalid floor');
    assert(b.w == Fixed::new(0_u128, false), 'invalid floor');
}
