classdef Classify
    methods (Static)
        function [amp,freq,error]=getfrequency(soln)
            %*****parameters**********************
            ntime=1000;%time steps
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
    end
end