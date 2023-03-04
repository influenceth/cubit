use traits::Into;
use result::ResultTrait;
use result::ResultTraitImpl;

#[derive(Copy, Drop)]
struct FixedType { val: felt }

trait Fixed {
  fn new(f: felt) -> FixedType;

  fn checked(self: FixedType) -> Result::<FixedType, FixedType>;
}

impl FixedImpl of Fixed {
  fn new(f: felt) -> FixedType {
    let fixed = FixedType { val: f };
    return fixed.checked().expect('Overflow of 64.61 value');
  }

  fn checked(self: FixedType) -> Result::<FixedType, FixedType> {
    if (self.val >= 0x20000000000000000000000000000000) {
      if (self.val <= -0x20000000000000000000000000000000) {
        return Result::Err(self);
      } else {
        return Result::Ok(self);
      }
    } else {
      return Result::Ok(self);
    }
  }
}

impl FixedInto of Into::<FixedType, felt> {
  fn into(self: FixedType) -> felt {
    return self.val;
  }
}

impl FixedAdd of Add::<FixedType> {
  fn add(a: FixedType, b: FixedType) -> FixedType {
    return Fixed::new(a.val + b.val);
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
    return Fixed::new(a.val - b.val);
  }
}

impl FixedSubEq of SubEq::<FixedType> {
  #[inline(always)]
  fn sub_eq(ref self: FixedType, other: FixedType) {
    self = Sub::sub(self, other);
  }
}

impl FixedPartialEq of PartialEq::<FixedType> {
  #[inline(always)]
  fn eq(a: FixedType, b: FixedType) -> bool {
    return a.val == b.val;
  }

  #[inline(always)]
  fn ne(a: FixedType, b: FixedType) -> bool {
    return !(a.val == b.val);
  }
}
