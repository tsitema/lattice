function error=NNN_optimizer(pumps)
pump1=pumps(1);
pump2=pumps(2);
%   eqna=TightBinding(M);
%   eqnb=TightBinding(-M);
%create equations********************************************
tr=100;
tph=1;
sigma=24;
threshold=(1/tr)*(1/(tph*sigma)+1);
eqna=ClassB();
eqna.par.tph=tph;
eqna.par.alpha=3;
eqna.par.sigma=sigma;%/tph;
eqna.par.pump=pump1*threshold;%/tph;
eqna.par.tr=tr;%*tph;
eqna.options.custom.Init_E='random';
eqna.options.custom.Init_N='steady';
eqnb=eqna;
eqnb.par.pump=pump2;
%(pump*carrier-1)/tph*sigma

%create lattice***********************************************
option=NNN.option_list;%get default option object
option.custom.edges='baklava';%set edge option
%option.custom.pump='edge';%pump edges only
lattice=NNN(eqna,eqnb,5,5,option);
lattice.J=3;
%SOLVE********************************************************
% egs=Solver.calceig(lattice);
%visualization methods
%Visual.plotEig(egs,1);
soln=Solver.calctime(lattice,1000);
% Visual.plotTimeAmp(soln);
error=Classify.objfun(soln);
% figure
% Visual.graphTimeAmp(soln);
%Visual.showNodes(lattice);