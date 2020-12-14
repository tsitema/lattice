%ClassB laser equations with detuning, M
classdef ClassA <Eqn
    properties 
        %parameters with default values
        par=struct('loss',1,'pump',0,'M',0);
        fields=struct('E',[]);
        initial=struct('E',0);
        options;
        input;%function handle for input
        output;%function handle for input
        initE=1e-3;%intensity of the initial random electric field
    end
    properties (Constant)
        DOF=1;%internal degrees of freedom for each node.
        option_list=Options('Init_E',{'default','random'});
    end
    methods
        function o=ClassA(p)
            if nargin==1
                o.par=p;
            end
            o.options=o.option_list;
        end
        %linear part of the equation. It may be useful calculating the
%         %spectrum
%         function er=getlinear(o)                
%                 er= (1-1i.*o.par.alpha).*o.par.pump-o.par.loss-1i.*o.par.M;
%         end
        function init=get.initial(o)
            init=o.initial;
            if strcmp(o.options.custom.Init_E,'random')
                init.E=o.initE*rand();
            end
            init.E=o.initE*rand();
        end
       end
    methods (Static)
        %every subclass of Eqn should have this static method for batch
        %calculation of nodes. is the vector that contains the fields,
        %each column is another field. p is the struct that contains the
        %arrays of parameters.
        function y=calc(x,p)
            E=x(:,1);
            %From Longhi mitigation of dynamical...
            y=(-p.loss -1i.*p.M +p.pump -(p.pump.*abs(E).^2)./(1+abs(E).^2)).*E./(1i) ;
        end
        function er=getlinear(par)                
                er= par.pump-par.loss-1i.*par.M;
        end
    end
end