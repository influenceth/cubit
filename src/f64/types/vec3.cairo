use core::debug::PrintTrait;

use cubit::f64::types::fixed::{Fixed, FixedTrait, FixedPrint};

#[derive(Copy, Drop, Serde)]
struct Vec3 {
    x: Fixed,
    y: Fixed,
    z: Fixed
}

trait Vec3Trait {
    // Constructors
    fn new(x: Fixed, y: Fixed, z: Fixed) -> Vec3;
    fn splat(v: Fixed) -> Vec3;
    // Math
    fn abs(self: Vec3) -> Vec3;
    fn cross(self: Vec3, rhs: Vec3) -> Vec3;
    fn dot(self: Vec3, rhs: Vec3) -> Fixed;
    fn floor(self: Vec3) -> Vec3;
    fn norm(self: Vec3) -> Fixed;
    // Scalar Math
    fn add(self: Vec3, scalar: Fixed) -> Vec3;
    fn sub(self: Vec3, scalar: Fixed) -> Vec3;
    fn mul(self: Vec3, scalar: Fixed) -> Vec3;
    fn div(self: Vec3, scalar: Fixed) -> Vec3;
    fn rem(self: Vec3, scalar: Fixed) -> Vec3;
}

// Implementations

impl Vec3Impl of Vec3Trait {
    // Creates a new vector.
    fn new(x: Fixed, y: Fixed, z: Fixed) -> Vec3 {
        return Vec3 { x: x, y: y, z: z };
    }

    // Creates a vector with all elements set to `v`.
    fn splat(v: Fixed) -> Vec3 {
        return Vec3 { x: v, y: v, z: v };
    }

    fn abs(self: Vec3) -> Vec3 {
        return abs(self);
    }

    fn cross(self: Vec3, rhs: Vec3) -> Vec3 {
        return cross(self, rhs);
    }

    // Computes the dot product of `self` and `rhs` .
    // #[inline(always)] is not allowed for functions with impl generic parameters.
    fn dot(self: Vec3, rhs: Vec3) -> Fixed {
        return dot(self, rhs);
    }

    fn floor(self: Vec3) -> Vec3 {
        return floor(self);
    }

    fn norm(self: Vec3) -> Fixed {
        return norm(self);
    }

    fn add(self: Vec3, scalar: Fixed) -> Vec3 {
        return Vec3 { x: self.x + scalar, y: self.y + scalar, z: self.z + scalar };
    }

    fn sub(self: Vec3, scalar: Fixed) -> Vec3 {
        return Vec3 { x: self.x - scalar, y: self.y - scalar, z: self.z - scalar };
    }

    fn mul(self: Vec3, scalar: Fixed) -> Vec3 {
        return Vec3 { x: self.x * scalar, y: self.y * scalar, z: self.z * scalar };
    }

    fn div(self: Vec3, scalar: Fixed) -> Vec3 {
        return Vec3 { x: self.x / scalar, y: self.y / scalar, z: self.z / scalar };
    }

    fn rem(self: Vec3, scalar: Fixed) -> Vec3 {
        return Vec3 { x: self.x % scalar, y: self.y % scalar, z: self.z % scalar };
    }
}

impl Vec3Print of PrintTrait<Vec3> {
    fn print(self: Vec3) {
        self.x.print();
        self.y.print();
        self.z.print();
    }
}

impl Vec3Add of Add<Vec3> {
    fn add(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return add(lhs, rhs);
    }
}

impl Vec3Div of Div<Vec3> {
    fn div(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return div(lhs, rhs);
    }
}

impl Vec3Mul of Mul<Vec3> {
    fn mul(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return mul(lhs, rhs);
    }
}

impl Vec3Rem of Rem<Vec3> {
    fn rem(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return rem(lhs, rhs);
    }
}

impl Vec3Sub of Sub<Vec3> {
    fn sub(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return sub(lhs, rhs);
    }
}

// Functions

fn abs(a: Vec3) -> Vec3 {
    return Vec3 { x: a.x.abs(), y: a.y.abs(), z: a.z.abs() };
}

fn add(a: Vec3, b: Vec3) -> Vec3 {
    return Vec3 { x: a.x + b.x, y: a.y + b.y, z: a.z + b.z };
}

fn cross(a: Vec3, b: Vec3) -> Vec3 {
    return Vec3 {
        x: (a.y * b.z) - (a.z * b.y), y: (a.z * b.x) - (a.x * b.z), z: (a.x * b.y) - (a.y * b.x)
    };
}

fn div(a: Vec3, b: Vec3) -> Vec3 {
    return Vec3 { x: a.x / b.x, y: a.y / b.y, z: a.z / b.z };
}

