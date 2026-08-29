use cubit::f64::math::trig::{ acos_fast, asin_fast, atan_fast, PI, HALF_PI };
use cubit::f64::math::lut;
use cubit::f64::types::fixed::{Fixed, FixedTrait, FixedAdd, FixedSub, FixedMul, FixedDiv, ONE};
use cubit::f64::types::fixed::{FixedPartialEq, FixedPrint};

fn main() {

    let p32: u64 = 0x100000000;
    let p26: u64 = 0x4000000;
    
    let mut i = p32;
    while (i > 0) {
        acos_fast(FixedTrait::new(i, true)).mag.print();
        i -= p26;
    };
    while (i <= p32) {
        acos_fast(FixedTrait::new(i, false)).mag.print();
        i += p26;
    };

}