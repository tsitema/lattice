include
averaging=100;
%SCAN 3 Bands
for nband=1:3
    data=dlmread(strcat('band',num2str(nband),'.tsv'));
    glist=data(:,1);
    klist=data(:,2);
    
    alist=data(:,7)+1i.*data(:,8);
    clist=data(:,9)+1i.*data(:,10);
    partlist=zeros(length(glist),1);
    avgpart=partlist;
    for ai=1:averaging
        parfor gi=1:length(glist)
            %Parameters
            g=glist(gi);
            phi=pi/2;
            k=klist(gi);
            N=40;%lattice size N=n*2 pi/k, where n is an integer
            timelimit=20*pi;%100 def
            
            %% TIME DOMAN
            %initial values
            %Calculated steady state amplitude
            a0=alist(gi);
            c0=clist(gi);
            %
            % a0=-0.258199;c0=0.930949;
            % a0=sqrt(3)/3;c0=a0;
            %Phases
            a= a0;%.*exp(-1i*(phi+k)/2);
            c= c0;%.*exp(1i*(phi-k)/2);
            b= sqrt(1-abs(a0)^2-abs(c0)^2);
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
            
            % if rem(gi,13)==1
            % pcolor(soln.time,[1:N],totalfield'); shading flat; colormap hot;
            % pause(1)
            % end
            % ylabel('site number'); xlabel('time');
            % colorbar()
            
            lastfield=totalfield(end,:);
            firstfield=totalfield(1,:);
            %plot(lastfield)
            npart=N*mean(sum(totalfield(floor(end/2):end,:).^2,2)./sum(totalfield(floor(end/2):end,:),2).^2);
            %npart=mean(std(totalfield(floor(end/2):end,:),1,2));%STANDARD DEV
            %npart=sum(lastfield.^2)./sum(lastfield);
            partlist(gi)=npart;
        end
        avgpart=avgpart+partlist;
        %figure('Position', [10 10 300 200])
        
    end
    avgpart=avgpart/averaging;
    F = scatteredInterpolant(klist,glist,avgpart);
    dlmwrite('data1.txt',[klist,glist,avgpart],'Delimiter','\t')
    pcolor(reshape(glist,[20 21]),reshape(klist,[20 21]),reshape(avgpart,[20 21])); shading flat; colormap hot;
    colorbar();
    drawnow();
    %caxis([1 2.5]);
    % pcolor(abs(soln.fields').^2); shading flat; colormap hot;
    ylabel('k'); xlabel('g');
end