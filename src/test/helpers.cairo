use debug::PrintTrait;
use traits::Into;

use cubit::core::Fixed;
use cubit::core::FixedInto;
use cubit::core::FixedType;
use cubit::core::FixedSub;
use cubit::core::FixedPartialEq;

const PRECISION: u128 = 1844674407370_u128; // 1e-8

fn assert_precise(result: FixedType, expected: felt252, msg: felt252) {
    let diff = (result - Fixed::from_felt(expected)).mag;

    if (diff > PRECISION) {
        result.into().print();
        assert(diff <= PRECISION, msg);
    }
}
