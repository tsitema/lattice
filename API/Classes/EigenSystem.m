%This is like a container for nodes and the eigensystem
classdef EigenSystem
    properties
        nodes;
        values;
        vectors;
    end
    methods
        function obj=EigenSystem(nodes,values,vectors)
            obj.nodes=nodes;
            obj.values=values;
            obj.vectors=vectors;
        end
    end
end