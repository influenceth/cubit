use core::debug::PrintTrait;
use core::traits::Into;

use cubit::f128::types::fixed::{Fixed, FixedTrait, FixedSub, FixedPartialEq, FixedPrint};

const DEFAULT_PRECISION: u128 = 1844674407370; // 1e-7

// To use `DEFAULT_PRECISION`, final arg is: `Option::None(())`.
// To use `custom_precision` of 184467440737_u128: `Option::Some(184467440737_u128)`.
fn assert_precise(result: Fixed, expected: felt252, msg: felt252, custom_precision: Option<u128>) {
    let precision = match custom_precision {
        Option::Some(val) => val,
        Option::None(_) => DEFAULT_PRECISION,
    };

    let diff = (result - FixedTrait::from_felt(expected)).mag;

    if (diff > precision) {
        result.print();
        assert(diff <= precision, msg);
    }
}

fn assert_relative(result: Fixed, expected: felt252, msg: felt252, custom_precision: Option<u128>) {
    let precision = match custom_precision {
        Option::Some(val) => val,
        Option::None(_) => DEFAULT_PRECISION,
    };

    let diff = result - FixedTrait::from_felt(expected);
    let rel_diff = (diff / result).mag;

    if (rel_diff > precision) {
        result.print();
        assert(rel_diff <= precision, msg);
    }
}
