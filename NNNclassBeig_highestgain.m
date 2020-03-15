include
clear
psweep=1.95%(0.05:0.05:3); %pump
msweep=3.1%0:0.05:4; %MMMMM
asweep=0;%alpha
edgepump=1;
timelimit=1000;
%checkfor='highestgain';
%checkfor='steady';
checkfor='freq';
%checkfor='edginess';
enableplot=false;
runInSerial = enableplot;% disable/enable parallel
repeat=1;
resultav=zeros(length(psweep),length(msweep));
%% disable/enable parallel
if runInSerial
    parforArg = 0;
else
    parforArg = Inf;
end
for cnt=1:repeat
    for alpha=asweep
        if strcmp(checkfor,'highestgain')
            modepower=zeros(length(psweep),length(msweep));
            modeimag=zeros(length(psweep),length(msweep));
            result=zeros(length(psweep),length(msweep));
        elseif strcmp(checkfor,'steady')||strcmp(checkfor,'freq')||strcmp(checkfor,'edginess')
            result=zeros(length(psweep),length(msweep));
        end
        for i=1:length(psweep)
            fprintf('%d of %d\n',i,length(psweep));
    %      parfor (j=1:length(msweep),parforArg)
             for (j=1:length(msweep))
                pump1=psweep(i);
                %% PARAMETERS*************************************************
                %pump1=S.pump1;
                M=msweep(j);
                if edgepump==1
                    pump2=pump1;
                    loss=0.1;%pump1*0.05;%(44/224);
                else
                    pump2=0;
                    loss=pump1;
                end
                %M=S.M;
                %tph=S.tph;
                %% CREATE EQUATIONS********************************************
                J=1;%normalize wrt J
                tr=0.1;%should be larger than 1
                sigma=24;
                %threshold=(1/tr)*(1/(tph*sigma)+1);
                eqna=ClassBdetuning();
                eqna.par.M=M;%detuning
                eqna.par.loss=loss;
                eqna.par.alpha=alpha;
                eqna.par.sigma=sigma;%
                eqna.par.pump=pump2;%
                eqna.par.tr=tr;%
                eqna.options.custom.Init_E='random';
                eqna.options.custom.Init_N='steady';
                eqna.initE=10;
                eqnb=eqna;
                eqnb.par.pump=pump1;
                if edgepump==0
                    %now, we make one site lossless, the other gainless
                    eqnb.par.loss=0;
                    eqna.par.pump=0;
                end
                eqnb.par.M=-M;
                %% CREATE LATTICE***********************************************
                option=NNN.option_list;%get default option object
                option.custom.edges='baklava';%set edge option
                if edgepump==1
                    option.custom.pump='edge'%pump edges only
                end
                option.custom.BC='periodic1';
                option.custom.pump='edge';%pump edges only
                lattice=NNN(eqna,eqnb,12,12,option);
                lattice.J=J;
                %% SOLVE********************************************************
                if strcmp(checkfor,'highestgain')
                    egs=Solver.calceig(lattice);
                    %visualization methods
                    [m,in]=max(real(egs.values));
                    modepower(i,j)=Analyze.modepower(egs,in);
                    modeimag(i,j)=imag(egs.values(in));
                    %          Visual.plotEig(egs,in);
                    %               pause(0.1);
                    %hold on
                elseif strcmp(checkfor,'steady')
                    soln=Solver.calctime(lattice,timelimit);
                    if enableplot
                    Visual.graphTimeAmp(soln);
                    end
                    [re,result(i,j),~]=Analyze.checksteady(soln);
                elseif strcmp(checkfor,'freq')
                    soln=Solver.calctime(lattice,timelimit);
                    %[amp,result(i,j),error]=Analyze.getfrequency(soln)
                    result(i,j)=Analyze.getfreqPN(soln);
                    fprintf('pump= %d M= %d',i,j);
                    Visual.graphTimeAmp(soln);
                    result(i,j)
                elseif strcmp(checkfor,'edginess')
                    soln=Solver.calctime(lattice,timelimit);
                    result(i,j) =Analyze.edginess(soln);
                    if enableplot
                    Visual.graphTimeAmp(soln);
                    end
                end
         
            end
        end
        if strcmp(checkfor,'steady')
            resultav=resultav+abs(result);
        end
    end
    %% PLOT ********************************************
    if strcmp(checkfor,'highestgain')
        f1=figure;
        surf(msweep,psweep,log(modepower))
        xlabel('M')
        ylabel('pump')
        shading interp
        colorbar()
        view(2)
        f2=figure;
        surf(msweep,psweep,abs(modeimag))
        xlabel('M')
        ylabel('pump')
        shading interp
        colorbar()
        view(2)
        %save figures
        saveas(f1,strcat('E4_a=',num2str(alpha),'.png'))
        saveas(f2,strcat('freq_a=',num2str(alpha),'.png'))
        %save data
        
    elseif strcmp(checkfor,'steady')
        surf(msweep,psweep,((abs(result))))
        xlabel('M')
        ylabel('\gamma')
        shading interp
    end
end