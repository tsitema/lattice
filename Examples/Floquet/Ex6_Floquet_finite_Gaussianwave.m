%FOR SQUARE LATTICE NX=NY, WAVE EXCITATION, GAUSSIAN ENVELOPE OPEN BOUNDARIES
include
n=10;%Lattice width=height
g=0.1;%Nonlinearity
kx=pi/2;
ky=0;
A=1;%wave amplitude per node
sigma=3;%GAUSSIAN WIDTH
x0=floor(n/2);%GAUSSIAN CENTER
y0=x0;%GAUSSIAN CENTER
init=0;%default initial value
T=1;%floquet period
N_steps=100;%Floquet steps
kxlist=-pi:0.1:pi;
J=pi;%default value
plotsteps=20;
%% %%%%%%%%%TIME DEPENDENT%%%%%%%%%%%%%%%%%%%%%%%%
%Create 4 lattice for each Floquet season
for season=1:4
    lat(season)=Floquet([n n],g,[0 0 ],J,init,season,'finite');
end

%%%%%%%%%%INITIAL STATE%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=repmat(1:n,[n 1]);
y=x';
x=x(:);
y=y(:);
for ii=1:n*n
lat(1).nodes(ii).eqn.initial.psi=A*exp(1i.*x(ii)*kx+1i.*y(ii)*ky)...
    .*exp(-(x(ii)-x0)^2/sigma^2).*exp(-(y(ii)-y0)^2/sigma^2); %Gaussian envelope 
end

%%%%%%%%%%CALL RUNGE KUTTA%%%%%%%%%%%%%%%%%%%%%%%%
sol=Solver.calctime(lat(1),T/2);
Visual.graphTimeAmp(sol,0,T/2,plotsteps,gca);
%%%%%%%%%SCAN THROUGH SEASONS%%%%%%%%%%%%%%%%%%%%
for cnt=1:N_steps
    season=mod(cnt,4)+1;    
    %
    lat(season).init=sol.fields(end,:);    
    sol=Solver.calctime(lat(season),T/2);
    disp(strcat('Step: ',num2str(cnt)));
    drawnow;
    Visual.graphTimeAmp(sol,0,T/2,plotsteps,gca);
end

fields=cat(1,fields{:});
cat(1,time{:});