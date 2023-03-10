use gas::try_fetch_gas;
use option::OptionTrait;
use result::ResultTrait;
use result::ResultTraitImpl;
use traits::Into;


// CONSTANTS

const PRIME: felt = 3618502788666131213697322783095070105623107215331596699973092056135872020480;
const HALF_PRIME: felt = 1809251394333065606848661391547535052811553607665798349986546028067936010240;
const ONE: felt = 18446744073709551616; // 2 ** 64
const ONE_u128: u128 = 18446744073709551616_u128; // 2 ** 64
const HALF: felt = 9223372036854775808; // 2 ** 63
const HALF_u128: u128 = 9223372036854775808_u128; // 2 ** 63
const WIDE_SHIFT_u128: u128 = 18446744073709551616_u128; // 2 ** 64
const MAX_u128: u128 = 340282366920938463463374607431768211455_u128; // 2 ** 128 - 1
const NEGATIVE: u128 = 0_u128;
const POSITIVE: u128 = 1_u128;

// STRUCTS

#[derive(Copy, Drop)]
struct FixedType { mag: u128, sign: u128 }

// TRAITS

trait Fixed {
    // Uitls
    fn from_felt(val: felt) -> FixedType;
    fn from_int(val: felt) -> FixedType; // un-scaled felt

    // Math
    fn abs(self: FixedType) -> FixedType;
    fn ceil(self: FixedType) -> FixedType;
    fn exp(self: FixedType) -> FixedType;
    fn exp2(self: FixedType) -> FixedType;
    fn floor(self: FixedType) -> FixedType;
    fn ln(self: FixedType) -> FixedType;
    fn log2(self: FixedType) -> FixedType;
    fn log10(self: FixedType) -> FixedType;
    fn pow(self: FixedType, b: FixedType) -> FixedType;
    fn round(self: FixedType) -> FixedType;
    fn sqrt(self: FixedType) -> FixedType;
}

// IMPLS

impl FixedImpl of Fixed {
    fn from_felt(val: felt) -> FixedType {
        let mag = integer::u128_try_from_felt(_felt_abs(val)).unwrap();
        return FixedType { mag: mag, sign: _felt_sign(val) };
    }

    fn from_int(val: felt) -> FixedType {
        return Fixed::from_felt(val * ONE);
    }

    fn abs(self: FixedType) -> FixedType {
        return Fixed::from_felt(self.mag.into());
    }

    fn ceil(self: FixedType) -> FixedType {
        let (div_u128, rem_u128) = _split_unsigned(self);

        if (rem_u128 == 0_u128) {
            return self;
        } else if (self.sign == POSITIVE) {
            return Fixed::from_int(div_u128.into() + 1);
        } else {
            return Fixed::from_int(div_u128.into() * -1);
        }
    }

    fn floor(self: FixedType) -> FixedType {
        let (div_u128, rem_u128) = _split_unsigned(self);

        if (rem_u128 == 0_u128) {
            return self;
        } else if (self.sign == POSITIVE) {
            return Fixed::from_int(div_u128.into());
        } else {
            return Fixed::from_int(-1 * div_u128.into() - 1);
        }
    }

    // Calculates the natural exponent of x: e^x
    fn exp(self: FixedType) -> FixedType {
        return Fixed::exp2(Fixed::from_felt(26613026195688644984) * self);
    }

    // Calculates the binary exponent of x: 2^x
    fn exp2(self: FixedType) -> FixedType {
        return _exp2(self);
    }

    // Calculates the natural logarithm of x: ln(x)
    // self must be greater than zero
    fn ln(self: FixedType) -> FixedType {
        return Fixed::from_felt(12786308645202655660) * Fixed::log2(self); // ln(2) = 0.693...
    }

    // Calculates the binary logarithm of x: log2(x)
    // self must be greather than zero
    fn log2(self: FixedType) -> FixedType {
        return _log2(self);
    }

    // Calculates the base 10 log of x: log10(x)
    // self must be greater than zero
    fn log10(self: FixedType) -> FixedType {
        return Fixed::from_felt(5553023288523357132) * Fixed::log2(self); // log10(2) = 0.301...
    }

    // Calclates the value of x^y and checks for overflow before returning
    // self is a fixed point value
    // b is a fixed point value
    fn pow(self: FixedType, b: FixedType) -> FixedType {
        let (div_u128, rem_u128) = _split_unsigned(b);

        // use the more performant integer pow when y is an int
        if (rem_u128 == 0_u128) {
            return _pow_int(self, b.mag / ONE_u128, b.sign);
        }

        // x^y = exp(y*ln(x)) for x > 0 will error for x < 0
        return Fixed::exp(b * Fixed::ln(self));
    }

