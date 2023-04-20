use option::OptionTrait;
use traits::Into;

use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::FixedImpl;
use cubit::types::fixed::FixedPartialOrd;


// PUBLIC

fn max (a: FixedType, b: FixedType) -> FixedType {
    if (a >= b) {
        return a;
    } else {
        return b;
    }
}

fn min (a: FixedType, b: FixedType) -> FixedType {
    if (a <= b) {
        return a;
    } else {
        return b;
    }
}
