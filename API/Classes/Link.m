classdef Link
    properties
    node
    str
    end
    methods
        function obj=Link(node, str)
            obj.node=node;
            obj.str=str;
        end
    end
end