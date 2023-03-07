# Cubit

![Workflow Tests Status](https://github.com/influenceth/cubit/actions/workflows/test.yaml/badge.svg) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/auditless/cairo-template/blob/main/LICENSE)

A fixed point math library in 64.64 representation built for Cairo 1.0 & Starknet. Successor to [**`influenceth/cairo-math-64x61`**](https://github.com/influenceth/cairo-math-64x61)

Cubit is currently a WORK IN PROGRESS and should not be used in production (yet). Contributions are welcomed.

## Usage ##
Cubit was built with [**`auditless/cairo-template`**](https://github.com/auditless/cairo-template), reference its installation guide to install dependencies.

## Signed 64.64 Fixed Point Numbers ##
A signed 64.64-bit fixed point number is a fraction in which the numerator is a signed 128-bit integer and the denominator is 2^64. Since the denominator stays the same there is no need to store it (as in a floating point value).

Can represent values in the range of -2^64 to 2^64 with precision to 1e-20.

## Core Library ##
`cubit::core` includes the following implementations for the `Fixed` type:
- `Fixed::from_felt` - creates a `Fixed` type from a pre-scaled `felt`
- `Fixed::from_int` - creates and scales a `felt` into a `Fixed` type
- `Into` (`fixed.into()`) - converts the `Fixed` value into a `felt`
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

## License

[MIT](https://github.com/influenceth/cubit/LICENSE) © [Unstoppable Games, Inc.](https://unstoppablegames.io)
