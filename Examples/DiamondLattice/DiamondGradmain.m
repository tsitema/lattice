
g=0.0;
phi=pi/2;
k=pi/2;
N=400;%lattice size N=n*2 pi/k, where n is an integer
timelimit=1000;%100 def
timelimit2=1;
a0=-0.707107i;
c0=0;
% % 
%   a0=0.249735 - 0.602913i;
%  c0=0.254187 + 0.105288i ;
%Phases
a= a0;%.*exp(-1i*(phi+k)/2);
c= c0;%.*exp(1i*(phi-k)/2);
b= sqrt(1-abs(a0)^2-abs(c0)^2);
rng(33);
lat=DiamondGradient(N,phi,g,k,[a,b,c]);

soln=Solver.calctime(lat,timelimit);

Visual.graphTimeAmp(soln);