classdef Link
    properties
    node
    str
    end
    methods
        %str can be a matrix or scalar. If scalar,only the first field is
        %connected
        function obj=Link(node, str)
            obj.node=node;
            obj.str=str;
        end
    end
end