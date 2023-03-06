use option::OptionTrait;
use result::ResultTrait;
use result::ResultTraitImpl;
use traits::Into;


const PRIME: felt = 3618502788666131213697322783095070105623107215331596699973092056135872020480;
const HALF_PRIME: felt = 1809251394333065606848661391547535052811553607665798349986546028067936010240;
const ONE: felt = 2305843009213693952; // 2 ** 61
const ONE_u128: u128 = 2305843009213693952_u128; // 2 ** 61
const HALF: felt = 1152921504606846976; // 2 ** 60
const HALF_u128: u128 = 1152921504606846976_u128; // 2 ** 60

// Returns the sign of a signed `felt`, -1, 0, or 1
fn felt_sign(a: felt) -> felt {
    if (a == 0) {
        return 0;
    } else if (a <= HALF_PRIME) {
        return 1;
    } else {
        return -1;
    }
}

// Returns the absolute value of a signed `felt`
fn felt_abs(a: felt) -> felt {
    let a_sign = felt_sign(a);

    if (a_sign == -1) {
        return a * -1;
    } else {
        return a;
    }
}

#[derive(Copy, Drop)]
struct FixedType { mag: felt, sign: felt }

trait Fixed {
    fn from_felt(val: felt) -> FixedType;
    fn from_int(val: felt) -> FixedType;
    fn checked(self: FixedType) -> Result::<FixedType, FixedType>;
    fn ceil(self: FixedType) -> FixedType;
    fn floor(self: FixedType) -> FixedType;
    fn round(self: FixedType) -> FixedType;
}

impl FixedImpl of Fixed {
    fn from_felt(val: felt) -> FixedType {
        let fixed = FixedType { mag: felt_abs(val), sign: felt_sign(val) };
        return fixed.checked().expect('Overflow of 64.64 value');
    }

    fn from_int(val: felt) -> FixedType {
        return FixedImpl::from_felt(val * ONE);
    }

    fn checked(self: FixedType) -> Result::<FixedType, FixedType> {
        if (self.mag >= 0x100000000000000000000000000000000) {
        if (self.mag <= -0x100000000000000000000000000000000) {
            return Result::Err(self);
        } else {
            return Result::Ok(self);
        }
        } else {
        return Result::Ok(self);
        }
    }

    fn ceil(self: FixedType) -> FixedType {
        let self_u128 = integer::u128_try_from_felt(self.mag).unwrap();
        let div_u128 = self_u128 / ONE_u128;
        let rem_u128 = self_u128 % ONE_u128;

        if (self.sign == 0 | rem_u128 == 0_u128) {
            return self;
        } else if (self.sign == 1) {
            return Fixed::from_int(div_u128.into() + 1);
        } else {
            return Fixed::from_int(self.sign * div_u128.into());
        }
    }

    fn floor(self: FixedType) -> FixedType {
        let self_u128 = integer::u128_try_from_felt(self.mag).unwrap();
        let div_u128 = self_u128 / ONE_u128;
        let rem_u128 = self_u128 % ONE_u128;

        if (self.sign == 0 | rem_u128 == 0_u128) {
            return self;
        } else if (self.sign == 1) {
            return Fixed::from_int(div_u128.into());
        } else {
            return Fixed::from_int(self.sign * div_u128.into() - 1);
        }
    }

    fn round(self: FixedType) -> FixedType {
        let self_u128 = integer::u128_try_from_felt(self.mag).unwrap();
        let div_u128 = self_u128 / ONE_u128;
        let rem_u128 = self_u128 % ONE_u128;

        if (HALF_u128 <= rem_u128) {
            return Fixed::from_int(self.sign * (div_u128.into() + 1));
        } else {
            return Fixed::from_int(self.sign * div_u128.into());
        }
    }
}

impl FixedInto of Into::<FixedType, felt> {
    fn into(self: FixedType) -> felt {
        return self.mag * self.sign;
    }
}

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
        let (a_high, a_low) = integer::u128_wide_mul(a_u128, ONE_u128);
        let b_u128 = integer::u128_try_from_felt(b.mag).unwrap();
        let b_inv = 340282366920938463463374607431768211455_u128 / b_u128;
        let res_u128 = a_low / b_u128 + a_high * b_inv;

        // Re-apply sign
        return Fixed::from_felt(res_sign * res_u128.into());
    }
}

impl FixedPartialOrd of PartialOrd::<FixedType> {
    #[inline(always)]
    fn le(a: FixedType, b: FixedType) -> bool {
        return (a.sign * a.mag <= b.sign * b.mag);
    }

    #[inline(always)]
    fn ge(a: FixedType, b: FixedType) -> bool {
        return (a.sign * a.mag >= b.sign * b.mag);
    }

    #[inline(always)]
    fn lt(a: FixedType, b: FixedType) -> bool {
        return (a.sign * a.mag < b.sign * b.mag);
    }

    #[inline(always)]
    fn gt(a: FixedType, b: FixedType) -> bool {
        return (a.sign * a.mag > b.sign * b.mag);
    }
}