    fn round(self: FixedType) -> FixedType {
        let (div_u128, rem_u128) = _split_unsigned(self);

        if (HALF_u128 <= rem_u128) {
            return FixedType { mag: ONE_u128 * (div_u128 + 1_u128), sign: self.sign };
        } else {
            return FixedType { mag: ONE_u128 * div_u128, sign: self.sign };
        }
    }

    // Calculates the square root of a fixed point value
    // x must be positive
    fn sqrt(self: FixedType) -> FixedType {
        assert(self.sign == POSITIVE, 'Must be positive');
        let root = integer::u128_sqrt(self.mag);
        let scale_root = integer::u128_sqrt(ONE_u128);
        let res_u128 = root * ONE_u128 / scale_root;
        return Fixed::from_felt(res_u128.into());
    }
}

impl FixedInto of Into::<FixedType, felt> {
    fn into(self: FixedType) -> felt {
        let mag_felt = self.mag.into();

        if (self.sign == NEGATIVE) {
            return mag_felt * -1;
        } else {
            return mag_felt;
        }
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
        return Fixed::from_felt(a.into() + b.into());
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
        return Fixed::from_felt(a.into() - b.into());
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
        let mut res_sign = POSITIVE;

        if (a.sign != b.sign) {
            res_sign = NEGATIVE;
        }

        // Use u128 to multiply and shift back down
        // TODO: replace if / when there is a felt div_rem supported
        let (high, low) = integer::u128_wide_mul(a.mag, b.mag);
        let res_u128 = high * WIDE_SHIFT_u128 + (low / ONE_u128);

        // Re-apply sign
        return FixedType { mag: res_u128, sign: res_sign };
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
        let mut res_sign = POSITIVE;

        if (a.sign != b.sign) {
            res_sign = NEGATIVE;
        }

        // Invert b to preserve precision as much as possible
        // TODO: replace if / when there is a felt div_rem supported
        let (a_high, a_low) = integer::u128_wide_mul(a.mag, ONE_u128);
        let b_inv = MAX_u128 / b.mag;
        let res_u128 = a_low / b.mag + a_high * b_inv;

        // Re-apply sign
        return FixedType { mag: res_u128, sign: res_sign };
    }
}

impl FixedDivEq of DivEq::<FixedType> {
    #[inline(always)]
    fn div_eq(ref self: FixedType, other: FixedType) {
        self = Div::div(self, other);
    }
}

impl FixedPartialOrd of PartialOrd::<FixedType> {
    #[inline(always)]
    fn le(a: FixedType, b: FixedType) -> bool {
        if (a.sign < b.sign) {
            return true;
        } else {
            return a.mag <= b.mag;
        }
    }

    #[inline(always)]
    fn ge(a: FixedType, b: FixedType) -> bool {
        if (a.sign > b.sign) {
            return true;
        } else {
            return a.mag >= b.mag;
        }
    }

    #[inline(always)]
    fn lt(a: FixedType, b: FixedType) -> bool {
        if (a.sign < b.sign) {
            return true;
        } else {
            return a.mag < b.mag;
        }
    }

    #[inline(always)]
    fn gt(a: FixedType, b: FixedType) -> bool {
        if (a.sign > b.sign) {
            return true;
        } else {
            return a.mag > b.mag;
        }
    }
}

impl FixedNeg of Neg::<FixedType> {
    #[inline(always)]
    fn neg(a: FixedType) -> FixedType {
        if (a.sign == POSITIVE) {
            return FixedType { mag: a.mag, sign: NEGATIVE };
        } else {
            return FixedType { mag: a.mag, sign: POSITIVE };
        }
    }
}

// INTERNAL

