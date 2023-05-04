use debug::PrintTrait;

use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::FixedPrint;


#[derive(Copy, Drop)]
struct Vec4Type {
    x: FixedType,
    y: FixedType,
    z: FixedType,
    w: FixedType
}

trait Vec4 {
    // Constructors
    fn new(x: FixedType, y: FixedType, z: FixedType, w: FixedType) -> Vec4Type;
    fn splat(v: FixedType) -> Vec4Type;
    // Math
    fn abs(self: Vec4Type) -> Vec4Type;
    fn dot(self: Vec4Type, rhs: Vec4Type) -> FixedType;
    fn floor(self: Vec4Type) -> Vec4Type;
    fn norm(self: Vec4Type) -> FixedType;
}

// Implementations

impl Vec4Impl of Vec4 {
    // Creates a new vector.
    #[inline(always)]
    fn new(x: FixedType, y: FixedType, z: FixedType, w: FixedType) -> Vec4Type {
        return Vec4Type { x: x, y: y, z: z, w: w };
    }

    // Creates a vector with all elements set to `v`.
    #[inline(always)]
    fn splat(v: FixedType) -> Vec4Type {
        return Vec4Type { x: v, y: v, z: v, w: v };
    }

    fn abs(self: Vec4Type) -> Vec4Type {
        return abs(self);
    }

    // Computes the dot product of `self` and `rhs`
    fn dot(self: Vec4Type, rhs: Vec4Type) -> FixedType {
        return dot(self, rhs);
    }

    fn floor(self: Vec4Type) -> Vec4Type {
        return floor(self);
    }

    fn norm(self: Vec4Type) -> FixedType {
        return norm(self);
    }
}

impl Vec4Print of PrintTrait<Vec4Type> {
    fn print(self: Vec4Type) {
        self.x.print();
        self.y.print();
        self.z.print();
        self.w.print();
    }
}

impl Vec4Add of Add<Vec4Type> {
    fn add(lhs: Vec4Type, rhs: Vec4Type) -> Vec4Type {
        return add(lhs, rhs);
    }
}

impl Vec4Div of Div<Vec4Type> {
    fn div(lhs: Vec4Type, rhs: Vec4Type) -> Vec4Type {
        return div(lhs, rhs);
    }
}

impl Vec4Mul of Mul<Vec4Type> {
    fn mul(lhs: Vec4Type, rhs: Vec4Type) -> Vec4Type {
        return mul(lhs, rhs);
    }
}

impl Vec4Rem of Rem<Vec4Type> {
    fn rem(lhs: Vec4Type, rhs: Vec4Type) -> Vec4Type {
        return rem(lhs, rhs);
    }
}

impl Vec4Sub of Sub<Vec4Type> {
    fn sub(lhs: Vec4Type, rhs: Vec4Type) -> Vec4Type {
        return sub(lhs, rhs);
    }
}

// Functions

fn abs(a: Vec4Type) -> Vec4Type {
    return Vec4Type { x: a.x.abs(), y: a.y.abs(), z: a.z.abs(), w: a.w.abs() };
}

fn add(a: Vec4Type, b: Vec4Type) -> Vec4Type {
    return Vec4Type { x: a.x + b.x, y: a.y + b.y, z: a.z + b.z, w: a.w + b.w };
}

fn div(a: Vec4Type, b: Vec4Type) -> Vec4Type {
    return Vec4Type { x: a.x / b.x, y: a.y / b.y, z: a.z / b.z, w: a.w / b.w };
}

fn dot(a: Vec4Type, b: Vec4Type) -> FixedType {
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z) + (a.w * b.w);
}

fn floor(a: Vec4Type) -> Vec4Type {
    return Vec4Type { x: a.x.floor(), y: a.y.floor(), z: a.z.floor(), w: a.w.floor() };
}

fn mul(a: Vec4Type, b: Vec4Type) -> Vec4Type {
    return Vec4Type { x: a.x * b.x, y: a.y * b.y, z: a.z * b.z, w: a.w * b.w };
}

fn norm(a: Vec4Type) -> FixedType {
    return a.dot(a).sqrt();
}

fn rem(a: Vec4Type, b: Vec4Type) -> Vec4Type {
    return Vec4Type { x: a.x % b.x, y: a.y % b.y, z: a.z % b.z, w: a.w % b.w };
}

fn sub(a: Vec4Type, b: Vec4Type) -> Vec4Type {
    return Vec4Type { x: a.x - b.x, y: a.y - b.y, z: a.z - b.z, w: a.w - b.w };
}
