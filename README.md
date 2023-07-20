# Cubit

![Workflow Tests Status](https://github.com/influenceth/cubit/actions/workflows/test.yaml/badge.svg) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/auditless/cairo-template/blob/main/LICENSE)

A fixed point math library in 64.64 and 32.32 representation built for Cairo & Starknet. Successor to [**`influenceth/cairo-math-64x61`**](https://github.com/influenceth/cairo-math-64x61)

Cubit is currently a WORK IN PROGRESS and should not be used in production (yet). Contributions are welcomed.

## Usage ##
Cubit was built with [**`auditless/cairo-template`**](https://github.com/auditless/cairo-template), reference its installation guide to install dependencies.

## Signed Fixed Point Numbers ##
A signed 64.64-bit fixed point number is a fraction in which the numerator is a signed 128-bit integer and the denominator is 2^64. Since the denominator stays the same there is no need to store it (as in a floating point value).

64.64 (`f128`) values can represent values in the range of -2^64 to 2^64 with precision to 1e-20.
32.32 (`f64`) values can represent vlaues in the range of -2^32 to 2^32 with precision to 1e-9.

## Core Library ##
All libraries in Cubit are referenced via the core type first, either `cubit::f64` or `cubit::f128`.

Within each library, the following functions are available:
`core` includes the following implementations for the `Fixed` type:
- `Add` (`+`)
- `AddEq` (`+=`)
- `Sub` (`-`)
- `SubEq` (`-=`)
- `Mul` (`*`)
- `MulEq` (`*=`)
- `Div` (`/`)
- `DivEq` (`/=`)
- `PartialEq` (`==`, `!=`)
- `PartialOrd` (`>`, `>=`, `<`, `<=`)
- `fixed.ceil`
- `fixed.exp`
- `fixed.floor`
- `fixed.ln`
- `fixed.log2`
- `fixed.log10`
- `fixed.pow`
- `fixed.round`
- `fixed.sqrt`

`trig` includes precise and fast versions of the following trigonometric functions:
- `fixed.cos`
- `fixed.cos_fast`
- `fixed.sin`
- `fixed.sin_fast`
- `fixed.tan`
- `fixed.tan_fast`
- `fixed.acos`
- `fixed.acos_fast`
- `fixed.asin`
- `fixed.asin_fast`
- `fixed.atan`
- `fixed.atan_fast`

## License

[MIT](https://github.com/influenceth/cubit/LICENSE) © [Unstoppable Games, Inc.](https://unstoppablegames.io)
