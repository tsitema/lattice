include
n=10;%Strip height
g=0.1;%Nonlinearity
kx=0;
ky=0;
init=0;
T=1;%floquet period
N_steps=100;%Floquet steps
kxlist=-pi:0.1:pi;
J=pi;%default value
a=1/sqrt(2);
b=-1/sqrt(2);
enableplot=true;
plotsteps=10;
%% %%%%%%%%%TIME DEPENDENT%%%%%%%%%%%%%%%%%%%%%%%%
%Create 4 lattice for each Floquet season
for season=1:4
    lat(season)=Floquet(n,g,[kx 0 ],J,init,season,'strip');
    H(:,:,season)=full(Solver.calch(lat(season)));
end

%%%%%%%%%%INITIAL STATE%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wave excitation
for nn=1:2:length(lat(1).nodes)
lat(1).nodes(nn).eqn.initial.psi=a.*exp(1i*ky*(nn-1)/2);
lat(1).nodes(nn+1).eqn.initial.psi=b.*exp(1i*ky*(nn-1)/2);
end
%%%%%%%%%%CALL RUNGE KUTTA%%%%%%%%%%%%%%%%%%%%%%%%
sol=Solver.calctime(lat(1),T/2);
if enableplot
    Visual.graphTimeAmp(sol,0,T/2,plotsteps,gca);
    %scale graph
    posn=get(gcf,'Position');posn(3:4)=[150 500];set(gcf,'Position',posn);
end
%%%%%%%%%SCAN THROUGH SEASONS%%%%%%%%%%%%%%%%%%%%
time=cell(N_steps,1);
fields=cell(N_steps,1);
for cnt=1:N_steps
    season=mod(cnt,4)+1;    
    %
    lat(season).init=sol.fields(end,:);    
    sol=Solver.calctime(lat(season),T/2);
    time{cnt}=sol.time+(cnt-1)*T/2;
    fields{cnt}=sol.fields;
    disp(strcat('Step: ',num2str(cnt)));
    %drawnow;
    if enableplot; Visual.graphTimeAmp(sol,0,T/2,plotsteps,gca); end
end
time=time;
fields=cat(1,fields{:});
cat(1,time{:});