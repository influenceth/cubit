use debug::PrintTrait;

use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::FixedPrint;


#[derive(Copy, Drop)]
struct Vec3Type {
    x: FixedType,
    y: FixedType,
    z: FixedType
}

trait Vec3 {
    // Constructors
    fn new(x: FixedType, y: FixedType, z: FixedType) -> Vec3Type;
    fn splat(v: FixedType) -> Vec3Type;

    // Math
    fn abs(self: Vec3Type) -> Vec3Type;
    fn cross(self: Vec3Type, rhs: Vec3Type) -> Vec3Type;
    fn dot(self: Vec3Type, rhs: Vec3Type) -> FixedType;
    fn floor(self: Vec3Type) -> Vec3Type;
    fn norm(self: Vec3Type) -> FixedType;
}

// Implementations

impl Vec3Impl of Vec3 {
    // Creates a new vector.
    #[inline(always)]
    fn new(x: FixedType, y: FixedType, z: FixedType) -> Vec3Type {
        return Vec3Type { x: x, y: y, z: z };
    }

    // Creates a vector with all elements set to `v`.
    #[inline(always)]
    fn splat(v: FixedType) -> Vec3Type {
        return Vec3Type { x: v, y: v, z: v };
    }

    fn abs(self: Vec3Type) -> Vec3Type {
        return abs(self);
    }

    fn cross(self: Vec3Type, rhs: Vec3Type) -> Vec3Type {
        return cross(self, rhs);
    }

    // Computes the dot product of `self` and `rhs` .
    // #[inline(always)] is not allowed for functions with impl generic parameters.
    fn dot(self: Vec3Type, rhs: Vec3Type) -> FixedType {
        return dot(self, rhs);
    }

    fn floor(self: Vec3Type) -> Vec3Type {
        return floor(self);
    }

    fn norm(self: Vec3Type) -> FixedType {
        return norm(self);
    }
}

impl Vec3Print of PrintTrait<Vec3Type> {
    fn print(self: Vec3Type) {
        self.x.print();
        self.y.print();
        self.z.print();
    }
}

impl Vec3Add of Add::<Vec3Type> {
    fn add(lhs: Vec3Type, rhs: Vec3Type) -> Vec3Type {
        return add(lhs, rhs);
    }
}

impl Vec3Div of Div::<Vec3Type> {
    fn div(lhs: Vec3Type, rhs: Vec3Type) -> Vec3Type {
        return div(lhs, rhs);
    }
}

impl Vec3Mul of Mul::<Vec3Type> {
    fn mul(lhs: Vec3Type, rhs: Vec3Type) -> Vec3Type {
        return mul(lhs, rhs);
    }
}

impl Vec3Sub of Sub::<Vec3Type> {
    fn sub(lhs: Vec3Type, rhs: Vec3Type) -> Vec3Type {
        return sub(lhs, rhs);
    }
}

// Functions

fn abs(a: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: a.x.abs(),
        y: a.y.abs(),
        z: a.z.abs()
    };
}

fn add(a: Vec3Type, b: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: a.x + b.x,
        y: a.y + b.y,
        z: a.z + b.z
    };
}

fn cross(a: Vec3Type, b: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: (a.y * b.z) - (a.z * b.y),
        y: (a.z * b.x) - (a.x * b.z),
        z: (a.x * b.y) - (a.y * b.x)
    };
}

fn div(a: Vec3Type, b: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: a.x / b.x,
        y: a.y / b.y,
        z: a.z / b.z
    };
}

fn dot(a: Vec3Type, b: Vec3Type) -> FixedType {
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

fn floor(a: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: a.x.floor(),
        y: a.y.floor(),
        z: a.z.floor()
    };
}

fn mul(a: Vec3Type, b: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: a.x * b.x,
        y: a.y * b.y,
        z: a.z * b.z
    };
}

fn norm(a: Vec3Type) -> FixedType {
    return dot(a, a).sqrt();
}

fn sub(a: Vec3Type, b: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: a.x - b.x,
        y: a.y - b.y,
        z: a.z - b.z
    };
}
