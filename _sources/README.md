# StLifeIns

StLifeIns is a package enabling stochastic valuations of life insurance products.

## Features
* Flexibility - StLifeIns can be used for several different types of life insurance
calculations including pricing, reserving and proft-testing. StLifeGPU also offers
simplistic means for constructing a wide variety of life insurance products for single
lives in a simple to understand modular process.
* Fast calculations making use of parallel processing power. StLifeIns provides the ability to transfer calculations from the CPU to the GPU (and vice versa).
* Monthly reserves - valuations are performed at a monthly frequency, leading to more exact valuations that conventional techniques where inexact approximations are made for monthly annuity or assurance functions. Monthly valuations also provide opportunities for more detailed strategies.
* Life Simulation - the outcome of each individual life can be set to be simulated, especially for products with fewer lives (where the law of large numbers ccannot yet be trusted).
* Termination - termination of contracts can also be allowed for.
