use core::debug::PrintTrait;

use cubit::f128::types::fixed::{Fixed, FixedTrait, FixedPrint};

#[derive(Copy, Drop, Serde)]
struct Vec2 {
    x: Fixed,
    y: Fixed
}

trait Vec2Trait {
    // Constructors
    fn new(x: Fixed, y: Fixed) -> Vec2;
    fn splat(v: Fixed) -> Vec2;
    // Math
    fn abs(self: Vec2) -> Vec2;
    fn cross(self: Vec2, rhs: Vec2) -> Fixed;
    fn dot(self: Vec2, rhs: Vec2) -> Fixed;
    fn floor(self: Vec2) -> Vec2;
    fn norm(self: Vec2) -> Fixed;
}

// Implementations

impl Vec2Impl of Vec2Trait {
    // Creates a new vector.
    fn new(x: Fixed, y: Fixed) -> Vec2 {
        return Vec2 { x: x, y: y };
    }

    // Creates a vector with all elements set to `v`.
    fn splat(v: Fixed) -> Vec2 {
        return Vec2 { x: v, y: v };
    }

    fn abs(self: Vec2) -> Vec2 {
        return abs(self);
    }

    fn cross(self: Vec2, rhs: Vec2) -> Fixed {
        return cross(self, rhs);
    }

    // Computes the dot product of `self` and `rhs` .
    // #[inline(always)] is not allowed for functions with impl generic parameters.
    fn dot(self: Vec2, rhs: Vec2) -> Fixed {
        return dot(self, rhs);
    }

    fn floor(self: Vec2) -> Vec2 {
        return floor(self);
    }

    fn norm(self: Vec2) -> Fixed {
        return norm(self);
    }
}

impl Vec2Print of PrintTrait<Vec2> {
    fn print(self: Vec2) {
        self.x.print();
        self.y.print();
    }
}

impl Vec2Add of Add<Vec2> {
    fn add(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return add(lhs, rhs);
    }
}

impl Vec2Div of Div<Vec2> {
    fn div(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return div(lhs, rhs);
    }
}

impl Vec2Mul of Mul<Vec2> {
    fn mul(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return mul(lhs, rhs);
    }
}

impl Vec2Rem of Rem<Vec2> {
    fn rem(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return rem(lhs, rhs);
    }
}

impl Vec2Sub of Sub<Vec2> {
    fn sub(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return sub(lhs, rhs);
    }
}

// Functions

fn abs(a: Vec2) -> Vec2 {
    return Vec2 { x: a.x.abs(), y: a.y.abs() };
}

fn add(a: Vec2, b: Vec2) -> Vec2 {
    return Vec2 { x: a.x + b.x, y: a.y + b.y };
}

fn cross(a: Vec2, b: Vec2) -> Fixed {
    return (a.x * b.y) - (a.y * b.x);
}

fn div(a: Vec2, b: Vec2) -> Vec2 {
    return Vec2 { x: a.x / b.x, y: a.y / b.y };
}

fn dot(a: Vec2, b: Vec2) -> Fixed {
    return (a.x * b.x) + (a.y * b.y);
}

fn floor(a: Vec2) -> Vec2 {
    return Vec2 { x: a.x.floor(), y: a.y.floor() };
}

fn mul(a: Vec2, b: Vec2) -> Vec2 {
    return Vec2 { x: a.x * b.x, y: a.y * b.y };
}

fn norm(a: Vec2) -> Fixed {
    return dot(a, a).sqrt();
}

fn rem(a: Vec2, b: Vec2) -> Vec2 {
    return Vec2 { x: a.x % b.x, y: a.y % b.y };
}

fn sub(a: Vec2, b: Vec2) -> Vec2 {
    return Vec2 { x: a.x - b.x, y: a.y - b.y };
}

// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use cubit::f128::test::helpers::assert_precise;

    use super::{Vec2Trait, FixedTrait};

    #[test]
    fn test_add() {
        let a = Vec2Trait::new(FixedTrait::new(1_u128, false), FixedTrait::new(2_u128, false));
        let b = Vec2Trait::new(FixedTrait::new(4_u128, false), FixedTrait::new(5_u128, false));
        let c = a + b;
        assert(c.x == FixedTrait::new(5_u128, false), 'invalid add');
        assert(c.y == FixedTrait::new(7_u128, false), 'invalid add');
    }

    #[test]
    fn test_mul() {
        let a = Vec2Trait::new(
            FixedTrait::new_unscaled(1_u128, false), FixedTrait::new_unscaled(2_u128, false),
        );
        let b = Vec2Trait::new(
            FixedTrait::new_unscaled(4_u128, false), FixedTrait::new_unscaled(5_u128, false),
        );
        let c = a * b;
        assert(c.x == FixedTrait::new_unscaled(4_u128, false), 'invalid mul');
        assert(c.y == FixedTrait::new_unscaled(10_u128, false), 'invalid mul');
    }

    #[test]
    fn test_div() {
        let a = Vec2Trait::new(FixedTrait::new(4_u128, false), FixedTrait::new(10_u128, false));
        let b = Vec2Trait::new(FixedTrait::new(1_u128, false), FixedTrait::new(5_u128, false));
        let c = a / b;
        assert(c.x == FixedTrait::new_unscaled(4_u128, false), 'invalid div');
        assert(c.y == FixedTrait::new_unscaled(2_u128, false), 'invalid div');
    }

    #[test]
    fn test_dot() {
        let a = Vec2Trait::new(
            FixedTrait::new_unscaled(4_u128, false), FixedTrait::new_unscaled(10_u128, false)
        );
        let b = Vec2Trait::new(
            FixedTrait::new_unscaled(1_u128, false), FixedTrait::new_unscaled(5_u128, false)
        );
        let c = a.dot(b);
        assert(c == FixedTrait::new_unscaled(54_u128, false), 'invalid dot');
    }

    #[test]
    fn test_sub() {
        let a = Vec2Trait::new(FixedTrait::new(4_u128, false), FixedTrait::new(10_u128, false));
        let b = Vec2Trait::new(FixedTrait::new(1_u128, false), FixedTrait::new(5_u128, false));
        let c = a - b;
        assert(c.x == FixedTrait::new(3_u128, false), 'invalid sub');
        assert(c.y == FixedTrait::new(5_u128, false), 'invalid sub');
    }

    #[test]
    fn test_cross() {
        let a = Vec2Trait::new(
            FixedTrait::new_unscaled(1_u128, false), FixedTrait::new_unscaled(2_u128, false)
        );
        let b = Vec2Trait::new(
            FixedTrait::new_unscaled(4_u128, false), FixedTrait::new_unscaled(5_u128, false)
        );
        let c = a.cross(b);
        assert(c == FixedTrait::new_unscaled(3_u128, true), 'invalid cross');
    }

    #[test]
    fn test_norm() {
        let a = Vec2Trait::new(
            FixedTrait::new_unscaled(1_u128, false), FixedTrait::new_unscaled(2_u128, false)
        );
        let b = a.norm();
        assert_precise(b, 41248173708084772864, 'invalid norm', Option::None(())); // sqrt(5)
    }

    #[test]
    fn test_abs() {
        let a = Vec2Trait::new(
            FixedTrait::new_unscaled(1_u128, false), FixedTrait::new_unscaled(2_u128, true)
        );
        let b = a.abs();
        assert(b.x == FixedTrait::new_unscaled(1_u128, false), 'invalid abs');
        assert(b.y == FixedTrait::new_unscaled(2_u128, false), 'invalid abs');
    }

    #[test]
    fn test_floor() {
        let a = Vec2Trait::new(
            FixedTrait::new(27670116110564327000_u128, false), // 1.5
            FixedTrait::new(59029581035870570000_u128, true) // -3.2
        );

        let b = a.floor();
        assert(b.x == FixedTrait::new_unscaled(1_u128, false), 'invalid floor');
        assert(b.y == FixedTrait::new_unscaled(4_u128, true), 'invalid floor');
    }
}
