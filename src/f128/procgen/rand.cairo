use core::array::ArrayTrait;
use core::integer::{u128_safe_divmod, u128_as_non_zero, u256_from_felt252};
use core::traits::Into;

use cubit::f128::types::fixed::{Fixed, FixedTrait, ONE_u128};

fn derive(seed: felt252, entropy: felt252) -> felt252 {
    return core::hash::LegacyHash::hash(seed, entropy);
}

// Returns a psuedo-random value between two values based on a seed. The returned
// value is inclusive of the low param and exclusive of the high param (low <= res < high)
fn fixed_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    assert(high > low, 'high !> low');
    let seed_low = u256_from_felt252(seed).low;
    return FixedTrait::new(seed_low % ONE_u128, false) * (high - low) + low;
}

fn u128_between(seed: felt252, low: u128, high: u128) -> u128 {
    let fixed = fixed_between(
        seed, FixedTrait::new_unscaled(low, false), FixedTrait::new_unscaled(high, false),
    );
    return fixed.mag / ONE_u128;
}

fn fixed_normal_between(seed: felt252, low: Fixed, high: Fixed) -> Fixed {
    let acc = _fixed_normal_between_loop(seed, low, high, FixedTrait::ZERO(), 5);
    return acc / FixedTrait::new_unscaled(5, false);
}

fn u128_normal_between(seed: felt252, low: u128, high: u128) -> u128 {
    let fixed_low = FixedTrait::new_unscaled(low, false);
    let fixed_high = FixedTrait::new_unscaled(high - 1, false);
    let fixed = fixed_normal_between(seed, fixed_low, fixed_high);
    return fixed.round().mag / ONE_u128;
}

fn _fixed_normal_between_loop(
    seed: felt252, low: Fixed, high: Fixed, acc: Fixed, iter: felt252,
) -> Fixed {
    if (iter == 0) {
        return acc;
    }
    let iter_seed = derive(seed, iter);
    let sample = fixed_between(iter_seed, low, high);
    return _fixed_normal_between_loop(seed, low, high, acc + sample, iter - 1);
}

// Tests
// --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use cubit::f128::procgen::rand;
    use cubit::f128::test::helpers::assert_precise;
    use cubit::f128::types::fixed::FixedPrint;

    use super::{FixedTrait};

    #[test]
    #[available_gas(200000000)]
    fn test_u128_between() {
        let mut seed = rand::derive(43235208298734, 7010232376584);
        let mut iter = 1000;
        let mut min = 10;
        let mut max = 1;

        loop {
            if iter == 0 {
                break;
            }
            seed = rand::derive(seed, iter);
            let r = rand::u128_between(seed, 1, 11);
            assert(r >= 1 && r <= 10, 'invalid range');

            if r < min {
                min = r;
            }
            if r > max {
                max = r;
            }

            iter -= 1;
        };

        assert(min == 1, 'min should be 1');
        assert(max == 10, 'max should be 10');
    }

    #[test]
    #[available_gas(200000000)]
    fn test_fixed_between() {
        let mut seed = rand::derive(432352089298734, 701022376584);
        let mut iter = 1000;
        let mut min = FixedTrait::new_unscaled(10, false);
        let mut max = FixedTrait::ZERO();

        loop {
            if iter == 0 {
                break;
            }
            seed = rand::derive(seed, iter);
            let r = rand::fixed_between(
                seed, FixedTrait::ZERO(), FixedTrait::new_unscaled(10, false),
            );
            assert(
                r >= FixedTrait::ZERO() && r < FixedTrait::new_unscaled(10, false), 'invalid range',
            );

            if r < min {
                min = r;
            }
            if r > max {
                max = r;
            }

            iter -= 1;
        };

        assert(min < FixedTrait::ONE(), 'min should be less than 1');
        assert(max > FixedTrait::new_unscaled(9, false), 'max should be more than 9');
    }

    #[test]
    #[available_gas(1000000000)]
    fn test_u128_normal_between() {
        let mut seed = rand::derive(43235208298734, 7010232376584);
        let mut iter = 1000;
        let mut min = 10;
        let mut max = 1;

        loop {
            if iter == 0 {
                break;
            }
            seed = rand::derive(seed, iter);
            let r = rand::u128_normal_between(seed, 0, 11);
            assert(r >= 0 && r <= 10, 'invalid range');

            if r < min {
                min = r;
            }
            if r > max {
                max = r;
            }

            iter -= 1;
        };

        assert(min <= 2, 'min should be at most 2');
        assert(max >= 8, 'max should be at least 8');
    }

    #[test]
    #[available_gas(1000000000)]
    fn test_fixed_normal_between() {
        let mut seed = rand::derive(432352089298734, 701022376584);
        let mut iter = 1000;
        let mut min = FixedTrait::new_unscaled(10, false);
        let mut max = FixedTrait::ZERO();

        loop {
            if iter == 0 {
                break;
            }
            seed = rand::derive(seed, iter);
            let r = rand::fixed_normal_between(
                seed, FixedTrait::ZERO(), FixedTrait::new_unscaled(10, false),
            );
            assert(
                r >= FixedTrait::ZERO() && r < FixedTrait::new_unscaled(10, false), 'invalid range',
            );

            if r < min {
                min = r;
            }
            if r > max {
                max = r;
            }

            iter -= 1;
        };

        assert(min < FixedTrait::new_unscaled(2, false), 'min should be less than 2');
        assert(max > FixedTrait::new_unscaled(8, false), 'max should be greater than 8');
    }
}
