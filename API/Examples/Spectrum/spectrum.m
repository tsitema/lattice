include
pump1=1.007;
pump2=0;
%   eqna=TightBinding(M);
%   eqnb=TightBinding(-M);
%create equations********************************************
tr=100;
tph=1;%was 1
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
eqnb.par.pump=pump2*threshold;
%(pump*carrier-1)/tph*sigma
ft=0;
i=1;
timelimit=2000;
for pump1=1:0.0005:1.04
eqna.par.pump=pump1*threshold;
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
soln=Solver.calctime(lattice,timelimit);
%Visual.plotTimeAmp(soln);
error=Classify.objfun(soln);
[len,~,~]=size(soln.fields);
signal=soln.fields(floor(len/2):end,1,1);
time=soln.time(floor(len/2):end,1,1);
tstart=time(1);
tend=time(end);

%interpolate data
if i==1
tint=round(tstart):round(tend);
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
end

plot(abs(ft'))