fn dot(a: Vec3, b: Vec3) -> Fixed {
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

fn floor(a: Vec3) -> Vec3 {
    return Vec3 { x: a.x.floor(), y: a.y.floor(), z: a.z.floor() };
}

fn mul(a: Vec3, b: Vec3) -> Vec3 {
    return Vec3 { x: a.x * b.x, y: a.y * b.y, z: a.z * b.z };
}

fn norm(a: Vec3) -> Fixed {
    return dot(a, a).sqrt();
}

fn rem(a: Vec3, b: Vec3) -> Vec3 {
    return Vec3 { x: a.x % b.x, y: a.y % b.y, z: a.z % b.z };
}

fn sub(a: Vec3, b: Vec3) -> Vec3 {
    return Vec3 { x: a.x - b.x, y: a.y - b.y, z: a.z - b.z };
}

// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use cubit::f64::test::helpers::assert_precise;

    use super::{Vec3Trait, FixedTrait};

    #[test]
    fn test_add() {
        let a = Vec3Trait::new(
            FixedTrait::new(1, false), FixedTrait::new(2, false), FixedTrait::new(3, false)
        );
        let b = Vec3Trait::new(
            FixedTrait::new(4, false), FixedTrait::new(5, false), FixedTrait::new(6, false)
        );
        let c = a + b;
        assert(c.x == FixedTrait::new(5, false), 'invalid add');
        assert(c.y == FixedTrait::new(7, false), 'invalid add');
        assert(c.z == FixedTrait::new(9, false), 'invalid add');
    }

    #[test]
    fn test_mul() {
        let a = Vec3Trait::new(
            FixedTrait::new_unscaled(1, false),
            FixedTrait::new_unscaled(2, false),
            FixedTrait::new_unscaled(3, false)
        );
        let b = Vec3Trait::new(
            FixedTrait::new_unscaled(4, false),
            FixedTrait::new_unscaled(5, false),
            FixedTrait::new_unscaled(6, false)
        );
        let c = a * b;
        assert(c.x == FixedTrait::new_unscaled(4, false), 'invalid mul');
        assert(c.y == FixedTrait::new_unscaled(10, false), 'invalid mul');
        assert(c.z == FixedTrait::new_unscaled(18, false), 'invalid mul');
    }

    #[test]
    fn test_div() {
        let a = Vec3Trait::new(
            FixedTrait::new(4, false), FixedTrait::new(10, false), FixedTrait::new(6, false)
        );
        let b = Vec3Trait::new(
            FixedTrait::new(1, false), FixedTrait::new(5, false), FixedTrait::new(3, false)
        );
        let c = a / b;
        assert(c.x == FixedTrait::new_unscaled(4, false), 'invalid div');
        assert(c.y == FixedTrait::new_unscaled(2, false), 'invalid div');
        assert(c.z == FixedTrait::new_unscaled(2, false), 'invalid div');
    }

    #[test]
    fn test_dot() {
        let a = Vec3Trait::new(
            FixedTrait::new_unscaled(4, false),
            FixedTrait::new_unscaled(10, false),
            FixedTrait::new_unscaled(6, false)
        );
        let b = Vec3Trait::new(
            FixedTrait::new_unscaled(1, false),
            FixedTrait::new_unscaled(5, false),
            FixedTrait::new_unscaled(3, false)
        );
        let c = a.dot(b);
        assert(c == FixedTrait::new_unscaled(72, false), 'invalid dot');
    }

    #[test]
    fn test_sub() {
        let a = Vec3Trait::new(
            FixedTrait::new(4, false), FixedTrait::new(10, false), FixedTrait::new(6, false)
        );
        let b = Vec3Trait::new(
            FixedTrait::new(1, false), FixedTrait::new(5, false), FixedTrait::new(3, false)
        );
        let c = a - b;
        assert(c.x == FixedTrait::new(3, false), 'invalid sub');
        assert(c.y == FixedTrait::new(5, false), 'invalid sub');
        assert(c.z == FixedTrait::new(3, false), 'invalid sub');
    }

    #[test]
    fn test_cross() {
        let a = Vec3Trait::new(
            FixedTrait::new_unscaled(1, false),
            FixedTrait::new_unscaled(2, false),
            FixedTrait::new_unscaled(3, false)
        );
        let b = Vec3Trait::new(
            FixedTrait::new_unscaled(4, false),
            FixedTrait::new_unscaled(5, false),
            FixedTrait::new_unscaled(6, false)
        );
        let c = a.cross(b);
        assert(c.x == FixedTrait::new_unscaled(3, true), 'invalid cross1');
        assert(c.y == FixedTrait::new_unscaled(6, false), 'invalid cross2');
        assert(c.z == FixedTrait::new_unscaled(3, true), 'invalid cross3');
    }

    #[test]
    fn test_norm() {
        let a = Vec3Trait::new(
            FixedTrait::new_unscaled(1, false),
            FixedTrait::new_unscaled(2, false),
            FixedTrait::new_unscaled(3, false)
        );
        let b = a.norm();
        assert_precise(b, 16070296109, 'invalid norm', Option::None(())); // sqrt(14)
    }

    #[test]
    fn test_abs() {
        let a = Vec3Trait::new(
            FixedTrait::new_unscaled(1, false),
            FixedTrait::new_unscaled(2, true),
            FixedTrait::new_unscaled(3, true)
        );
        let b = a.abs();
        assert(b.x == FixedTrait::new_unscaled(1, false), 'invalid abs');
        assert(b.y == FixedTrait::new_unscaled(2, false), 'invalid abs');
        assert(b.z == FixedTrait::new_unscaled(3, false), 'invalid abs');
    }

    #[test]
    fn test_floor() {
        let a = Vec3Trait::new(
            FixedTrait::new(6442450944, false), // 1.5
            FixedTrait::new(13743895347, true), // -3.2
            FixedTrait::new(0, false)
        );

        let b = a.floor();
        assert(b.x == FixedTrait::new_unscaled(1, false), 'invalid floor');
        assert(b.y == FixedTrait::new_unscaled(4, true), 'invalid floor');
        assert(b.z == FixedTrait::new(0, false), 'invalid floor');
    }
}
