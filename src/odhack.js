function Fixed(mag, sign) {
    this.mag = BigInt(mag);
    this.sign = sign;
}

const ONE = BigInt(2**32);
const ONEf = new Fixed(ONE, false);
const PI = BigInt(13493037705);
const HALF_PI = PI / BigInt(2);

function toFixed(number) {
    return new Fixed(Math.floor(Math.abs(number * Number(ONE))), number < 0);
}

function toNumber(fixed) {
    return (fixed.sign?-1:1) * Number(fixed.mag) / Number(ONE);
}

function neg(a) {
    if (a.mag == 0) return a;
    return new Fixed(a.mag, !a.sign);
}

function abs(a) {
    return new Fixed(a.mag, false);
}

function add(a, b) {
    if (a.sign == b.sign) return new Fixed(a.mag + b.mag, a.sign);
    if (a.mag == b.mag) return new Fixed(0, false);
    if (a.mag > b.mag) return new Fixed (a.mag - b.mag, a.sign);
    return new Fixed(b.mag - a.mag, b.sign);
}

function sub(a, b) {
    return add(a, neg(b));
}

function mul(a, b) {
    return new Fixed(a.mag * b.mag / ONE, a.sign != b.sign);
}

function div(a, b) {
    return new Fixed(a.mag * ONE / b.mag, a.sign != b.sign);
}

function sqrt(a) {
    if (a.sign) throw 'square root of negative numbers is not supported';

    // The conversion to Number will limit our precision to the 51 bits of Number's mantisse.
    // This is an issue because we multiple by ONE (2**32) so that only leaves 19 bits of actual precision of a.
    // To fight this, if a is bigger than 2**19, we'll use the homemade bigSqrt function.
    if (a.mag < 2**19) {
        return(new Fixed(Math.floor(Math.sqrt(Number(a.mag * ONE))), false));
    }
    else {
        return(new Fixed(bigSqrt(a.mag * ONE), false));
    }
}

// https://stackoverflow.com/questions/53683995/javascript-big-integer-square-root
function bigSqrt(value) {
    if (value < 0n) {
        throw 'square root of negative numbers is not supported'
    }

    if (value < 2n) {
        return value;
    }

    function newtonIteration(n, x0) {
        const x1 = ((n / x0) + x0) >> 1n;
        if (x0 === x1 || x0 === (x1 - 1n)) {
            return x0;
        }
        return newtonIteration(n, x1);
    }

    return newtonIteration(value, 1n);
}

const slots = [
    [0, 0, 30064280]                    // 0
    , [30064771, 30064280, 60125614]
    , [60129542, 60125614, 90181058]
    , [90194313, 90181058, 120227671]
    , [120259084, 120227671, 150262518]
    , [150323855, 150262518, 180282670]
    , [180388626, 180282670, 210285207]
    , [210453398, 210285207, 240267219]
    , [240518169, 240267219, 270225809]
    , [270582940, 270225809, 300158091]
    , [300647711, 300158091, 330061199] // 10
    , [330712482, 330061199, 359932279]
    , [360777253, 359932279, 389768499]
    , [390842024, 389768499, 419567044]
    , [420906795, 419567044, 449325123]
    , [450971566, 449325123, 479039968]
    , [481036337, 479039968, 508708834]
    , [511101108, 508708834, 538329004]
    , [541165879, 538329004, 567897786]
    , [571230650, 567897786, 597412520]
    , [601295421, 597412520, 626870573] // 20
    , [631360193, 626870573, 656269345]
    , [661424964, 656269345, 685606269]
    , [691489735, 685606269, 714878810]
    , [721554506, 714878810, 744084472]
    , [751619277, 744084472, 773220790]
    , [781684048, 773220790, 802285339]
    , [811748819, 802285339, 831275734]
    , [841813590, 831275734, 860189625]
    , [871878361, 860189625, 889024705]
    , [901943132, 889024705, 917778707] // 30
    , [932007903, 917778707, 946449406]
    , [962072674, 946449406, 975034620]
    , [992137445, 975034620, 1003532209]
    , [1022202216, 1003532209, 1031940079]
    , [1052266988, 1031940079, 1060256178]
    , [1082331759, 1060256178, 1088478502]
    , [1112396530, 1088478502, 1116605090]
    , [1142461301, 1116605090, 1144634029]
    , [1172526072, 1144634029, 1172563451]
    , [1202590843, 1172563451, 1200391537]  // 40
    , [1232655614, 1200391537, 1228116512]
    , [1262720385, 1228116512, 1255736652]
    , [1292785156, 1255736652, 1283250279]
    , [1322849927, 1283250279, 1310655762]
    , [1352914698, 1310655762, 1337951519]
    , [1382979469, 1337951519, 1365136018]
    , [1413044240, 1365136018, 1392207771]
    , [1443109011, 1392207771, 1419165341]
    , [1473173783, 1419165341, 1446007339]
    , [1503238554, 1446007339, 1472732422]  // 50
    , [1533303325, 1472732422, 1499339299]
    , [1563368096, 1499339299, 1525826721]
    , [1593432867, 1525826721, 1552193491]
    , [1623497638, 1552193491, 1578438458]
    , [1653562409, 1578438458, 1604560517]
    , [1683627180, 1604560517, 1630558611]
    , [1713691951, 1630558611, 1656431729]
    , [1743756722, 1656431729, 1682178905]
    , [1773821493, 1682178905, 1707799220]
    , [1803886264, 1707799220, 1733291798]  // 60
    , [1833951035, 1733291798, 1758655812]
    , [1864015806, 1758655812, 1783890474]
    , [1894080578, 1783890474, 1808995043]
    , [1924145349, 1808995043, 1833968821]
    , [1954210120, 1833968821, 1858811150]
    , [1984274891, 1858811150, 1883521418]
    , [2014339662, 1883521418, 1908099052]
    , [2044404433, 1908099052, 1932543520]
    , [2074469204, 1932543520, 1956854330]
    , [2104533975, 1956854330, 1981031032]  // 70
    , [2134598746, 1981031032, 2005073211]
    , [2164663517, 2005073211, 2028980494]
    , [2194728288, 2028980494, 2052752544]
    , [2224793059, 2052752544, 2076389061]
    , [2254857830, 2076389061, 2099889781]
    , [2284922601, 2099889781, 2123254476]
    , [2314987373, 2123254476, 2146482953]
    , [2345052144, 2146482953, 2169575052]
    , [2375116915, 2169575052, 2192530648]
    , [2405181686, 2192530648, 2215349647]  // 80
    , [2435246457, 2215349647, 2238031989]
    , [2465311228, 2238031989, 2260577643]
    , [2495375999, 2260577643, 2282986611]
    , [2525440770, 2282986611, 2305258922]
    , [2555505541, 2305258922, 2327394635]
    , [2585570312, 2327394635, 2349393839]
    , [2615635083, 2349393839, 2371256649]
    , [2645699854, 2371256649, 2392983206]
    , [2675764625, 2392983206, 2414573679]
    , [2705829396, 2414573679, 2436028262]  // 90
    , [2735894168, 2436028262, 2457347172]
    , [2765958939, 2457347172, 2478530652]
    , [2796023710, 2478530652, 2499578968]
    , [2826088481, 2499578968, 2520492408]
    , [2856153252, 2520492408, 2541271281]
    , [2886218023, 2541271281, 2561915920]
    , [2916282794, 2561915920, 2582426676]
    , [2946347565, 2582426676, 2602803920]  // 98
    , [2976412336, 2602803920, 2623048044]  // default for >98
]

