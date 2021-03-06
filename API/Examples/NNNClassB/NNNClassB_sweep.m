include
psweep=0.001:0.5:3;
pump2=0;
msweep=0:-0.5:-3;
contrast=1;
parlen=length(msweep)*length(msweep);
cnt=1;
result=zeros(length(psweep),length(msweep));
for i=1:length(psweep)
    pump1=psweep(i);
    for j=1:length(msweep)
        M=msweep(j);
        %tph=0.2;%was 1
        loss=1;
        timelimit=500;
        %   eqna=TightBinding(M);
        %   eqnb=TightBinding(-M);
        %create equations********************************************
        J=1;%normalize wrt J
        tr=100;%should be larger than 1
        sigma=24;
        %threshold=(1/tr)*(1/(tph*sigma)+1);
        eqna=ClassBdetuning();
        eqna.par.M=M;%detuning
        %eqna.par.tph=tph;
        eqna.par.loss=pump1*contrast;
        eqna.par.alpha=0;
        eqna.par.sigma=sigma;%/tph;
        eqna.par.pump=pump2;%/tph;
        eqna.par.tr=tr;%*tph;
        eqna.options.custom.Init_E='random';
        eqna.options.custom.Init_N='steady';
        eqnb=eqna;
        eqnb.par.pump=pump1;
        %(pump*carrier-1)/tph*sigma
        %now, we make one site lossless, the other gainless
        eqnb.par.loss=0;
        eqna.par.pump=0;
        eqnb.par.M=-M;
        %create lattice***********************************************
        option=NNN.option_list;%get default option object
        option.custom.edges='b';%set edge option
        option.custom.BC='periodic2';
        %option.custom.pump='edge';%pump edges only
        lattice=NNN(eqna,eqnb,12,10,option);
        lattice.J=J;
        %SOLVE********************************************************
        %egs=Solver.calceig(lattice);
        %visualization methods
        % [m,in]=max(real(egs.values));
        % scatter(real(egs.values),imag(egs.values));
        % xlabel('Real(eig)');
        % ylabel('Imag(eig)');
        %text(real(egs.values), imag(egs.values), cellstr(num2str((1:length(egs.values))')));
        % Visual.plotEig(egs,in);
        % for i=length(egs.values):-1:1
        % Visual.plotEig(egs,i);
        % pause(0.5)
        % end
        soln=Solver.calctime(lattice,timelimit);
        [re,result(i,j),~]=Analyze.checksteady(soln);
        if re
            Visual.graphTimeAmp(soln);
        end
    end
end
surf(msweep,psweep,log(abs(result)))
xlabel('M')
ylabel('\gamma')
shading interp
%result=cell2mat(steady.result);
%ms=cell2mat(steady.M);
%ps=cell2mat(steady.pump);
%scatter3(ms,ps,log(abs(result)))
%Visual.plotTimeAmp(soln);
%Visual.saveVideo(soln);
% %%FFT
% [len,~,~]=size(soln.fields);
% signal=soln.fields(floor(len/2):end,1,1);
% time=soln.time(floor(len/2):end,1,1);
% tstart=time(1);
% tend=time(end);


% %interpolate data
% tint=round(tstart):round(tend);
% eint=interp1(time,signal,tint);
% %calculate FT
% ft=fft(signal);
% %plot(abs(ft));

% figure
%Visual.graphTimeAmp(soln);
%Visual.showNodes(lattice);