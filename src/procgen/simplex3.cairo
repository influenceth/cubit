use cubit::math::comp::max;
use cubit::math::comp::min;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::vec3::Vec3;
use cubit::types::vec3::Vec3Type;
use cubit::types::vec4::Vec4;
use cubit::types::vec4::Vec4Type;

use debug::PrintTrait;
use cubit::types::fixed::FixedPrint;
use cubit::types::vec3::Vec3Print;
use cubit::types::vec4::Vec4Print;


fn permute(x: Vec4Type) -> Vec4Type {
    let v34 = Vec4::splat(Fixed::new_unscaled(34_u128, false));
    let v1 = Vec4::splat(Fixed::new_unscaled(1_u128, false));
    let v289 = Vec4::splat(Fixed::new_unscaled(289_u128, false));
    return (((x * v34) + v1) * x) % v289;
}

fn taylor_inv_sqrt(r: Vec4Type) -> Vec4Type {
    let v1 = Vec4::splat(Fixed::new(33072114398950993631_u128, false)); // 1.79284291400159
    let v2 = Vec4::splat(Fixed::new(15748625904262413056_u128, false)); // 0.85373472095314
    return v1 - v2 * r;
}

// For x, 0.0 is returned if x < edge, and 1.0 is returned otherwise
fn step(edge: FixedType, x: FixedType) -> FixedType {
    if x < edge {
        return Fixed::new(0, false);
    } else {
        return Fixed::new_unscaled(1, false);
    }
}

fn noise(v: Vec3Type) -> FixedType {
    let zero = Fixed::new(0_u128, false);
    let half = Fixed::new(9223372036854775808_u128, false); // 0.5
    let one = Fixed::new_unscaled(1_u128, false);

    let Cx = Fixed::new(3074457345618258602_u128, false); // 1 / 6
    let Cy = Fixed::new(6148914691236517205_u128, false); // 1 / 3
    let D = Vec4::new(
        zero,
        Fixed::new(9223372036854775808_u128, false), // 0.5
        Fixed::new(13835058055282163712_u128, false), // 0.75
        one
    );

    // First corner
    let mut i = (v + Vec3::splat(v.dot(Vec3::splat(Cy)))).floor();
    let x0 = v - i + Vec3::splat(i.dot(Vec3::splat(Cx)));

    // Other corners
    let g = Vec3::new(step(x0.y, x0.x), step(x0.z, x0.y), step(x0.x, x0.z));
    let l = Vec3::splat(one) - g;
    let i1 = Vec3::new(min(g.x, l.z), min(g.y, l.x), min(g.z, l.y));
    let i2 = Vec3::new(max(g.x, l.z), max(g.y, l.x), max(g.z, l.y));

    // x0 = x0 - 0.0 + 0.0 * C.xxx;
    // x1 = x0 - i1  + 1.0 * C.xxx;
    // x2 = x0 - i2  + 2.0 * C.xxx;
    // x3 = x0 - 1.0 + 3.0 * C.xxx;
    let x1 = x0 - i1 + Vec3::splat(Cx);
    let x2 = x0 - i2 + Vec3::splat(Cy);
    let x3 = x0 - Vec3::splat(D.y);

    // Permutations
    i = i % Vec3::splat(Fixed::new_unscaled(289_u128, false));
    let _p1 = permute(Vec4::splat(i.z) + Vec4::new(zero, i1.z, i2.z, one));
    let _p2 = permute(_p1 + Vec4::splat(i.y) + Vec4::new(zero, i1.y, i2.y, one));
    let p = permute(_p2 + Vec4::splat(i.x) + Vec4::new(zero, i1.x, i2.x, one));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    let ns = Vec3::new(
        Fixed::new(5270498306774157605_u128, false), // 2 / 7
        Fixed::new(17129119497016012214_u128, true), // -13 / 14
        Fixed::new(2635249153387078803_u128, false) // 1 / 7
    );

    let j = p % Vec4::splat(Fixed::new_unscaled(49_u128, false));
    let x_ = (j * Vec4::splat(ns.z)).floor();
    let y_ = (j - x_ * Vec4::splat(Fixed::new_unscaled(7_u128, false))).floor();

    let x = x_ * Vec4::splat(ns.x) + Vec4::splat(ns.y);
    let y = y_ * Vec4::splat(ns.x) + Vec4::splat(ns.y);
    let h = Vec4::splat(one) - x.abs() - y.abs();

    let b0 = Vec4::new(x.x, x.y, y.x, y.y);
    let b1 = Vec4::new(x.z, x.w, y.z, y.w);

    // vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
    // vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
    let s0 = b0.floor() * Vec4::splat(Fixed::new_unscaled(2_u128, false)) - Vec4::splat(one);
    let s1 = b1.floor() * Vec4::splat(Fixed::new_unscaled(2_u128, false)) - Vec4::splat(one);
    let sh = Vec4::new(-step(h.x, zero), -step(h.y, zero), -step(h.z, zero), -step(h.w, zero));

    let a0 = Vec4::new(b0.x, b0.z, b0.y, b0.w) + Vec4::new(s0.x, s0.z, s0.y, s0.w) * Vec4::new(sh.x, sh.x, sh.y, sh.y);
    let a1 = Vec4::new(b1.x, b1.z, b1.y, b1.w) + Vec4::new(s1.x, s1.z, s1.y, s1.w) * Vec4::new(sh.z, sh.z, sh.w, sh.w);

    let mut p0 = Vec3::new(a0.x, a0.y, h.x);
    let mut p1 = Vec3::new(a0.z, a0.w, h.y);
    let mut p2 = Vec3::new(a1.x, a1.y, h.z);
    let mut p3 = Vec3::new(a1.z, a1.w, h.w);

    // Normalise gradients
    let norm = taylor_inv_sqrt(Vec4::new(p0.dot(p0), p1.dot(p1), p2.dot(p2), p3.dot(p3)));
    let p0 = p0 * Vec3::splat(norm.x);
    let p1 = p1 * Vec3::splat(norm.y);
    let p2 = p2 * Vec3::splat(norm.z);
    let p3 = p3 * Vec3::splat(norm.w);

    // Mix final noise value
    let mut m = Vec4::new(
        max(half - x0.dot(x0), zero),
        max(half - x1.dot(x1), zero),
        max(half - x2.dot(x2), zero),
        max(half - x3.dot(x3), zero)
    );

    m = (m * m) * (m * m);

    return Fixed::new_unscaled(105_u128, false) * m.dot(Vec4::new(p0.dot(x0), p1.dot(x1), p2.dot(x2), p3.dot(x3)));
}
