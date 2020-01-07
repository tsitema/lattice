function [] = NNNclassBeig()
include
S.fh = figure('units','pixels', 'position',[600 600 700 700],...
              'menubar','none',...
              'name','slider_plot',...
              'numbertitle','off');    
S.ax = axes('units', 'pixels', 'position',[100 250 550 400]);

S.fcn = @(pump1,M,loss) calculate(pump1,M,loss,alpha);
S.pump1=0.03;
S.M=0;
S.loss=0;
S.alpha=0;
egs=calculate(S.pump1,S.M,S.loss,S.alpha);
S.LN  = scatter(real(egs.values), imag(egs.values), 'r'); 
update(S);
% Slider for slope parameter:
S.mSlider = uicontrol('style','slider',...
                 'unit','pixels',...  
                 'position',[40 50 500 20],...
                 'min',0,'max',10,'value', S.pump1,...
                 'sliderstep',[1/20 1/20],...
                 'callback', {@SliderCB, 'pump1'},'tooltip','pump1'); 
% 2nd Slider:
S.bSlider = uicontrol('style','slide',...
                 'unit','pixels', 'position',[40 100 500 20],...
                 'min',-4,'max',4,'value', S.M,...
                 'sliderstep',[1/20 1/20],...
                 'callback', {@SliderCB, 'M'},'tooltip','M'); 
S.cSlider = uicontrol('style','slide',...
                 'unit','pixels', 'position',[40 150 500 20],...
                 'min',0,'max',10,'value', S.alpha,...
                 'sliderstep',[1/20 1/20],...
                 'callback', {@SliderCB, 'alpha'},'tooltip','alpha'); 
guidata(S.fh, S);  % Store S struct in the figure
end
function SliderCB(mSlider, EventData, Param)
% Callback for both sliders
S = guidata(mSlider);  % Get S struct from the figure
S.(Param) = get(mSlider, 'Value');  % Either 'm' or 'b'
update(S);
guidata(mSlider, S);  % Store modified S in figure
end
function update(S)
%y = S.fcn(S.x, S.m, S.b);   % @(x, m, b) m * x + b;
egs=calculate(S.pump1,S.M,S.loss,S.alpha);
y=imag(egs.values);
x=real(egs.values);
set(S.LN, 'YData', y);
set(S.LN, 'XData', x);
xlabel({'real(eig)',strcat('loss: ',num2str(S.loss), '   M:  ',num2str(S.M),'   pump1:  ',num2str(S.pump1),'   alpha1:  ',num2str(S.alpha))})
ylabel('imag(eig)')
end


%% 
function egs=calculate(pump1,M,loss,alpha)      
%% PARAMETERS*************************************************
        %% PARAMETERS*************************************************
        edgepump=1;
        %pump1=S.pump1;
        if edgepump==1
        pump2=pump1;
        loss=pump1*(44/224);
        else
            loss=pump1;
            pump2=0;
        end
        %M=S.M;
        %tph=S.tph;
        timelimit=500;
        %% CREATE EQUATIONS********************************************
        J=1;%normalize wrt J
        tr=100;%should be larger than 1
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
         option.custom.pump='edge';%pump edges only
        end
        %option.custom.BC='periodic1';
        %option.custom.pump='edge';%pump edges only
        lattice=NNN(eqna,eqnb,12,12,option);
        lattice.J=J;
        %% SOLVE********************************************************
        egs=Solver.calceig(lattice);
end