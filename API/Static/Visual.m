%contains the static methods relevant to plotting
classdef Visual
    methods (Static)
        %PLOTS GRAPH OF GIVEN HAMILTONIAN
        function showH(H)
            plot(graph(abs(H.*(1-eye(size(H))))))
        end
        %PLOTS GRAPH OF NODE NETWORK
        function pl=showNodes(nodes, plotHandle)
            shownodenumbers=false;
            if isa(nodes,'Node')==1
                nodes=nodes(:);%flatten
            elseif isa(nodes,'Lattice')==1
                nodes=nodes.nodes(:);
            else
                warning('shownodes: not a Node or Lattice')
            end
            A=Solver.calcadj(nodes);
            gr=graph(abs(A.*(1-eye(size(A)))));
            xps=[nodes.x];
            yps=[nodes.y];
            if isempty(xps)||isempty(yps)
                pl=plot(gr);
            else
                if shownodenumbers
                    id=[nodes.ID];%+0.1*rand(size(yps)));
                else
                    id=[];
                end
                if nargin>1
                    pl=plot(plotHandle, gr, 'XData', xps, 'YData',yps,'NodeLabel',id);
                else
                    pl=plot(gr, 'XData', xps, 'YData',yps,'NodeLabel',id);
                end
            end
            pl.MarkerSize = 9;
            types=unique([nodes.type]);
            colorpalette=jet(length(types));
            for i=1:length(nodes)
                ct=nodes(i).type;
                if length(types)>0
                highlight(pl,nodes(i).ID,'NodeColor',colorpalette(types==ct,:));
                else
                highlight(pl,nodes(i).ID);
                end
            end
        end
        
        %plots nth eigenvector
        function plotEig(eigensystem, n, plotHandle)
            if n<=length(eigensystem.values)||n<1
                if nargin>2
                    pl=Visual.showNodes(eigensystem.nodes', plotHandle);
                else
                    pl=Visual.showNodes(eigensystem.nodes');
                end
                vector=abs(eigensystem.vectors(:,n));
                minv=min(vector);
                maxv=max(vector);
                %colormap
                ncolor=50;
                cmap=cool(ncolor);
                scaled=floor((ncolor-1)*(vector-minv)/(maxv-minv)+1);
                for i=1:length(eigensystem.nodes)
                    highlight(pl,eigensystem.nodes(i).ID,'NodeColor',cmap(scaled(i),:));
                end
               %TEXT 
               text(plotHandle,0,0,strcat('t= ',num2str(n),'eig= ',num2str(eigensystem.values(n))));
            else
                warning('plotEigen: invalid Eigenvector index');
            end
        end
        %This function plays an animation of the time evolution of the fields
        function graphTimeAmp(soln, tstart, tend, ntime, plotHandle)
            %******PARAMETERS********
            ncolor=50;%number of colors
            sfield=1;%# of selected field
            pausetime=0.01;
            if nargin==1
                tstart=0;
                tend=soln.time(end);
                ntime=200;%number of time steps
                plotHandle=gca;
            elseif nargin>=3
                %ok
            end
            %******parameters END****
            if nargin>4
                pl=Visual.showNodes(soln.lattice,plotHandle);
            else
                pl=Visual.showNodes(soln.lattice,plotHandle);
            end
            field=soln.fields(:,:,sfield);
            %absolute square
            field=abs(field).^2;
            %interpolate fields
            if ntime>1
                timesteps=tstart:(tend-tstart)/(ntime-1):tend;
            else
                timesteps=tstart;
            end
            fieldint=zeros(ntime,length(soln.lattice));
            for i=1:length(soln.lattice)
                fieldint(:,i)=interp1(soln.time,field(:,i),timesteps);
            end
            %scale fields
            minv=min(fieldint');
            maxv=max(fieldint');
            for sc=1:ntime
                if maxv(sc)~=minv(sc)
                    scaled(sc,:)=floor((ncolor-1)*(fieldint(sc,:)-minv(sc))./(maxv(sc)-minv(sc))+1);
                else
                    %if field is constant
                    scaled(sc,:)=ones(1,length(soln.lattice));
                end
            end
            %colormap
            cmap=cool(ncolor);
            %scan times
            for i=1:ntime
                curtime=scaled(i,:);
                %scaled=floor((ncolor-1)*(fieldint-min(fieldint))/(max(curtime)-min(curtime))+1);
                for j=1:length(soln.lattice)
                    highlight(pl,soln.lattice(j).ID,'NodeColor',cmap(curtime(j),:));
                end
                xlabel(plotHandle,strcat('t= ',num2str(timesteps(i)),'  max E= ', num2str(maxv(i))));
                %colorbar(plotHandle,cmap)
                pause(pausetime)
            end
        end
        function plotTimeAmp(soln,plotHandle)
            if nargin==1
                plotHandle=gca;
            end
            %pl=Visual.showNodes(soln.lattice);
            sfield=1;
            field=soln.fields(:,:,sfield);
            %absolute square
            field=abs(field).^2;
            plot(plotHandle,soln.time,field);
        end
        function plotfft(soln,snode,plotHandle,options)
            %*****parameters**********************
            ntime=1001;%time steps
            %FFT is calculated for time interval steady*tmax:tmax
            steady=0.5;%choose between 0-1 to specify steady state time
            if nargin==1
                snode=0;%selected node, if==0 calculate all nodes
                plothandle=gca;
            elseif nargin==2
                plothandle=gca;
            end
            sfield=1;%selected field
            %*****parameters END******************
            %interpolate
            tmax=soln.time(end);
            fs=tmax*steady/ntime;%sampling frequency
            timesteps=tmax*steady:(1-steady)*tmax/(ntime-1):tmax;
            field=soln.fields(:,:,sfield);
            if snode==0
                %field=sum(field,2);%sum through nodes
            else
                field=field(:,snode);
            end
            [~,nn]=size(field);
            fieldint=zeros(ntime,nn);  
            for i=1:nn
                fieldint(:,i)=interp1(soln.time,field(:,i),timesteps);
            end
            %fft of the field intensity
            fft0=fft(fieldint);
            fft0=abs((fft0));
            [~,freq]=max(fft0);
            amp=mean(abs(field).^2);
            error=(sum(fft0)-amp)/amp;
            [xmax,ymax]=size(fft0);
            markersize=5;
            Fs=1/((1-steady)*tmax/(ntime-1));
            freqrange= Fs*[-ntime/2:(ntime/2-1)];
            f = Fs/2*linspace(0,1,ntime/2+1);
            f=[-flip(f(2:end)) f];
            %repmat(1:xmax,[1 ymax])
            xdata=repmat(freqrange,[1 ymax]);
            %sort fft with respect to the first row
            fft0=fftshift(sortrows(fft0',1)');
            ydata=(fft0(:));
            cmap=jet(nn);
            cla(plotHandle,'reset');
            hold(plotHandle,'on');
            for j=1:nn
                pl=plot(plotHandle,f,fft0(:,j),'Color',cmap(j,:));
            end
            hold(plotHandle,'off');
%              pl=scatter(plotHandle,xdata, ydata,markersize,...
%              'r','filled','MarkerFaceAlpha',0.05,'defaultAxesColorOrder',cmap);
        end
        function saveVideo(soln)
            %******parameters********
            ncolor=50;%number of colors
            sfield=1;%# of selected field
            nframes=500;%number of frames
            pausetime=0.01;
            %******parameters END****
            
            pl=Visual.showNodes(soln.lattice);
            field=soln.fields(:,:,sfield);
            %absolute square
            field=abs(field).^2;
            %interpolate fields
            timesteps=0:soln.time(end)/(nframes-1):soln.time(end);
            fieldint=zeros(nframes,length(soln.lattice));
            for i=1:length(soln.lattice)
                fieldint(:,i)=interp1(soln.time,field(:,i),timesteps);
            end
            %scale fields
            minv=min(fieldint');
            maxv=max(fieldint');
            for sc=1:nframes
                if maxv(sc)~=minv(sc)
                    scaled(sc,:)=floor((ncolor-1)*(fieldint(sc,:)-minv(sc))./(maxv(sc)-minv(sc))+1);
                else
                    %if field is constant
                    scaled(sc,:)=ones(1,length(soln.lattice));
                end
            end
            %colormap
            cmap=cool(ncolor);
            
            F(nframes) = struct('cdata',[],'colormap',[]);%frames
            %scan times
            for i=1:nframes
                curtime=scaled(i,:);
                set(gcf, 'Position',  [100, 100, 600, 600])
                %scaled=floor((ncolor-1)*(fieldint-min(fieldint))/(max(curtime)-min(curtime))+1);
                for j=1:length(soln.lattice)
                    highlight(pl,soln.lattice(j).ID,'NodeColor',cmap(curtime(j),:));
                end
                %axis([0 10 -5 5]);
                xlabel(strcat('t= ',num2str(timesteps(i)),'  max E= ', num2str(maxv(i))));
                drawnow
                F(i) = getframe(gcf);
            end
            v = VideoWriter('video.avi','Motion JPEG AVI');
            open(v);
            writeVideo(v,F(1:nframes-1));
            close(v);
        end
    end
end