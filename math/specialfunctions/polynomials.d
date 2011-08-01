module math.specialfunctions.polynomials;

import math.common;
import std.stdio;
import std.functional;
import std.math;

class Polynomial(Real) : Function!(Real)
{
	private Real[] _c;

	this(Real[] cd) pure
	{
		this._c = cd;
	}

	Real opCall(Real x) pure
	{
		Real result = 0;

		foreach_reverse (Real cd; _c)
			result = result * x + cd;
		
		return result;
	}

	@property Real[] coef(Real[] cn) pure
	{
		return (this._c = cn);
	}

	@property Real[] coef() pure
	{
		return this._c;
	}

	Polynomial!(Real) derivative() pure
	{
		Real[] result = _c.dup;

		foreach (int i, Real cn; _c)
			result[i] = i * cn;

		Polynomial!(Real) r = new Polynomial!Real(result[1..$]);
		return r;
	}
}

unittest
{
	writeln("Polynomial Tests ...");
	Polynomial!real p = new Polynomial!real([1,1,1]);
	assert(p(.5)==1.75);
	assert(p.coef == [1,1,1]);
	assert(p.derivative().coef == [1.,2.]);
	writeln("Polynomial Tests finished!");
}

Real BinomialCoefficient(Real)(int n, int k) pure
{
	Real result = 1;
	for (int i = 1; i <= k; i++)
		result *= cast(real)(n - k + i) / cast(real)(i);
	return result;
}

unittest
{
	writeln("Binomial Tests ...");
	assert(BinomialCoefficient!(real)(7,3)==35);
	assert(BinomialCoefficient!(real)(8,4)==70);
	assert(BinomialCoefficient!(real)(8,5)==56);
	assert(BinomialCoefficient!(real)(8,7)==8);
	assert(BinomialCoefficient!(real)(8,0)==1);
	assert(BinomialCoefficient!(real)(2,1)==2);
	assert(BinomialCoefficient!(real)(0,1)==0);
	writeln("Binomial Tests finished!");
}

Polynomial!(Real) LegendreP(int n,Real)() pure 
{
	Real[n+1] coef; 
	coef[] = 0;

	for (int k = 0; k <= n/2; k++)
	{
		coef[n-2*k] = (1. / std.math.pow(2,n));
		coef[n-2*k] *= BinomialCoefficient!(Real)(n,k) * BinomialCoefficient!(Real)(2*n - 2*k, n );
		if (k%2 == 1)
			coef[n-2*k] = - coef[n-2*k];
	}

	Polynomial!(Real) result = new Polynomial!Real(coef.dup);
	return result;
}

unittest 
{
	writeln("LegendreP tests ...");
	assert(LegendreP!(0,real)()(.5) == 1);
	assert(LegendreP!(1,real)()(.5) == .5);
	assert(LegendreP!(2,real)()(.5) == -0.125);
	assert(LegendreP!(3,real)()(.5) == -0.4375);
	writeln("LegendreP tests finished!");
}

Real BSpline(int k : 0, Real)(scope Real x, scope const(Real)[] t) pure 
{
	if (t[0] <= x && x < t[k+1])
		return 1;
	else
		return 0;
}
Real BSpline(int k, Real)(scope Real x, scope const(Real)[] t) pure 
{
	if (t[0] <= x && x < t[k+1])
	{
		Real a = (x - t[0]) / (t[k] - t[0]);
		Real b = (t[k+1] - x) / (t[k+1] - t[1]);
		Real c = BSpline!(k-1,Real)(x, t[0..k+1]);
		Real d = BSpline!(k-1,Real)(x, t[1..k+2]);
		Real rv = (c?c*a:c) + (d?d*b:d);
		return rv;
	}
	else
		return 0;
}

unittest {
	writeln("BSpline Tests ...");
	real a = .5;
	real[] b = [0,0,1,2,3,4,5,6,7,8,9,10];
	assert(BSpline!(0,real)(a,b) == 0);
	assert(BSpline!(1,real)(a,b) == 0.5);
	assert(BSpline!(2,real)(a,b) == .625);
	assert(BSpline!(3,real)(a,b) - 0.2604166666666666666 < .0000000000000000001);
	assert(BSpline!(4,real)(a,b) - 0.0616319444444444444 < .0000000000000000001);
	writeln("BSpline Tests finished!");
}

class BSplineClass(int k, Real) : Function!Real
{
	private:
		Real[] _t;
		//Real delegate(Real) funct;

	public:
		this(Real[] t) pure
		{
			this._t = t;
		}

		Real opCall(Real x) pure
		{
			return BSpline(x, _t);
		}

		static Real BSpline(scope Real x, scope const(Real)[] t) pure 
		{
			static if (k == 0)
			{
				if (t[0] <= x && x < t[k+1])
					return 1;
				else
					return 0;
			}
			else
			{
				if (t[0] <= x && x < t[k+1])
				{
					Real a = (x - t[0]) / (t[k] - t[0]);
					Real b = (t[k+1] - x) / (t[k+1] - t[1]);
					Real c = BSplineClass!(k-1,Real).BSpline(x, t[0..k+1]);
					Real d = BSplineClass!(k-1,Real).BSpline(x, t[1..k+2]);
					Real rv = (c?c*a:c) + (d?d*b:d);
					return rv;
				}
				else
					return 0;
			}
		}

		static Real delegate(Real)
}

unittest {
	writeln("BSpline class Tests ...");
	real a = .5;
	real[] b = [0,0,1,2,3,4,5,6,7,8,9,10];
	writeln("testing k = 0");
	BSplineClass!(0,real) bs = new BSplineClass!(0,real)(b);
	assert(bs(a) == 0);
	writeln("testing k = 1");
	BSplineClass!(1,real) b1 = new BSplineClass!(1,real)(b);
	assert(b1(a) == .5);
	writeln("testing k = 2");
	BSplineClass!(2,real) b2 = new BSplineClass!(2,real)(b);
	assert(b2(a) == .625);
	writeln("testing k = 3");
	BSplineClass!(3,real) b3 = new BSplineClass!(3,real)(b);
	assert(b3(a) - 0.2604166666666666666 < .0000000000000000001);
	writeln("testing k = 4");
	BSplineClass!(4,real) b4 = new BSplineClass!(4,real)(b);
	assert(b4(a) - 0.0616319444444444444 < .0000000000000000001);
	writeln("BSpline class Tests finished!");
}
