include
data=dlmread('band3.tsv');
glist=data(:,1);
klist=data(:,2);
loss=0.5;
alist=data(:,7)+1i.*data(:,8);
clist=data(:,9)+1i.*data(:,10);
partlist=zeros(length(glist),1);
%Parameters
g=0.1;
phi=pi/2;
k=pi/2;
N=40;%lattice size N=n*2 pi/k, where n is an integer
timelimit=300;%100 def
timelimit2=1000;
%% TIME DOMAN
%initial values
%Calculated steady state amplitude
a0=-0.707107i;
c0=0;
% 
%  a0=-0.17689 + 0.660163i;
% c0=-0.173125 - 0.0463888i;
%Phases
a= a0;%.*exp(-1i*(phi+k)/2);
c= c0;%.*exp(1i*(phi-k)/2);
b= sqrt(1-abs(a0)^2-abs(c0)^2);
rng(1);
lat=Diamond(N,phi,g,k,[a,b,c]);
%Visual.showNodes(lat);
soln=Solver.calctime(lat,timelimit);
%Visual.graphTimeAmp(soln);
% Visual.plotfft(soln)
%Visual.plotTimeAmp(soln);
%title(strcat('bb:',num2str(bb),' g:',num2str(g)))
% Calculate FFT
types=[soln.lattice.nodes.type];
afields=soln.fields(:,types=='a');
bfields=soln.fields(:,types=='b');
cfields=soln.fields(:,types=='c');
totalfield=abs(afields).^2+abs(bfields).^2+abs(cfields).^2;
%Visual.showNodes(lat2)
%pcolor(soln.time,[1:3*N],abs(soln.fields').^2); shading flat; colormap hot;
%pcolor(soln.time,[1:N],totalfield'); shading flat; colormap hot;
% ylabel('site number'); xlabel('time');
% colorbar()
nextinitial=soln.fields(end,:).*(1-loss);
%nextinitial(1:58)=0;nextinitial(60)=0;nextinitial(67:end)=0;%2diamond

%nextinitial(1:57)=0;nextinitial(68)=0;nextinitial(70:end)=0;%XXX
%nextinitial(1:50)=0;nextinitial(72:end)=0;%BROAD
%nextinitial(1:60)=0;nextinitial(65)=0;nextinitial(67:end)=0;%X

%nextinitial(1:61)=0;nextinitial(63:end)=0;%one point
% %RANDOM 6x6
% nextinitial=zeros(size(nextinitial));
% rnp=rand(1,6)+1i*rand(1,6);
% nextinitial(58:63)=rnp./(0.5*sum(abs(rnp).^2));
lat2=Diamond(N,phi,g,k,nextinitial);

soln2=Solver.calctime(lat2,timelimit2);


types2=[soln2.lattice.nodes.type];
afields2=soln2.fields(:,types=='a');
bfields2=soln2.fields(:,types=='b');
cfields2=soln2.fields(:,types=='c');
totalfield2=abs(afields2).^2+abs(bfields2).^2+abs(cfields2).^2;

pcolor(soln.time,[1:N],totalfield'); shading flat; colormap hot;
hold on
pcolor(soln2.time+timelimit,[1:N],totalfield2'); shading flat; colormap hot;
xlim([0 timelimit+timelimit2])
xlabel('Time');ylabel('Site Number')
%plot(lastfield)
npart=mean(sum(totalfield(floor(end/2):end,:).^2,2)./sum(totalfield(floor(end/2):end,:),2)).^2;
%npart=mean(std(totalfield(floor(end/2):end,:),1,2));%STANDARD DEV
%npart=sum(lastfield.^2)./sum(lastfield);

%LOCAL MAX
npeaks=zeros(1,size(totalfield,1));
for ii=1:size(totalfield,1)
pks=findpeaks(totalfield(ii,:));
npeaks(ii)=length(pks);
end
% %AUTOCORRELATION
% nrm=abs(afields).^2+abs(bfields).^2+abs(cfields).^2;
% nrm=(sum(nrm(:)));
% %IN SPACE
% aco=acorr(afields);
% bco=acorr(bfields);
% cco=acorr(cfields);
% totalcorr=abs(aco).^2+abs(bco).^2+abs(cco).^2;
% pcolor(soln.time,[1:N],totalcorr'./800); box on;shading flat; colormap hot;colorbar();
% xlabel('Time');ylabel('Autocorrelation shift')
% set(gca,'Layer','top')
% %IN TIME
% acot=acorr(afields');
% bcot=acorr(bfields');
% ccot=acorr(cfields');
% totalcorrt=abs(acot).^2+abs(bcot).^2+abs(ccot).^2;
% 
% figure(2)
% pcolor(soln.time,[1:N],totalcorrt./400000000); box on;shading flat; colormap hot;colorbar();
% xlabel('Time shift');ylabel('Lattice site')
% set(gca,'Layer','top')
% 
% figure(3)

