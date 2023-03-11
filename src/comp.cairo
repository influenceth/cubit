use option::OptionTrait;
use traits::Into;

use cubit::core::Fixed;
use cubit::core::FixedType;
use cubit::core::FixedImpl;
use cubit::core::FixedPartialOrd;


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
