use option::OptionTrait;
use traits::Into;

use cubit::core::ONE;
use cubit::core::ONE_u128;
use cubit::core::felt_sign;
use cubit::core::felt_abs;
use cubit::core::Fixed;
use cubit::core::FixedType;
use cubit::core::FixedImpl;


impl FixedPartialEq of PartialEq::<FixedType> {
    #[inline(always)]
    fn eq(a: FixedType, b: FixedType) -> bool {
        return a.mag == b.mag & a.sign == b.sign;
    }

    #[inline(always)]
    fn ne(a: FixedType, b: FixedType) -> bool {
        return a.mag != b.mag | a.sign != b.sign;
    }
}

impl FixedAdd of Add::<FixedType> {
    fn add(a: FixedType, b: FixedType) -> FixedType {
        return Fixed::from_felt(a.mag * a.sign + b.mag * b.sign);
    }
}

impl FixedAddEq of AddEq::<FixedType> {
    #[inline(always)]
    fn add_eq(ref self: FixedType, other: FixedType) {
        self = Add::add(self, other);
    }
}

impl FixedSub of Sub::<FixedType> {
    fn sub(a: FixedType, b: FixedType) -> FixedType {
        return Fixed::from_felt(a.mag * a.sign - b.mag * b.sign);
    }
}

impl FixedSubEq of SubEq::<FixedType> {
    #[inline(always)]
    fn sub_eq(ref self: FixedType, other: FixedType) {
        self = Sub::sub(self, other);
    }
}

impl FixedMul of Mul::<FixedType> {
    fn mul(a: FixedType, b: FixedType) -> FixedType {
        // Calculate result sign
        let res_sign = a.sign * b.sign;

        // Use u128 to multiply and shift back down to 64.61
        let a_u128 = integer::u128_try_from_felt(a.mag).unwrap();
        let b_u128 = integer::u128_try_from_felt(b.mag).unwrap();
        let (high, low) = integer::u128_wide_mul(a_u128, b_u128);
        let res_u128 = high * ONE_u128 + (low / ONE_u128);

        // Re-apply sign
        return Fixed::from_felt(res_sign * res_u128.into());
    }
}

impl FixedMulEq of MulEq::<FixedType> {
    #[inline(always)]
    fn mul_eq(ref self: FixedType, other: FixedType) {
        self = Mul::mul(self, other);
    }
}

impl FixedDiv of Div::<FixedType> {
    fn div(a: FixedType, b: FixedType) -> FixedType {
        // Calculate result sign
        let res_sign = a.sign * b.sign;

        // Use u128 to divide, then scale up remainder to 64.61 and divide again
        let a_u128 = integer::u128_try_from_felt(a.mag).unwrap();
        let b_u128 = integer::u128_try_from_felt(b.mag).unwrap();
        let div = a_u128 / b_u128;
        let rem = a_u128 % b_u128;
        let rem_div = rem * ONE_u128 / b_u128;
        let res_u128 = ONE_u128 * div + rem_div;

        // Re-apply sign
        return Fixed::from_felt(res_sign * res_u128.into());
    }
}
