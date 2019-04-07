if !(VERSION.major==0&&VERSION.minor<=6)
	using Test
else
	using Base.Test
end
using FinancialToolbox

print_colored("Starting Hyper Dual Numbers Test\n",:green)

#Test Parameters
testToll=1e-14;
spot=10;K=10;r=0.02;T=2.0;sigma=0.2;d=0.01;

#EuropeanCall Option
PriceCall=blsprice(spot,K,r,T,sigma,d);
DeltaCall=blsdelta(spot,K,r,T,sigma,d);
ThetaCall=blstheta(spot,K,r,T,sigma,d);
RhoCall=blsrho(spot,K,r,T,sigma,d);
LambdaCall=blslambda(spot,K,r,T,sigma,d);
VannaCall=blsvanna(spot,K,r,T,sigma,d);

#EuropeanPut Option
PricePut=blsprice(spot,K,r,T,sigma,d,false);
DeltaPut=blsdelta(spot,K,r,T,sigma,d,false);
ThetaPut=blstheta(spot,K,r,T,sigma,d,false);
RhoPut=blsrho(spot,K,r,T,sigma,d,false);
LambdaPut=blslambda(spot,K,r,T,sigma,d,false);
VannaPut=blsvanna(spot,K,r,T,sigma,d,false);

#Equals for both Options
Gamma=blsgamma(spot,K,r,T,sigma,d);
Vega=blsvega(spot,K,r,T,sigma,d);

########HYPER DUAL NUMBERS
using HyperDualNumbers;
DerToll=1e-13;
di=1e-15;
#Function definition
SpotHyper=hyper(spot,1.0,1.0,0.0);
rHyper=hyper(r,1.0,1.0,0.0);
THyper=hyper(T,1.0,1.0,0.0);
SigmaHyper=hyper(sigma,1.0,1.0,0.0);
KHyper=hyper(K,1.0,1.0,0.0);


#Function definition
#Call
F(spot)=blsprice(spot,K,r,T,sigma,d);
FF(spot)=blsdelta(spot,K,r,T,sigma,d);
G(r)=blsprice(spot,K,r,T,sigma,d);
H(T)=blsprice(spot,K,r,T,sigma,d);
L(sigma)=blsprice(spot,K,r,T,sigma,d);
P(spot)=blsprice(spot,K,r,T,sigma,d)*spot.f0/blsprice(spot.f0,K,r,T,sigma,d);
V(sigma)=blsdelta(spot,K,r,T,sigma,d);
VV(spot,sigma)=blsprice(spot,K,r,T,sigma,d);
#Put
F1(spot)=blsprice(spot,K,r,T,sigma,d,false);
FF1(spot)=blsdelta(spot,K,r,T,sigma,d,false);
G1(r)=blsprice(spot,K,r,T,sigma,d,false);
H1(T)=blsprice(spot,K,r,T,sigma,d,false);
P1(spot)=blsprice(spot,K,r,T,sigma,d,false)*spot.f0/blsprice(spot.f0,K,r,T,sigma,d,false);
V1(sigma)=blsdelta(spot,K,r,T,sigma,d,false);
V11(spot,sigma)=blsprice(spot,K,r,T,sigma,d,false);

#TEST
print_colored("--- European Call Sensitivities: HyperDualNumbers\n",:yellow)
print_colored("-----Testing Delta\n",:blue);
@test(abs(F(SpotHyper).f1-DeltaCall)<DerToll)
print_colored("-----Testing Gamma\n",:blue);
@test(abs(FF1(SpotHyper).f1-Gamma)<DerToll)
print_colored("-----Testing Gamma  2\n",:blue);
@test(abs(F(SpotHyper).f12-Gamma)<DerToll)
print_colored("-----Testing Rho\n",:blue);
@test(abs(G(rHyper).f1-RhoCall)<DerToll)
print_colored("-----Testing Theta\n",:blue);
@test(abs(-H(THyper).f1-ThetaCall)<DerToll)
print_colored("-----Testing Lambda\n",:blue);
@test(abs(P(SpotHyper).f1-LambdaCall)<DerToll)
print_colored("-----Testing Vanna\n",:blue);
@test(abs(V(SigmaHyper).f1-VannaCall)<DerToll)
print_colored("-----Testing Vanna  2\n",:blue);
@test(abs(VV(hyper(spot,1,0,0),hyper(sigma,0,1,0)).f12-VannaCall)<DerToll)

## Complex Test with Complex Step Approximation for European Put
#TEST
print_colored("--- European Put Sensitivities: HyperDualNumbers\n",:yellow)
print_colored("-----Testing Delta\n",:blue);
@test(abs(F1(SpotHyper).f1-DeltaPut)<DerToll)
print_colored("-----Testing Rho\n",:blue);
@test(abs(G1(rHyper).f1-RhoPut)<DerToll)
print_colored("-----Testing Theta\n",:blue);
@test(abs(-H1(THyper).f1-ThetaPut)<DerToll)
print_colored("-----Testing Lambda\n",:blue);
@test(abs(P1(SpotHyper).f1-LambdaPut)<DerToll)
print_colored("-----Testing Vanna\n",:blue);
@test(abs(V1(SigmaHyper).f1-VannaPut)<DerToll)
print_colored("-----Testing Vanna  2\n",:blue);
@test(abs(V11(hyper(spot,1,0,0),hyper(sigma,0,1,0)).f12-VannaPut)<DerToll)
print_colored("-----Testing Vega\n",:blue);
@test(abs(L(SigmaHyper).f1-Vega)<DerToll)
print_colored("Hyper Dual Numbers Test Passed\n\n",:green)



#TEST OF INPUT VALIDATION
print_colored("Starting Input Validation Test Hyper Dual Numbers\n",:magenta)
print_colored("----Testing Negative  Spot Price \n",:cyan)
@test_throws(ErrorException, blsprice(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blkprice(-SpotHyper,K,r,T,sigma))
@test_throws(ErrorException, blsdelta(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blsgamma(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blstheta(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blsrho(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blspsi(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blslambda(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blsvanna(-SpotHyper,K,r,T,sigma,d))
@test_throws(ErrorException, blsvega(-SpotHyper,K,r,T,sigma,d))

print_colored("----Testing Negative  Strike Price \n",:cyan)
@test_throws(ErrorException, blsprice(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blkprice(spot,-KHyper,r,T,sigma))
@test_throws(ErrorException, blsdelta(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blsgamma(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blstheta(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blsrho(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blspsi(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blslambda(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blsvanna(spot,-KHyper,r,T,sigma,d))
@test_throws(ErrorException, blsvega(spot,-KHyper,r,T,sigma,d))

print_colored("----Testing Negative  Time to Maturity \n",:cyan)
@test_throws(ErrorException, blsprice(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blkprice(spot,K,r,-THyper,sigma))
@test_throws(ErrorException, blsdelta(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blsgamma(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blstheta(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blsrho(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blspsi(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blslambda(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blsvanna(spot,K,r,-THyper,sigma,d))
@test_throws(ErrorException, blsvega(spot,K,r,-THyper,sigma,d))

print_colored("----Testing Negative  Volatility \n",:cyan)
@test_throws(ErrorException, blsprice(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blkprice(spot,K,r,T,-SigmaHyper))
@test_throws(ErrorException, blsdelta(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blsgamma(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blstheta(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blsrho(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blspsi(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blslambda(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blsvanna(spot,K,r,T,-SigmaHyper,d))
@test_throws(ErrorException, blsvega(spot,K,r,T,-SigmaHyper,d))

print_colored("Hyper Dual Input Validation Test Passed\n",:magenta)