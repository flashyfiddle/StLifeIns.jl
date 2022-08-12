Documentation
============================

Where, typically, valuations are done on an expected basis, one would have an equation of the form

```{math}
:label: detval
V_t = \sum_{t} p_t v^t c_t
```

where $V_t$ is the valuation amount at time t, $c_t$ is a cashflow amount contingent on an event with probability $p_t$ of occurring and $v^t$ is the discount rate up to time $t$ for every $t$.

Instead, where a stochastic valuation is done, we might generalise Equation {eq}`detval` to

```{math}
:label: stochval
V_t^s = \sum_{t} P_t \left(\prod_{i=0}^t v_i\right) C_t
```

where $V_t^s$ is now a stochastic valuation amount at time t, $C_t$ is a random variable cashflow amount contingent on an event with random variable probability $P_t$ of occurring and $v_i$ is a random variable denoting the discount factor applicable for the period $(i-1, i]$ only ($v_0=1$).

So for a stochastic life valuation we would need a mortality model to sample $P_t$ from and an interest rate model from which to obtain the $v_i$s. Life insurance benefits are typically prespecified, but where they may be unknown in amount or, particularly, where cashflows such as expenses are inflation-linked, some probability model may be required to sample values of $C_t$.

We can go one step further from here by using the sampled probabilities $P_t$ to further sample from survival, death and termination of the policy at each time $t$ until a policyholder has either survived an entire term, else died or terminated the contract.