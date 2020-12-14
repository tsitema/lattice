include
lattice=load('biscuit.mat');
lattice=lattice.lattice;
Visual.showNodes(lattice);
soln=Solver.calctime(lattice,100);
Visual.graphTimeAmp(soln);