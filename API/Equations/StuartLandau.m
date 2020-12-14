classdef StuartLandau <Eqn
    properties 
        %W: energy beta: nonlinearity constant
        par=struct('kappa',0,'omega',0,'gamma',0);
        fields=struct('psi',0);
        initial=struct('psi',0);
        random_intensity=1e-3;%intensity of the initial random field
        options;
    end
    properties (Constant)
        DOF=1;%internal degrees of freedom for each node.
        option_list=Options('Init_psi',{'default','zero'}); 
    end
    methods
        function o=StuartLandau(kappa,omega,gamma)
            if nargin>0
            o.par.kappa=kappa;
            end
            if nargin>1
            o.par.omega=omega;
            end
            if nargin>2
            o.par.omega=omega;
            end
            o.options=o.option_list;
        end
        function init=get.initial(o)
            init=o.initial;
            if strcmp(o.options.custom.Init_psi,'default')
            init.psi=rand()*o.random_intensity;  
            end
        end
    end
    methods (Static)
        function y=calc(x,p)
            y=(p.kappa-1i.*p.omega-p.gamma.*abs(x).^2).*x;
        end
        function er=getlinear(p)   
            er=(p.kappa-1i.*p.omega);
        end
    end
end
        