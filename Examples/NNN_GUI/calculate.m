function [egs,lattice]=calculate(pump1,M,loss,alpha,tr,edgepump,bulkedgeratio)
            %% PARAMETERS*************************************************
            %% PARAMETERS*************************************************
            %edgepump=1;
            %pump1=S.pump1;
            if edgepump==1
                pump2=pump1;
                %loss=pump1*(44/224);
            else
                loss=pump1;
                pump2=0;
            end
            timelimit=1000;
            %% CREATE EQUATIONS********************************************
            J=1;%normalize wrt J
            %tr=0.1;%should be larger than 1
            sigma=24;
            %threshold=(1/tr)*(1/(tph*sigma)+1);
            %% Initialize Class B model
%             eqna=ClassBdetuning();
%             eqna.par.M=M;%detuning
%             eqna.par.loss=loss;
%             eqna.par.alpha=alpha;
%             eqna.par.sigma=sigma;%
%             eqna.par.pump=pump2;%
%             eqna.par.tr=tr;%
%             eqna.options.custom.Init_E='random';
%             eqna.options.custom.Init_N='steady';
%             eqna.initE=1;
%             eqnb=eqna;
%             eqnb.par.pump=pump1;
%             if edgepump==0
%                 %now, we make one site lossless, the other gainless
%                 eqnb.par.loss=0;
%                 eqna.par.pump=0;
%             end
%             eqnb.par.M=-M;
%% Initialize Class A model
            eqna=ClassA();
            eqna.par.loss=loss;
            eqna.par.pump=pump1;%
            eqna.par.M=M;%detuning
            eqnb=eqna;
            eqnb.par.M=-M;
            
            %% CREATE LATTICE***********************************************
            option=NNN.option_list;%get default option object
            option.custom.edges='baklava';%set edge option
            if edgepump==1
                option.custom.pump='edge';%pump edges only
            end
            %option.custom.BC='periodic1';
            %option.custom.pump='edge';%pump edges only
            lattice=NNN(eqna,eqnb,12,12,option);
            %Bulk-Edge separate pumping option
            if edgepump==1
            lattice.separatepumprate=pump1*bulkedgeratio;
            end
            lattice.J=J;
            %% SOLVE********************************************************
            egs=Solver.calceig(lattice);
        end