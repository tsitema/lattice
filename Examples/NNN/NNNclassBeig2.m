clear
sweep=0.001:0.01:2;
for i=1:length(sweep)
pump1=sweep(i);
%% PARAMETERS*************************************************
%pump1=S.pump1;
M=4;
alpha=0;
pump2=0;
loss=0;%pump1;
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
% %now, we make one site lossless, the other gainless
% eqnb.par.loss=0;
% eqna.par.pump=0;
% eqnb.par.M=-M;
%% CREATE LATTICE***********************************************
option=NNN.option_list;%get default option object
option.custom.edges='b';%set edge option
%option.custom.pump='edge';%pump edges only
lattice=NNN(eqna,eqnb,12,12,option);
lattice.J=J;
%% SOLVE********************************************************
egs=Solver.calceig(lattice);
if i==1
  l1=length(egs.vectors);
  vectors=zeros(l1,l1,length(sweep));
  vectors(:,:,i)=egs.vectors;
  e1=real(egs.values);
  elist(:,i)=e1;
else
%SORTING
%   vectors(:,:,i)=egs.vectors;
%   corr=vectors(:,:,i)*conj(vectors(:,:,i-1))';
%   [a,b]=max(corr.*conj(corr));
%   nshift=sum(diff(b)~=1);
%   if nshift>0
%       disp('eigs shifted');
%   end
%   length(unique(b));
  %surf(abs(corr))
    %reorder
    e1=real(egs.values);
    elist(:,i)=e1;%(b);
    %colormap
    colorlist(:,i)=Analyze.modepower(egs);
end
%visualization methods
 [m,in]=max(real(egs.values));
 %Visual.plotEig(egs,in);
 %hold on
end
[n,m]=size(elist);
for k=1:m
[~,ind]=sort(elist(:,k));
elist(:,k)=elist(ind,k);
colorlist(:,k)=colorlist(ind,k);
end
ncolor=255;
%cmap=cool(ncolor);
minv=min(min(colorlist));
maxv=max(max(colorlist));
scaled=floor((ncolor-1)*(colorlist-minv)/(maxv-minv)+1);
%cs=cmap(scaled(1,:));

hold on
cd = [uint8((jet(ncolor))*ncolor) uint8(1:255)'].' ;
for j=1:n
p=plot(sweep,elist(j,:)-sweep, 'LineWidth',1);
p.Color(4) = 0.5;
drawnow
set(p.Edge, 'ColorBinding','interpolated', 'ColorData',cd(:,scaled(j,:)))
end
xlabel('pump1');
ylabel('real(eig)');
ylim([-0.5 0.01]);
%colorbar()
% %export
%  colorlist=colorlist';
%  elist=elist';
%  plotdata = colorlist(:,[1;1]*(1:size(colorlist,2)));
%  plotdata(:,1:2:end)=elist;
%  plotdata=[sweep' plotdata];