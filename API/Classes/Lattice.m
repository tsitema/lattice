classdef (Abstract) Lattice <handle
    properties 
        nodes=Node.empty();
        par;%struct of lattice specific parameters, e.g. coupling strengths
    end
    methods
        %detach a node from a lattice and remove it.
        function obj=deleteNode(obj,node)
            %delete links
            links=[node.linklist];
            linknodes=[links.node];
            for i=1:length(linknodes)
                Node.detach(node,linknodes(i));
            end
            %delete nodes
            index=[obj.nodes.ID]==node.ID;
            obj.nodes(index).ID=0;
        end
    end
end