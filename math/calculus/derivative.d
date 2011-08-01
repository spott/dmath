module math.calculus.derivative;

T derivative(T:Polynomial!(Real), Real)(T funct) pure
{
	return funct.derivative()
}


T derivative(T, Real)(T funct) pure
{
	funct
	return funct.derivative()
}
