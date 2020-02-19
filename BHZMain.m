
include;%include directories
%% constants from Talitha Weiß thesis page 87
W=1;
B=1.2;
A=1.5;
%nonlinearity
beta=0.05;
%calculation time limit
timelimit=10;
%lattice size
nx=10;
ny=10;
%% Ker nonlinearity 
eqn=KerrNonlinearity(2*W,beta);%KerrNonlinearity(Energy,nonlinearity)
eqn.options.custom.Init_psi='random';
%% BHZ lattice creates links (hopping terms) between orbitals
opt=lattice.option_list;
opt.custom.initialpulse='leftedge';
opt.custom.pulseintensity=1;
lattice=BHZ(eqn,nx,ny,A,B,opt);
%% CALCULATIONS
%calculate eigenvalues and eigenvectors
egs=Solver.calceig(lattice);

%calculate time dependent field
soln=Solver.calctime(lattice,timelimit);

%% PLOTS
%plot eigenvalues
scatter(real(egs.values),imag(egs.values))
figure
%show an animation of time evolution
Visual.graphTimeAmp(soln)
figure
%show plot
Visual.showNodes(lattice);
figure
%plot spectrum
Visual.plotfft(soln);
figure
%plot time dependent fields
Visual.plotTimeAmp(soln)