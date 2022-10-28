StLifeIns
============================

StLifeIns is [Julia](https://julialang.org/) package that can be used for stochastic life insurance valuations.

StLifeIns is built to be simply understood and accessible. There is no need to understand actuarial notation nor is there a need to set up formulae involved in any calculations. Once the relevant policy information has been read into the appropriate coding structures, all that is left is determining the bases that need to be used.

The diagram below gives a quick structure flow for a reserving valuation. Through the construction of Policies, each made up of a [Life](life) and several applicable [Cashflows](cashflows), and the specification of a suitable stochastic basis, many possible reserves can be calculated under various probabilistic circumstances.

```{figure} StLifeInsStructure.jpeg
---
scale: 75%
---
```