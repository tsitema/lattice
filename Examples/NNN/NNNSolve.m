include
sweep=0:0.001:0.01;
for i=1:length(sweep)
M=0.0018;
phi=pi/2;
g=1;
%create equations********************************************
% tr=100;
% tph=1;%was 1
% sigma=24;
% threshold=(1/tr)*(1/(tph*sigma)+1);
% eqna=ClassB();
% eqna.par.tph=tph;
% eqna.par.alpha=3;
% eqna.par.sigma=sigma;%/tph;
% eqna.par.pump=pump1*threshold;%/tph;
% eqna.par.tr=tr;%*tph;
eqna=TightBinding(phi,M,0.01);
eqnb=TightBinding(phi,-M,0.01);
%eqna.options.custom.Init_E='random';
%eqna.options.custom.Init_N='steady';
%(pump*carrier-1)/tph*sigma

%create lattice***********************************************
option=NNN.option_list;%get default option object
option.custom.edges='baklava';%set edge option
%option.custom.pump='edge';%pump edges only
lattice=NNN(eqna,eqnb,5,5,option);
lattice.J=1;
%SOLVE********************************************************
%egs=Solver.calceig(lattice);
%visualization methods
%Visual.plotEig(egs,1);
soln=Solver.calctime(lattice,200);
%Visual.plotTimeAmp(soln);
%error=Classify.objfun(soln);
% figure
Visual.graphTimeAmp(soln);
%Visual.showNodes(lattice);

[len,~,~]=size(soln.fields);
signal=soln.fields(floor(len/2):end,1,1);
time=soln.time(floor(len/2):end,1,1);
tend=time(end);
tstart=time(1);
tstep=0.1;
i=1
%interpolate data
if i==1
tint=ceil(tstart):tstep:floor(tend);
end
eint=interp1(time,signal,tint);

%calculate FT
if i==1
ft=fft(eint);
else
ft=[ft; fft(eint)];
end
% plot(abs(signal));
% figure
%Visual.graphTimeAmp(soln);
%Visual.showNodes(lattice);
i=i+1;

plot(abs(ft'))
end