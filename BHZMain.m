
include;%include directories
%% constants from Talitha Weiß thesis page 87
W=-1;
B=1;
A=1;
%nonlinearity
beta=1;
%calculation time limit
timelimit=500;
%lattice size
nx=15;
ny=15;
%% Ker nonlinearity 
eqn=KerrNonlinearity(2*W,beta);%KerrNonlinearity(Energy,nonlinearity)
eqn.options.custom.Init_psi='random';
eqn.random_intensity=1e-3;
%% BHZ lattice creates links (hopping terms) between orbitals
opt=BHZ.option_list;
% opt.custom.initialpulse='leftedge';
% opt.custom.pulseintensity=1;
opt.custom.BC='periodic';%boundary conditions
lattice=BHZ(eqn,nx,ny,A,B,opt);
%% CALCULATIONS
%calculate eigenvalues and eigenvectors
%egs=Solver.calceig(lattice);

%calculate time dependent field
soln=Solver.calctime2(lattice,timelimit);

%% PLOTS
%plot eigenvalues
%scatter(real(egs.values),imag(egs.values))
figure
%show an animation of time evolution
Visual.graphTimeAmp(soln)
%figure
% %show plot
% Visual.showNodes(lattice);
% figure
% %plot spectrum
% Visual.plotfft(soln);
% figure
%plot time dependent fields
%Visual.plotTimeAmp(soln)