fn _exp2(self: FixedType) -> FixedType {
    if (self.mag == 0_u128) {
        return Fixed::from_int(1);
    }

    let (int_part, frac_part) = _split_unsigned(self);
    let int_res = _pow_int(Fixed::from_int(2), int_part, POSITIVE);

    // 1.069e-7 maximum error
    let a1 = Fixed::from_felt(18446742102121545016);
    let a2 = Fixed::from_felt(12786448315833223256);
    let a3 = Fixed::from_felt(4429795821981912136);
    let a4 = Fixed::from_felt(1030550312125424568);
    let a5 = Fixed::from_felt(164966079091297224);
    let a6 = Fixed::from_felt(34983544691898416);

    let frac_fixed = Fixed::from_felt(frac_part.into());
    let r6 = a6 * frac_fixed;
    let r5 = (r6 + a5) * frac_fixed;
    let r4 = (r5 + a4) * frac_fixed;
    let r3 = (r4 + a3) * frac_fixed;
    let r2 = (r3 + a2) * frac_fixed;
    let frac_res = r2 + a1;
    let res_u = int_res * frac_res;

    if (self.sign == NEGATIVE) {
        return Fixed::from_int(1) / res_u;
    } else {
        return res_u;
    }
}

// Returns the sign of a signed `felt`
// 1 = positive (including zero)
// 0 = negative
fn _felt_sign(a: felt) -> u128 {
    if (integer::u256_from_felt(a) <= integer::u256_from_felt(HALF_PRIME)) {
        return POSITIVE;
    } else {
        return NEGATIVE;
    }
}

// Returns the absolute value of a signed `felt`
fn _felt_abs(a: felt) -> felt {
    let a_sign = _felt_sign(a);

    if (a_sign == NEGATIVE) {
        return a * -1;
    } else {
        return a;
    }
}

fn _log2(a: FixedType) -> FixedType {
    match try_fetch_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt>();
            array_append::<felt>(ref data, 'OOG');
            panic(data);
        },
    }

    assert(a.sign == POSITIVE, 'must be positive');

    if (a.mag == ONE_u128) {
        return Fixed::from_int(0);
    } else if (a.mag < ONE_u128) {
        // Compute negative inverse binary log if 0 < x < 1
        let div = Fixed::from_int(1) / a;
        return -_log2(div);
    }

    let msb_u128 = _msb(a.mag / 2_u128);
    let divisor = _pow_int(Fixed::from_int(2), msb_u128, POSITIVE);
    let norm = a / divisor;

    // 4.233e-8 maximum error
    let a1 = Fixed::from_felt(-63187350828072553424);
    let a2 = Fixed::from_felt(150429590981271126408);
    let a3 = Fixed::from_felt(-184599081115266689944);
    let a4 = Fixed::from_felt(171296190111888966192);
    let a5 = Fixed::from_felt(-110928274989790216568);
    let a6 = Fixed::from_felt(48676798788932142400);
    let a7 = Fixed::from_felt(-13804762162529339368);
    let a8 = Fixed::from_felt(2284550827067371376);
    let a9 = Fixed::from_felt(-167660832607149504);

    let r9 = a9 * norm;
    let r8 = (r9 + a8) * norm;
    let r7 = (r8 + a7) * norm;
    let r6 = (r7 + a6) * norm;
    let r5 = (r6 + a5) * norm;
    let r4 = (r5 + a4) * norm;
    let r3 = (r4 + a3) * norm;
    let r2 = (r3 + a2) * norm;
    return r2 + a1 + Fixed::from_int(msb_u128.into());
}

// Calculates the most significant bit
fn _msb(a: u128) -> u128 {
    match try_fetch_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt>();
            array_append::<felt>(ref data, 'OOG');
            panic(data);
        },
    }

    if (a <= ONE_u128) {
        return 0_u128;
    }

    return 1_u128 + _msb(a / 2_u128);
}

// Calclates the value of x^y and checks for overflow before returning
// TODO: swap to signed int when available
fn _pow_int(a: FixedType, b: u128, sign: u128) -> FixedType {
    match try_fetch_gas() {
        Option::Some(_) => {},
        Option::None(_) => {
            let mut data = array_new::<felt>();
            array_append::<felt>(ref data, 'OOG');
            panic(data);
        },
    }

    if (sign == NEGATIVE) {
        return Fixed::from_int(1) / _pow_int(a, b, POSITIVE);
    }

    let (div, rem) = integer::u128_safe_divmod(b, integer::u128_as_non_zero(2_u128));

    if (b == 0_u128) {
        return Fixed::from_int(1);
    } else if (rem == 0_u128) {
        return _pow_int(a * a, div, POSITIVE);
    } else {
        return a * _pow_int(a * a, div, POSITIVE);
    }
}

// Ignores sign and always returns positive
fn _split_unsigned(a: FixedType) -> (u128, u128) {
    return integer::u128_safe_divmod(a.mag, integer::u128_as_non_zero(ONE_u128));
}
