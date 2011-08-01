module math.common;



interface Function(Real)
{
	Real opCall(Real x) pure;
	bool inRange(Real x) pure;
}

class Polynomial(Real) : Function!Real
{
	override Real opCall(Real x) pure
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

	bool inRange(Real x) pure
	{
		return x < this.range[1] && x > this.range[0];
	}

	@property Real beginning() pure
	{
		return this.range[0];
	}

protected:

	Real[] _c;
	Real[2] range;
}

unittest
{
	writeln("Polynomial Tests ...");
	Polynomial!real p = new Polynomial!real([1,1,1]);
	assert(p(.5)==1.75);
	assert(p.coef == [1,1,1]);
	//assert(p.derivative().coef == [1.,2.]);
	writeln("Polynomial Tests finished!");
}


interface PiecewisePolynomial(Real) : Function!Real
{
	Real opCall(Real x) pure;
	void addPoly(Polynomial!Real poly) pure;
	Polynomial!Real removePoly(int index) pure;
	
protected:
	int whichPiece(Real x) pure;
}

class BSpline(Real, int k, Real[] knots) : PiecewisePolynomial!Real
{

	this()
	{
	}


	override Real opCall(Real x) pure
	{
		int index = this.whichPiece(x);
		Real result = 0;
		result = polynomials[index](x);
		return result;
	}

	override void addPoly(Polynomial!Real poly) pure
	{
		polynomials[poly.beginning] = poly;
	}

	override Polynomial!Real removePoly(Real x) pure
	{
		auto p = polynomials[whichPiece(x)];
		polynomials.remove(whichPiece(x));
		return p;
	}

	void findCoefficients(int k, Real[] knots)
	{

	}

	//BSpline!Real removeBSpline(BSpline!Real b) pure
	//void addBSpline(BSpline!Real b) pure;
	//static BSpline!Real innerProduct(BSpline!Real a, BSpline!Real b) pure;
	//static BSpline!Real derivative();

private:
	
	Polynomial!(Real)[Real] polynomials;
	Real[2] range;
}

class LegendreP(Real) : Polynomial!Real
{
	Real opCall(Real x) pure;
	@property Real[] coef() pure;
	@property int coef(Real[] c) pure;

}
