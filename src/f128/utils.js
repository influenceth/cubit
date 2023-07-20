import BN from 'bignumber.js';

const SCALE = BN(2).pow(64);
const HALF = SCALE.idiv(2);
const ONE = SCALE;
const TWO = SCALE.times(2);
const PI = BN('57952155664616982739');
const HALF_PI = PI.idiv(2);

// Converts to f128::Fixed representation
const toFixed = (num) => {
  let res = BN(num).times(SCALE);
  if (res.gte(BN(2).pow(128)) || res.lte(BN(2).pow(128).negated())) throw new Error('Number is out of valid range')

  return {
    mag: BigInt(res.abs().integerValue().toString(10)),
    sign: res.isNegative()
  };
};

// Converts from f128::Fixed to floating point number
const fromFixed = (num) => {
  let res = BN(num.mag);
  if (num.sign) res = res.negated();
  return res.div(SCALE).toNumber();
}

export default {
  SCALE,
  HALF,
  ONE,
  TWO,
  PI,
  HALF_PI,
  toFixed,
  fromFixed
};
