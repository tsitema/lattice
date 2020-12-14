function DiodeMain
%in1=[[0.590277222787643,-3.36009358208986e-05,3.53658280558023,-2.77666592155084,-0.0545067697156059,-0.661402381705982,1.22683993202632,-0.00253206456340535]]
%    J1 J2  J3   M1  M2  P1  P2 P3
in2=[1 0*0.07 0.5 0.2	3.7	0.36 2.1 0];
in3=[27.0992 1.7571  0.6014  25.7998 5.1462 0.4836 1.7965 2.0193];
N=1;
init=in3;%2*rand(N,8);
init=[5 5 5 5 5 1 1 1].*rand(N,8);
result=zeros(N,12);
opt= optimset( 'MaxIter',200,'TolFun',1e-2);%'PlotFcns',@optimplotfval,
gaopt = optimoptions('ga','ConstraintTolerance',1e-2,'UseParallel',1,'PlotFcn', @gaplotbestf);%
f =@(x) optim(x);

[x,fval,exitflag,output,population,scores] =ga(f,8,gaopt);

% %random search
% parfor ii=1:N
% [x,fval]=fminsearch(f,init(ii,:),opt);
% disp(strcat('min :', num2str(x)))
%    [forward, reverse, offval]=test(x);
%    result(ii,:)=[x forward reverse offval fval];
% end

%result=result(result(:,end)<0,:);%record only the best
good=population(scores<0.4,:);
save('workspace.mat')
dlmwrite('result.txt',result,'\t')
end

function res=optim(vars0)
vars0=abs(vars0);
tlim=700;
Ntrial=1;
timeout=25;
errormargin=0.01;
kex=1;%external coupling constant
%par=struct('J1',1,'J2',1,'M1',0,'M2',0,'pump1',1,'pump2',1,'loss1',0.5,'loss2',0.5);
%par=struct('J1',rand(),'J2',rand(),'M1',2*rand()-1,'M2',2*rand()-1,'pump1',rand()-0.5,'pump2',rand()-0.5,'loss1',rand()-0.5,'loss2',rand()-0.5);

for nt=1:Ntrial
%% Perturb input parametes
err=errormargin*(rand(size(vars0))-0.5);
vars=vars0.*(1-err);
%% Create nodes
par=struct('J1',vars(1),'J2',0,'J3',vars(3),'M1',vars(4),'M2',vars(5),'pump1',vars(6),'pump2',vars(7),'pump3',vars(8),'loss1',0.1,'loss2',0.1,'loss3',0.1);
diode=node3(par);
diode.off();
sln=Solver.calctime(diode,tlim);
offval=abs(sln.fields(end,3,1)).^2+abs(sln.fields(end,1,1)).^2;
    maxI=vars(2);
    inputs=[0.1 0.5 1].*maxI;
    for jj=1:length(inputs)
        input=inputs(jj);
        diode.forward(input);
        tic
        sln=Solver.calctime(diode,tlim);
        tf=toc;
        if tf>timeout; res=20*tf;disp('to');return; end
        %% check forward oscillation
        osc_f=mean(std(abs(sln.fields(floor(end/2):end,3,1)).^2));
        if osc_f>0.1*input
            res=50*osc_f;
            %Visual.plotTimeAmp(sln)
            %drawnow
            disp('forward osc');
            return
        end
        %Visual.graphTimeAmp(sln);
        %Visual.plotTimeAmp(sln)
        forward(nt,jj)=mean(abs(sln.fields(floor(end/2):end,3,1)).^2./input.^2);
        diode.reverse(input);
        tic
        sln=Solver.calctime(diode,tlim);
        tr=toc;
        if tr>timeout; res=20*tr; disp('to'); return; end
        %% check reverse oscillation
        osc_r=mean(std(abs(sln.fields(floor(end/2):end,1,1)).^2));
        if osc_r>0.1*input
            res=50*osc_r;
            %Visual.plotTimeAmp(sln)
            %drawnow
            disp('reverse osc');
            return
        end
        
        reverse(nt,jj)=mean(abs(sln.fields(floor(end/2):end,3,1)).^2./input.^2);
        %Visual.graphTimeAmp(sln);
        %  hold on
        %  Visual.plotTimeAmp(sln)
        %  hold off
        %  ylim([0 1])
        %  drawnow
    end
end
%plot([-flip(inputs) inputs],[-flip(reverse) forward ])
res=mean(mean(reverse ...
    -(forward<10).*forward -(forward>10).*10 ...
    +offval(:)*100/maxI));
%res=mean(mean(reverse ...
%    +abs(forward-0.5)...
%    +0.5*offval(:)*100));
% if res<0
%     disp(res);
% end
disp(strcat('forward/in: ',num2str(mean(forward(:),1)),' forward/reverse: ',num2str(mean(forward./reverse,1)),...
    ' off: ',num2str(offval),' opt: ',num2str(res),' MaxI: ',num2str(maxI)))
disp(par)
end
%% TEST