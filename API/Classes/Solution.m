classdef Solution
    properties
    %TODO: lattice here is a node array it could be more consistent if it
    %was a lattice object instead
    lattice;%lattice contains the node array 
    initial;%initial values
    fields;%calculated fields
    time;%corresponding time
    end
    methods
        function obj=Solution(lattice)
            if isa(lattice,'Node')==1
                obj.lattice=lattice;
            elseif isa(lattice,'Lattice')==1
                obj.lattice=lattice.nodes;
            end
            %obj.initial=getdefaultinit();
        end
    end
end