function atan(a) {
    let slot =  Math.min(Number(a / BigInt(30064771)), 99);
    return [BigInt(slots[slot][0]), BigInt(slots[slot][1]), BigInt(slots[slot][2])];
}

function atan_fast(a) {
    let at = abs(a);
    let shift = false;
    let invert = false;

    // Invert value when a > 1
    if (at.mag > ONE) {
        at = div(ONEf, at);
        invert = true;
    }

    // Account for lack of precision in polynomaial when a > 0.7
    if (at.mag > 3006477107) {
        const sqrt3_3 = new Fixed(2479700525, false); // = sqrt(3) / 3
        at = div(sub(at, sqrt3_3), add(ONEf, mul(at, sqrt3_3)));
        shift = true;
    }

    const ata = atan(at.mag);
    const partial_step = div(new Fixed(at.mag - ata[0], false), new Fixed(30064771, false));
    let res = add(mul(partial_step, new Fixed(ata[2] - ata[1], false)), new Fixed(ata[1], false));

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = add(res, new Fixed(2248839617, false)); // pi / 6
    }

    if (invert) {
        res = sub(res, new Fixed(HALF_PI, false));
    }

    return new Fixed(res.mag, a.sign);
}

function asin_fast(a) {
    if (a.mag == ONE) {
        return new Fixed(HALF_PI, a.sign);
    }
    const d = sqrt(sub(ONEf, mul(a, a))); // will fail if a > 1
    return atan_fast(div(a, d));
}

function acos_fast(a) {
    const asin_arg = sqrt(sub(ONEf, mul(a, a))); // will fail if a > 1
    const asin_res = asin_fast(asin_arg);

    if (a.sign) {
        return new Fixed(PI - asin_res.mag, false);
    }
    else {
        return asin_res;
    }
}


// ===== TEST =====

for (let i = -(2**32) ; i <= 2**32 ; i += 2**26) {
    let t = '';

    let a = new Fixed(Math.floor(Math.abs(i)), i<0);
    let atf = acos_fast(a);
    let at = Math.acos(i / 2**32);
    
    t += '\t' + (i / 2**32).toFixed(2);
    //t += '\t' + a.sign + '_' + a.mag;
    //t += '\t' + atf.sign + '_' + atf.mag;
    t += '\t' + atf.mag.toString(16);
    t += '\t' + toNumber(atf).toFixed(4);
    //t += '\t' + at.toFixed(4);
    //t += '\t' + (toNumber(atf) - at).toFixed(4);

    console.log(t);
}
