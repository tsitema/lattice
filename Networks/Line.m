classdef Line < Lattice
    properties
        nodes;
        n;
        eqna;
        eqnb;
    end
    methods
        %% CONSTRUCTOR
        function o=Line(eqna,eqnb,nx,ny,opt)
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
    end
end