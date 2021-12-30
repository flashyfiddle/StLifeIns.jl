abstract type Contingency end
struct Definite <: Contingency end # cashflows that happen with probability 1 throughout
abstract type Indefinite <: Contingency end
abstract type Decrement <: Indefinite end

struct InForce <: Indefinite end
struct OnDeath <: Decrement end
struct OnTermination <: Decrement end
