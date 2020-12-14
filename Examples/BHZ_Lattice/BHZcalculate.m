function [egs,lattice]=BHZcalculate(W,B,A,beta)
    include;%include directories
    if nargin==0
    %% constants from Talitha Weiß thesis page 87
    W=1;
    B=1.2;
    A=1.5;
    %nonlinearity
    beta=0.05;
    end
    %lattice size
    nx=10;
    ny=10;
    %% I use tight binding with detuning to define the first row of Hamiltonian
    eqn=KerrNonlinearity(2*W,beta);
    eqn.options.custom.Init_psi='random';
    % BHZ lattice creates links (hopping terms) between orbitals
    lattice=BHZ(eqn,nx,ny,A,B);
    %Visual.showNodes(lattice);
    %calculate eigenvalues and eigenvectors
    egs=Solver.calceig(lattice);
    %plot eigenvalues
    %scatter(real(egs.values),imag(egs.values))
end