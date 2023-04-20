use debug::PrintTrait;

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
    fn splat(self: FixedType) -> Vec3Type;

    // Math
    fn cross(self: Vec3Type, rhs: Vec3Type) -> Vec3Type;
    fn dot(self: Vec3Type, rhs: Vec3Type) -> FixedType;
}

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

    fn cross(self: Vec3Type, rhs: Vec3Type) -> Vec3Type {
        return Vec3Type {
            x: (self.y * rhs.z) - (self.z * rhs.y),
            y: (self.z * rhs.x) - (self.x * rhs.z),
            z: (self.x * rhs.y) - (self.y * rhs.x)
        };
    }

    // Computes the dot product of `self` and `rhs` .
    // #[inline(always)] is not allowed for functions with impl generic parameters.
    fn dot(self: Vec3Type, rhs: Vec3Type) -> FixedType {
        return (self.x * rhs.x) + (self.y * rhs.y) + (self.z * rhs.z);
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
    fn add(a: Vec3Type, b: Vec3Type) -> Vec3Type {
        return Vec3Type {
            x: a.x + b.x,
            y: a.y + b.y,
            z: a.z + b.z
        };
    }
}

impl Vec3Div of Div::<Vec3Type> {
    fn div(a: Vec3Type, b: Vec3Type) -> Vec3Type {
        return Vec3Type {
            x: a.x / b.x,
            y: a.y / b.y,
            z: a.z / b.z
        };
    }
}

impl Vec3Mul of Mul::<Vec3Type> {
    fn mul(a: Vec3Type, b: Vec3Type) -> Vec3Type {
        return Vec3Type {
            x: a.x * b.x,
            y: a.y * b.y,
            z: a.z * b.z
        };
    }
}

impl Vec3Sub of Sub::<Vec3Type> {
    fn sub(a: Vec3Type, b: Vec3Type) -> Vec3Type {
        return Vec3Type {
            x: a.x - b.x,
            y: a.y - b.y,
            z: a.z - b.z
        };
    }
}

fn cross(self: Vec3Type, rhs: Vec3Type) -> Vec3Type {
    return Vec3Type {
        x: (self.y * rhs.z) - (self.z * rhs.y),
        y: (self.z * rhs.x) - (self.x * rhs.z),
        z: (self.x * rhs.y) - (self.y * rhs.x)
    };
}