classdef KerrNonlinearity <Eqn
    properties 
        %W: energy beta: nonlinearity constant
        par=struct('W',0,'beta',0);
        fields=struct('psi',0);
        initial=struct('psi',0);
        options;
    end
    properties (Constant)
        DOF=1;%internal degrees of freedom for each node.
        option_list=Options('Init_psi',{'default','random'});
    end
    methods
        function obj=KerrNonlinearity(W,beta)
            obj.par.W=W;
            obj.par.beta=beta;
            %obj.eqn=@(x) (2*obj.phi+obj.M)*x*(-1i);
        end
        function init=get.initial(o)
            init=o.initial;
            %init.psi=rand()*0.01;
            init.psi=0.001;
        end
        function er=getlinear(o)                
                er= o.par.W;
        end
    end
    methods (Static)
        function y=calc(x,p)
            y=(p.W+p.beta.*abs(x).^2).*x./(1i);
        end
    end
end
        