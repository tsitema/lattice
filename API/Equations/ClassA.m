classdef ClassA <Eqn
    properties 
        eqn;
    end
    %parameters are read-only and should be set in construction
    properties (SetAccess=public)
        loss;
        alpha;
    end
    properties (Constant)
        DOF=1;%internal degrees of freedom for each node.
    end
    methods
        function obj=ClassA(loss,alpha)
            if nargin==2
                obj.loss=loss;
                obj.alpha=alpha;
            elseif nargin==1
                obj.loss=loss;
                obj.alpha=0;
            elseif nargin ==0
                obj.loss=0;
                obj.alpha=0;
            end
                obj.eqn=@(x) -(1-1i*obj.alpha)*obj.loss*x;
        end
        function obj= set.loss(obj,loss)
            obj.loss=loss;
        end
    end
end