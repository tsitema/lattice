classdef TightBinding <Eqn
    properties 
        %phi: phase M: detuning
        par=struct('phi',0,'M',0,'g',0);
        fields=struct('psi',0);
        initial=struct('psi',0);
        options;
    end
    properties (Constant)
        DOF=1;%internal degrees of freedom for each node.
    end
    methods
        function obj=TightBinding(detuning,phase,gain)
            if nargin==3
                obj.par.g=gain;
                obj.par.M=detuning;
                obj.par.phi=phase;
            elseif nargin==2
                obj.par.g=0;
                obj.par.M=detuning;
                obj.par.phi=phase;
            elseif nargin==1
                obj.par.g=0;
                obj.par.M=detuning;
                obj.par.phi=0;
            elseif nargin ==0
                obj.par.g=0;
                obj.par.M=0;
                obj.par.phi=0;
            end
                %obj.eqn=@(x) (2*obj.phi+obj.M)*x*(-1i);
        end
        function init=get.initial(o)
            init=o.initial;
            %init.psi=rand()*0.01;
            init.psi=0.001;
        end
    end
    methods (Static)
        function y=calc(x,p)
            y=(2.*cot(p.phi/2)+p.M+1i.*p.g).*x./(1i);
        end
    end
end
        