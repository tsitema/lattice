classdef KerrNonlinearity <Eqn
    properties 
        %W: energy beta: nonlinearity constant
        par=struct('W',0,'beta',0);
        fields=struct('psi',0);
        initial=struct('psi',0);
        random_intensity=1e-3;%intensity of the initial random field
        options;
    end
    properties (Constant)
        DOF=1;%internal degrees of freedom for each node.
        option_list=Options('Init_psi',{'default','random'}); %WHAT IT MEANS DEFOLT? DOES IT MEAN EQUAL AMPLITUDES? HOW IT WOULD BE FOR PLANE WAVE?
    end
    methods
        function o=KerrNonlinearity(W,beta)
            if nargin==2
            o.par.W=W;
            o.par.beta=beta;
            end
            o.options=o.option_list;
        end
        function init=get.initial(o)
            init=o.initial;
            if strcmp(o.options.custom.Init_psi,'random')
            init.psi=1+rand()*o.random_intensity;  
            end
        end
    end
    methods (Static)
        function y=calc(x,p)
           y=(p.W+p.beta.*abs(x).^2).*x./(1i);  %cubic
           
           %y=(p.W+p.beta.*abs(x).^2 ./(1+abs(x).^2)).*x./(1i); % SATURABLE
        end
        function er=getlinear(par)                
                er= par.W;
        end
    end
end
        