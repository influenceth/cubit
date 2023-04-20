use array::array_append;
use array::array_new;
use debug::PrintTrait;
use gas::withdraw_gas;
use traits::Into;

use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedInto;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::FixedSub;
use cubit::types::fixed::FixedPartialEq;
use cubit::types::fixed::FixedPrint;

const PRECISION: u128 = 1844674407370_u128; // 1e-7

fn assert_precise(result: FixedType, expected: felt252, msg: felt252) {
    let diff = (result - Fixed::from_felt(expected)).mag;

    if (diff > PRECISION) {
        match withdraw_gas() {
            Option::Some(_) => {},
            Option::None(_) => {
                let mut data = array_new::<felt252>();
                array_append::<felt252>(ref data, 'OOG');
                panic(data);
            },
        }

        result.print();
        assert(diff <= PRECISION, msg);
    }
}
