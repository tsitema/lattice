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
plotsteps=20;

%% %%%%%%%%%TIME DEPENDENT%%%%%%%%%%%%%%%%%%%%%%%%
%Create 4 lattice for each Floquet season
for season=1:4
    lat(season)=Floquet(n,g,[kx 0 ],J,init,season);
    H(:,:,season)=full(Solver.calch(lat(season)));
end

%%%%%%%%%%INITIAL STATE%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_node=1;% selected node to excite
lat(1).nodes(N_node).eqn.initial.psi=1; %Single site excitation 

%%%%%%%%%%CALL RUNGE KUTTA%%%%%%%%%%%%%%%%%%%%%%%%
sol=Solver.calctime(lat(1),T/2);
Visual.graphTimeAmp(sol,0,T/2,plotsteps,gca);
%scale graph
posn=get(gcf,'Position');posn(3:4)=[150 500];set(gcf,'Position',posn);
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