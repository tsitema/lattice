classdef Networkname < Lattice
    %% PROPERTIES
    properties
        %M=0;%detuning is a property of the internal dynamics
        nodes=Node.empty();
        options;%currently selected options
    end
    
    %% CONSTANTS
    properties (Constant)
        %named constants
        
        %default option object
        option_list=Options();
    end
    
    %% METHODS
    methods
        %% CONSTRUCTOR
        function o=Networkname()
            if nargin==5
                o.options=opt;
                o.eqna=eqna;
                o.eqnb=eqnb;
                o.nx=nx;
                o.ny=ny;
            else %if not specified, default options
                o.options=o.option_list;
            end
            %o.nodes=o.buildNodes();
        end
        %% SET METHODS
end