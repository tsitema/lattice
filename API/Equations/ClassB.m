classdef ClassB <Eqn
    properties 
        %parameters with default values
        par=struct('tph',1,'alpha',0,'sigma',1,'pump',0,'tr',100);
        fields=struct('E',[],'N',[]);
        initial=struct('E',0,'N',1);
        options;
        
        initE=0.001;%intensity of the initial random electric field
    end
    properties (Constant)
        DOF=2;%internal degrees of freedom for each node.
        option_list=Options('Init_E',{'default','random'},...
            'Init_N',{'default','steady'});
    end
    methods
        function o=ClassB(p)
            if nargin==1
                o.par=p;
            end
            o.options=o.option_list;
        end
        %linear part of the equation. It may be useful calculating the
        %spectrum
        function er=getlinear(o)                
                er= [-(1-1i*o.par.alpha)*(1/o.par.tph+o.par.sigma),     0 ...
                           ;                0,               o.par.pump-1/o.par.tr ];
        end
        function init=get.initial(o)
            init=o.initial;
            if strcmp(o.options.custom.Init_E,'random')
                init.E=o.initE*rand();
            end
            if strcmp(o.options.custom.Init_N,'steady')
                init.N=o.par.pump.*o.par.tr;
            end
        end
       end
    methods (Static)
        %every subclass of Eqn should have this static method for batch
        %calculation of nodes. is the vector that contains the fields,
        %each column is another field. p is the struct that contains the
        %arrays of parameters.
        function y=calc(x,p)
             E=x(:,1);
             N=x(:,2);
%             %calculate RHS of each field equation
             col1=(0.5.*((-1./p.tph)+p.sigma.*(N-1)).*(1i-p.alpha).*E).*(-1i);
             col2=p.pump-N./p.tr -2.*(N-1).*(abs(E).^2)./p.tr;
            %now, interleave the fields again.
            y=[col1,col2];
        end
        
    end
end