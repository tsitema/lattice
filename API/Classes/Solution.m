classdef Solution
    properties
    lattice;%lattice contains the node array
    initial;%initial values
    fields;%calculated fields
    time;%corresponding time
    end
    methods
        function obj=Solution(lattice)
            obj.lattice=lattice;
            %obj.initial=getdefaultinit();
        end
    end
end