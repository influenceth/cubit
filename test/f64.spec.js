import { expect } from 'chai';
import almostEqual from 'almost-equal';
import f64 from '../src/f64/utils.js';

describe('f64 Fixed utils', function () {
  describe('toFixed', function () {
    it('should convert floating point value to Fixed', function () {
      let result = f64.toFixed(Math.PI);
      expect(almostEqual(Number(result.mag), f64.PI)).to.be.true;
      expect(result.sign).to.be.false;
    });

    it('should convert negative floating point value to Fixed', function () {
      let result = f64.toFixed(-Math.PI);
      expect(almostEqual(Number(result.mag), f64.PI)).to.be.true;
      expect(result.sign).to.be.true;
    });
  });

  describe('fromFixed', function () {
    it('should convert Fixed value to floating point', function () {
      let result = f64.fromFixed({
        mag: f64.PI,
        sign: false
      });

      expect(result.toFixed(5)).to.equal(Math.PI.toFixed(5));
    });

    it('should convert negative Fixed value to floating point', function () {
      let result = f64.fromFixed({
        mag: f64.PI,
        sign: true
      });

      expect(result.toFixed(5)).to.equal((-Math.PI).toFixed(5));
    });
  });
});