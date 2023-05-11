use cubit::types::fixed::Fixed;
use cubit::types::fixed::FixedType;
use cubit::types::fixed::ONE_u128;


// Tolerance for stopping the Newton-Raphson method
const TOLERANCE: u128 = 1844674407_u128;

fn _eccentric_anomaly_iter(mean_anom: FixedType, ecc: FixedType, prev_ecc_anom: FixedType) -> FixedType {
    let one = Fixed::new(ONE_u128, false);

    if ecc < one {
        let f = prev_ecc_anom - e * prev_ecc_anom.sin() - mean_anom;
        let df = one - ecc * prev_ecc_anom.cos();
    } else {
        let f = ecc * prev_ecc_anom.sinh() - prev_ecc_anom - mean_anom;
        let df = ecc * prev_ecc_anom.cosh() - one;
    }

    return prev_ecc_anom - f / df;
}

fn _eccentric_anomaly_rec(mean_anom: FixedType, ecc: FixedType, ecc_anom: FixedType) -> FixedType {
    let next_ecc_anom = _eccentric_anomaly_iter(mean_anom, ecc, ecc_anom);

    if (next_ecc_anom - ecc_anom).abs() > TOLERANCE {
        return _eccentric_anomaly_rec(mean_anom, ecc, next_ecc_anom);
    } else {
        return next_ecc_anom;
    }
}

fn true_anomaly(mean_anom: FixedType, ecc: FixedType) -> FixedType {
    let ecc_anom = _eccentric_anomaly_rec(mean_anom, ecc, mean_anom);
    let one = Fixed::new(ONE_u128, false);
    let two = Fixed::new(36893488147419103232, false); // 2

    if ecc < one {
        return two * ((ecc * ecc_anom.sin() / (one - ecc * ecc_anom.cos())).atan());
    } else {
        return two * ((ecc * ecc_anom.sinh() / (ecc * ecc_anom.cosh() - one)).atanh());
    }
}
