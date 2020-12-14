include
repeat=1;
%Parameters
g=0.3;
phi=pi/2;
k=pi/2;
N=40;%lattice size N=n*2 pi/k, where n is an integer
timelimit=20*pi;%100 def
timesteps=0:0.1:timelimit;
pshift=-pi:pi/50:pi;
%% TIME DOMAN
%initial values
%Calculated steady state amplitude
a0=-0.707107i;
c0=0;
% % 
%   a0=0.249735 - 0.602913i;
%  c0=0.254187 + 0.105288i ;
%Phases
a= a0;%.*exp(-1i*(phi+k)/2);
c= c0;%.*exp(1i*(phi-k)/2);
b= sqrt(1-abs(a0)^2-abs(c0)^2);
%rng(33);
totalco=zeros(length(timesteps),N);
totalfield=zeros(length(timesteps),N);
shiftlist=zeros(size(pshift));
for rep=1:repeat
for jj=1:length(pshift)
lat=Diamond(N,phi,g,k,[a,b,c]);
lat.prtPhase=pshift(jj);pshift(jj)
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

totalfield=abs(afields).^2+abs(bfields).^2+abs(cfields).^2;
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



fftr=fft(totalfield(end,:));
shiftlist(jj)=angle(fftr(31));

% pcolor(timesteps/pi,1:N,totalfield'/rep); shading flat; colormap hot;colorbar()
% xlabel('Time (\pi)');ylabel('Site Number')
% drawnow
% pause(0.1)
end
end
figure('Position',[100,100,400,200])
fig=scatter(pshift/pi,shiftlist/pi,'filled'); box on; 
xlabel('\Delta \phi (\pi)');
ylabel('\Delta x (\pi)');
drawnow