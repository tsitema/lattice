include
n=10;%Lattice width=height
g=10;%Nonlinearity
init=0;%default initial value
T=1;%floquet period
N_steps=100;%Floquet steps
J=pi;%default value
plotsteps=2;

%% %%%%%%%%%TIME DEPENDENT%%%%%%%%%%%%%%%%%%%%%%%%
%Create 4 lattice for each Floquet season
for season=1:4
    lat(season)=Floquet([n n],g,[0 0 ],J,init,season,'finite');
end

%%%%%%%%%%INITIAL STATE%%%%%%%%%%%%%%%%%%%%%%%%%%%
%N_node=floor(n^2/2 +n/2+1);% selected node to excite FOR MIDPOINT
N_node=1;% selected node to excite FOR EDGE

lat(1).nodes(N_node).eqn.initial.psi=1; %Single site excitation 

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

%fields=cat(1,fields{:});
%cat(1,time{:});