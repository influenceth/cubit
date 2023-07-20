import { expect } from 'chai';
import almostEqual from 'almost-equal';
import f128 from '../src/f128/utils.js';

describe('f128 Fixed utils', function () {
  describe('toFixed', function () {
    it('should convert floating point value to Fixed', function () {
      let result = f128.toFixed(Math.PI);
      expect(almostEqual(Number(result.mag), f128.PI)).to.be.true;
      expect(result.sign).to.be.false;
    });

    it('should convert negative floating point value to Fixed', function () {
      let result = f128.toFixed(-Math.PI);
      expect(almostEqual(Number(result.mag), f128.PI)).to.be.true;
      expect(result.sign).to.be.true;
    });
  });

  describe('fromFixed', function () {
    it('should convert Fixed value to floating point', function () {
      let result = f128.fromFixed({
        mag: f128.PI,
        sign: false
      });

      expect(result.toFixed(5)).to.equal(Math.PI.toFixed(5));
    });

    it('should convert negative Fixed value to floating point', function () {
      let result = f128.fromFixed({
        mag: f128.PI,
        sign: true
      });

      expect(result.toFixed(5)).to.equal((-Math.PI).toFixed(5));
    });
  });
});