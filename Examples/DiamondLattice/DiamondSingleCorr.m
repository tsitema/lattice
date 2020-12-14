include
repeat=5000;
%Parameters
g=0.3;
phi=pi/2;
k=pi/2;
N=40;%lattice size N=n*2 pi/k, where n is an integer
timelimit=10*pi;%100 def
timesteps=0:0.2:timelimit;
%% TIME DOMAN
%initial values
%Calculated steady state amplitude
a0=-1i/sqrt(2);
c0=0;
% % % 
%     a0=0.5 - 0.5i;
%     c0=-a0;
%   c0=0.356677 - 0.356677i ;
%Phases
a= a0;%.*exp(-1i*(phi+k)/2);
c= c0;%.*exp(1i*(phi-k)/2);
b= sqrt(1-abs(a0)^2-abs(c0)^2);
%rng(33);
totalco=zeros(length(timesteps),N);
totalfield=zeros(length(timesteps),N);
tcor=zeros(length(timesteps),N);
for rep=1:repeat
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
%INTERPOLATE fields
afields=interp1(soln.time,afields,timesteps);
bfields=interp1(soln.time,bfields,timesteps);
cfields=interp1(soln.time,cfields,timesteps);

totalfield=totalfield+abs(afields).^2+abs(bfields).^2+abs(cfields).^2;
% figure(1)
% pcolor(timesteps,1:N,totalfield'); shading flat; colormap hot;colorbar()
% 
% xlabel('Time');ylabel('Site Number')

%normalize a,b,c
nrm=sqrt(abs(afields).^2+abs(bfields).^2+abs(cfields).^2);
afields=afields./nrm;
bfields=bfields./nrm;
cfields=cfields./nrm;

%Correlation of the first node with others
aco=zeros(size(afields));
bco=aco;
cco=aco;
for nn=1:N
aco(:,nn)=afields(:,20).*conj(afields(:,nn));
bco(:,nn)=bfields(:,20).*conj(bfields(:,nn));
cco(:,nn)=cfields(:,20).*conj(cfields(:,nn));
end
totalco=totalco+aco+bco+cco;

%AUTOCORRELATION
nrm=(sum(nrm(:)));

tcor=tcor+acorr(afields)+acorr(bfields)+acorr(cfields);
end

% 
figure('Position',[100,100,400,200])
pcolor(timesteps/pi,1:N,abs(totalco'/rep).^2); box on;shading flat; colormap hot;colorbar();
xlabel('z');ylabel('Lattice site')
set(gca,'Layer','top')

figure('Position',[100,100,400,200])
pcolor(timesteps,1:N, totalfield'/rep); shading flat; colormap hot;colorbar()
xlabel('z');ylabel('Cell Number')

fftr=fft(totalfield(end,:)/rep)

% 
% figure('Position',[100,100,400,200])
% plot(1:N,abs(totalco(end,:)/rep).^2);
% 
% %TIME CORRELATION
% %tcor=acorr(afields)+acorr(bfields)+acorr(cfields);
% 
% figure('Position',[100,100,400,200])
% pcolor(timesteps/pi,1:N,abs(tcor)'/rep); shading flat; colormap hot;colorbar()
% xlabel('Time (\pi)');ylabel('Lattice site')