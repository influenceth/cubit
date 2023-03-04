use traits::Into;
use cubit::math::Fixed;
use cubit::math::FixedAdd;
use cubit::math::FixedAddEq;
use cubit::math::FixedImpl;
use cubit::math::FixedInto;
use cubit::math::FixedPartialEq;
use cubit::math::FixedSub;
use cubit::math::FixedType;

#[test]
fn test_add() {
  let a = Fixed::new(1);
  let b = Fixed::new(2);
  let c = Fixed::new(3);
  assert(a + b == c, 'Wrong');
}

#[test]
fn test_add_eq() {
  let mut a = Fixed::new(1);
  let b = Fixed::new(2);
  let c = Fixed::new(3);
  a += b;
  assert(a == c, 'Wrong');
}

#[test]
fn test_sub() {
  let a = Fixed::new(5);
  let b = Fixed::new(2);
  let c = Fixed::new(3);
  assert(a - b == c, 'Wrong');
}

#[test]
fn test_into() {
  let a = Fixed::new(5);
  assert(a.into() == 5, 'Wrong');
}

#[test]
#[should_panic]
fn test_overflow_large() {
  let too_large = 0x20000000000000000000000000000000;
  Fixed::new(too_large);
}

#[test]
#[should_panic]
fn test_overflow_small() {
  let too_small = -0x20000000000000000000000000000000;
  Fixed::new(too_small);
}
