function DiodeTolerancing
%in1=[[0.590277222787643,-3.36009358208986e-05,3.53658280558023,-2.77666592155084,-0.0545067697156059,-0.661402381705982,1.22683993202632,-0.00253206456340535]]
%    J1 J2  J3   M1  M2  P1  P2 P3
%in2=[1 0*0.07 0.5 0.2	3.7	0.36 2.1 0];
in5= [18.6 0.096761 35.1044 4.6512 18.4837 0.6287 1.6023 3.3836];

in3=[27.0992 1.7571  0.6014  25.7998 5.1462 0.4836 1.7965 2.0193];
in4=[57.2526 1.1084 50.4612 1.0357 3.6486 1.3855 1.1387 68.2952];
N=1;
init=in5;%2*rand(N,8);
result=zeros(N,12);
opt= optimset( 'MaxIter',200);%'PlotFcns',@optimplotfval,
f =@(x) optim(x);
errormargin=0.000001;
%for ii=1:N
for ii=1:N
    hold on    
    err=errormargin*(rand(size(init))-0.5);
    result(ii)=optim(init.*(1-err))
end
%result=result(result(:,end)<0,:);%record only the best
dlmwrite('result.txt',result,'\t')
end

function res=optim(vars)
vars=abs(vars);
tlim=700;
kex=1;%external coupling constant
%par=struct('J1',1,'J2',1,'M1',0,'M2',0,'pump1',1,'pump2',1,'loss1',0.5,'loss2',0.5);
%par=struct('J1',rand(),'J2',rand(),'M1',2*rand()-1,'M2',2*rand()-1,'pump1',rand()-0.5,'pump2',rand()-0.5,'loss1',rand()-0.5,'loss2',rand()-0.5);
par=struct('J1',vars(1),'J2',0,'J3',vars(3),'M1',vars(4),'M2',vars(5),'pump1',vars(6),'pump2',vars(7),'pump3',vars(8),'loss1',0.1,'loss2',0.1,'loss3',0.1);
diode=node3(par);

diode.off();
sln=Solver.calctime(diode,tlim);
offval=abs(sln.fields(end,3,1)).^2+abs(sln.fields(end,1,1)).^2;
res=0;
inputs=[0 0.01 0.02 0.05 0.07 0.1];
for jj=1:length(inputs)
input=inputs(jj);
diode.forward(input);
sln=Solver.calctime(diode,tlim);
% if Analyze.getfreqPN(sln)<0.97
%     res=1000;
%     return 
% end
%Visual.graphTimeAmp(sln);
Visual.plotTimeAmp(sln)
forward(jj)=abs(sln.fields(end,3,1)).^2;
diode.reverse(input);
sln=Solver.calctime(diode,tlim);
reverse(jj)=abs(sln.fields(end,1,1))^2;
%Visual.graphTimeAmp(sln);
%  hold on
%  Visual.plotTimeAmp(sln)
%  hold off
%  ylim([0 1])
%  drawnow

%res=mean(reverse./forward -forward+offval*100);
disp(par)
disp(strcat('forward: ',num2str(forward),' forward/reverse: ',num2str(forward/reverse),' off: ',num2str(offval),' opt: ',num2str(res)))

end
scatter([-flip(inputs) inputs],[-flip(reverse) forward ])
xlabel('input')
ylabel('output')

end

function [forward, reverse, offval]=test(vars)
vars=abs(vars);
tlim=200;
kex=1;%external coupling constant
input=1;
%par=struct('J1',1,'J2',1,'M1',0,'M2',0,'pump1',1,'pump2',1,'loss1',0.5,'loss2',0.5);
%par=struct('J1',rand(),'J2',rand(),'M1',2*rand()-1,'M2',2*rand()-1,'pump1',rand()-0.5,'pump2',rand()-0.5,'loss1',rand()-0.5,'loss2',rand()-0.5);
par=struct('J1',vars(1),'J2',0,'J3',vars(3),'M1',vars(4),'M2',vars(5),'pump1',vars(6),'pump2',vars(7),'pump3',vars(7),'loss1',0.1,'loss2',0.1,'loss3',0.1);
diode=node3(par);
diode.off();
sln=Solver.calctime(diode,tlim);
offval=abs(sln.fields(end,3,1)).^2+abs(sln.fields(end,1,1)).^2;
diode.forward(input);
sln=Solver.calctime(diode,tlim);

%Visual.graphTimeAmp(sln);
%Visual.plotTimeAmp(sln)
forward=abs(sln.fields(end,3,1)).^2;
diode.reverse(input);
sln=Solver.calctime(diode,tlim);
reverse=abs(sln.fields(end,1,1))^2;
res=reverse/forward -forward+offval*100;
disp(par)
disp(strcat('forward: ',num2str(forward),' reverse: ',num2str(reverse),' off: ',num2str(offval),' opt: ',num2str(res)))
%Visual.graphTimeAmp(sln);
%  hold on
%  Visual.plotTimeAmp(sln)
%  hold off
%  drawnow

end