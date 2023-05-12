use debug::PrintTrait;
use traits::Into;

use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedInto;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::FixedSub;
use cubit::types::fixed::FixedPartialEq;
use cubit::types::fixed::FixedPrint;

const DEFAULT_PRECISION: u128 = 1844674407370_u128; // 1e-7

// To use `DEFAULT_PRECISION`, final arg is: `Option::None(())`.
// To use `custom_precision` of 184467440737_u128: `Option::Some(184467440737_u128)`.
fn assert_precise(
    result: FixedType, expected: felt252, msg: felt252, custom_precision: Option<u128>
) {
    let precision = match custom_precision {
        Option::Some(val) => val,
        Option::None(_) => DEFAULT_PRECISION,
    };

    let diff = (result - Fixed::from_felt(expected)).mag;

    if (diff > precision) {
        result.print();
        assert(diff <= precision, msg);
    }
}

fn assert_relative(
    result: FixedType, expected: felt252, msg: felt252, custom_precision: Option<u128>
) {
    let precision = match custom_precision {
        Option::Some(val) => val,
        Option::None(_) => DEFAULT_PRECISION,
    };

    let diff = result - Fixed::from_felt(expected);
    let rel_diff = (diff / result).mag;

    if (rel_diff > precision) {
        result.print();
        assert(rel_diff <= precision, msg);
    }
}
