module math.calculus.integrate;

import math.solve;

/+ integrates from a to b, using the n zeroes of the nth Legendre Polynomial
 +/
Real GaussLegendre(Real,Func,int n)(Func f, Real a, Real b) pure
{
	// find the n roots:
	static Real[n] roots = math.solve.findRoots(LegendreP!(n)(x), -1., 1.);

	// map roots to 

}
