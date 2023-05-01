use array::array_append;
use array::array_new;
use gas::withdraw_gas;

use cubit::math::comp::max;
use cubit::math::comp::min;
use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::ONE_u128;
use cubit::types::vec3::Vec3;
use cubit::types::vec3::Vec3Type;
use cubit::types::vec4::Vec4;
use cubit::types::vec4::Vec4Type;


fn permute(x: Vec4Type) -> Vec4Type {
    match withdraw_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt252>();
            array_append::<felt252>(ref data, 'OOG');
            panic(data);
        },
    }

    let v34 = Vec4::splat(Fixed::new(627189298506124754944_u128, false));
    let v1 = Vec4::splat(Fixed::new(ONE_u128, false));
    let v289 = Vec4::splat(Fixed::new(5331109037302060417024_u128, false));
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
        return Fixed::new(ONE_u128, false);
    }
}

fn noise(v: Vec3Type) -> FixedType {
    let zero = Fixed::new(0_u128, false);
    let half = Fixed::new(9223372036854775808_u128, false); // 0.5
    let one = Fixed::new(ONE_u128, false);

    let Cx = Fixed::new(3074457345618258602_u128, false); // 1 / 6
    let Cy = Fixed::new(6148914691236517205_u128, false); // 1 / 3

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
    let x1 = Vec3::new(x0.x - i1.x + Cx, x0.y - i1.y + Cx, x0.z - i1.z + Cx);
    let x2 = Vec3::new(x0.x - i2.x + Cy, x0.y - i2.y + Cy, x0.z - i2.z + Cy);
    let x3 = Vec3::new(x0.x - half, x0.y - half, x0.z - half);

    // Permutations
    i = i % Vec3::splat(Fixed::new(5331109037302060417024_u128, false)); // 289
    let _p1 = permute(Vec4::new(i.z + zero, i.z + i1.z, i.z + i2.z, i.z + one));
    let _p2 = permute(Vec4::new(_p1.x + i.y + zero, _p1.y + i.y + i1.y, _p1.z + i.y + i2.y, _p1.w + i.y + one));
    let p = permute(Vec4::new(_p2.x + i.x + zero, _p2.y + i.x + i1.x, _p2.z + i.x + i2.x, _p2.w + i.x + one));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    let ns_x = Fixed::new(5270498306774157605_u128, false); // 2 / 7
    let ns_y = Fixed::new(17129119497016012214_u128, true); // -13 / 14
    let ns_z = Fixed::new(2635249153387078803_u128, false); // 1 / 7

    let j = p % Vec4::splat(Fixed::new(903890459611768029184_u128, false)); // 49
    let x_ = (j * Vec4::splat(ns_z)).floor();
    let y_ = (j - x_ * Vec4::splat(Fixed::new(129127208515966861312_u128, false))).floor(); // 7

    let x = x_ * Vec4::splat(ns_x) + Vec4::splat(ns_y);
    let y = y_ * Vec4::splat(ns_x) + Vec4::splat(ns_y);
    let h = Vec4::splat(one) - x.abs() - y.abs();

    // Revoke AP tracking until handled by compiler
    internal::revoke_ap_tracking();

    let b0 = Vec4::new(x.x, x.y, y.x, y.y);
    let b1 = Vec4::new(x.z, x.w, y.z, y.w);

    // vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
    // vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
    let s0 = b0.floor() * Vec4::splat(Fixed::new_unscaled(2_u128, false)) + Vec4::splat(one);
    let s1 = b1.floor() * Vec4::splat(Fixed::new_unscaled(2_u128, false)) + Vec4::splat(one);
    let sh = Vec4::new(-step(h.x, zero), -step(h.y, zero), -step(h.z, zero), -step(h.w, zero));

    let a0 = Vec4::new(b0.x + s0.x * sh.x, b0.z + s0.z * sh.x, b0.y + s0.y * sh.y, b0.w + s0.w * sh.y);
    let a1 = Vec4::new(b1.x + s1.x * sh.z, b1.z + s1.z * sh.z, b1.y + s1.y * sh.w, b1.w + s1.w * sh.w);

    let mut p0 = Vec3::new(a0.x, a0.y, h.x);
    let mut p1 = Vec3::new(a0.z, a0.w, h.y);
    let mut p2 = Vec3::new(a1.x, a1.y, h.z);
    let mut p3 = Vec3::new(a1.z, a1.w, h.w);

    // Normalise gradients
    let norm = taylor_inv_sqrt(Vec4::new(p0.dot(p0), p1.dot(p1), p2.dot(p2), p3.dot(p3)));
    let p0 = Vec3::new(p0.x * norm.x, p0.y * norm.x, p0.z * norm.x);
    let p1 = Vec3::new(p1.x * norm.y, p1.y * norm.y, p1.z * norm.y);
    let p2 = Vec3::new(p2.x * norm.z, p2.y * norm.z, p2.z * norm.z);
    let p3 = Vec3::new(p3.x * norm.w, p3.y * norm.w, p3.z * norm.w);

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

fn noise_octaves(v: Vec3Type, octaves: u128, persistence: FixedType) -> FixedType {
    return _noise3_octaves_loop(
        v: v,
        p: persistence,
        o: octaves,
        s: Fixed::new(ONE_u128, false),
        t: Fixed::new(0_u128, false),
        n: Fixed::new(0_u128, false)
    );
}

fn _noise3_octaves_loop(v: Vec3Type, p: FixedType, o: u128, s: FixedType, t: FixedType, n: FixedType) -> FixedType {
    if o == 0_u128 {
      return n / t;
    }

    match withdraw_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt252>();
            array_append::<felt252>(ref data, 'OOG');
            panic(data);
        },
    }

    let resized_point = v / Vec3::splat(s);
    let current_noise = noise(resized_point);
    let scaled_noise = current_noise * s;
    let new_scale = s * p;

    return _noise3_octaves_loop(
        v: v,
        p: p,
        o: o - 1_u128,
        s: new_scale,
        t: t + s,
        n: n + scaled_noise
    );
}
