
include;%include directories
%% constants from Talitha Weiß thesis page 87
W=1;
B=1.2;
A=1.5;
%nonlinearity
beta=0.05;
%calculation time limit
timelimit=100;
%lattice size
nx=10;
ny=10;
%% Ker nonlinearity 
eqn=KerrNonlinearity(2*W,beta);%KerrNonlinearity(Energy,nonlinearity)
eqn.options.custom.Init_psi='random';
% BHZ lattice creates links (hopping terms) between orbitals
lattice=BHZ(eqn,nx,ny,A,B);
%Visual.showNodes(lattice);
%calculate eigenvalues and eigenvectors
egs=Solver.calceig(lattice);
%plot eigenvalues
scatter(real(egs.values),imag(egs.values))

%calculate time dependent field
sln=Solver.calctime(lattice,timelimit);

%show an animation of time evolution

%plot time dependent fields
Visual.plotTimeAmp(sln)