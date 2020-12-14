include
n=10;
phi=0;
g=0.1;
kx=0;
%ky=0;
init=0;
T=3/2;%floquet period
N_steps=100;%Floquet steps
kxlist=-pi:0.1:pi;
J=pi;%default value
plotsteps=20;
extra=1;
% PLOTS FLOQUET SEASONS
% for season=1:4
%     lat(season)=Floquet(n,g,[kx ky],J,init,season);
%     Visual.showNodes(lat(season));
%     xlabel(num2str(season))
%     H(:,:,season)=full(Solver.calch(lat(season)));
%     %
%     pause(3)
% end

%% SEMI-INFINITE BAND DIAGRAM
for jj=1:length(kxlist)
    kxi=kxlist(jj);
    for season=1:4
        lat(season)=Floquet(n,g,[kxi 0 ],J,init,season,'strip');
        H(:,:,season)=full(Solver.calch(lat(season)));
    end
    
    %EIGENVALS
    
    U1 = expm(-1i*H(:,:,1)*T/4);
    U2 = expm(-1i*H(:,:,2)*T/4);
    U3 = expm(-1i*H(:,:,3)*T/4);
    U4 = expm(-1i*H(:,:,4)*T/4);
    
    %Propagator
    U = U4*U3*U2*U1;
    
    %%eigenvalues
    [EV,E] = eig(U);
    [eglist(jj,:),I]=sort(real(1i*1/T*log(diag(E))),'ascend');
end
plot(kxlist,eglist,'red')

