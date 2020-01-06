classdef Analyze
    methods (Static)
        function [amp,freq,error]=getfrequency(soln)
            %returns the most prominent frequency
            %*****parameters**********************
            ntime=2000;%time steps
            steady=0.5;%choose between 0-1 to specify steady state time
            snode=0;%selected node, if==0 calculate average of nodes
            sfield=1;%selected field
            %*****parameters END******************
            %interpolate
            tmax=soln.time(end);
            timesteps=tmax*steady:(1-steady)*tmax/(ntime-1):tmax;
            field=soln.fields(:,:,sfield);
            if snode==0
                field=sum(field,2);%sum through nodes
            else
                field=field(:,snode);
            end
            [~,nn]=size(field);
            fieldint=zeros(ntime,nn);  
            for i=1:nn
                fieldint(:,i)=interp1(soln.time,field(:,i),timesteps);
            end
            %fft of the field intensity
            fft0=fft(abs(fieldint).^2);
            fft0=abs(fft0);
            [~,freq]=max(fft0);
            amp=mean(abs(field).^2);
            error=(sum(fft0)-amp)/amp;
        end
        function merit=objfun(soln)
            [amp,~,error]=Classify.getfrequency(soln);
            merit=error/(amp);
        end
        function [result,change,spec]=checksteady(soln)
            %settings**********
            checkonlyfirstfield=true;
            selectmaxnode=true;
            N_segment=20;
            threshold=0.01;%threshold in spectral change
            output=false;%print result
            sfield=1;%# of selected field
            %******************
            time=soln.time;
            tmax=time(end);
            tlen=length(time);
            signal=soln.fields;
            
            if checkonlyfirstfield==true
                if selectmaxnode
                    %sum intensities of each field and find max
                    [maxval,snode] = max(mean(abs(soln.fields(floor(end/2):end,:,1)'),2));
                else
                    snode=10;%I selected an arbitrary node
                end
                field=soln.fields(:,snode,sfield);
                time=soln.time;
                %plot(time,abs(field));
                samp=floor(tlen/N_segment);
                spec=spectrogram(field,samp,floor(samp/2),'yaxis','centered','MinThreshold',-30);
                avg=mean(abs(spec));
                change=mean(diff(abs(spec)')')./avg(2:end);
            else
                disp('checking only first field, other options not implemented');
            end
            if abs(change(end))<threshold
                result=true;
                if output
                    disp('equilibrium detected. change=');
                    disp(change(end));
                end
            else
                result=false;
                if output
                    disp('no equilibrium. change=');
                    disp(change(end));
                end
            end
            intensity=mean(mean(abs(signal(floor(9*end/10:end),:,sfield))));
            change=mean(change((end-2):end))/intensity;
        end
        %calculates sum of 4th power of the mode
        function dev=modepower(egs,n)
            if nargin>1
                if n<=length(egs.values)||n<1
                    dev=sum( abs(egs.vectors(:,n)).^4);
                else
                    warning('plotEigen: invalid Eigenvector index');
                end
            else                
                    dev=sum(abs(egs.vectors).^4);
            end
        end
        function res=edginess(soln)
            edges=[soln.lattice.type]=='c';
            sfield=1;
            signal=soln.fields(end,:,sfield);
            res=sum(abs(signal(edges)))/sum(abs(signal));
        end
    end
end