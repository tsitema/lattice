classdef Node <handle
    properties
        ID;% node IDs also supposed to determine the position in hamiltonian 
        %ID=0 means inactive/deleted node.
        linklist;%=struct('conn',Node.empty(),'str',0);%0 ID means unconnected
        eqn;
        x;%visual position of the node
        y;
        type;
    end
    methods
%         function obj=Node(ID,eqn)
%             obj.ID=ID;
%             obj.eqn=eqn;
%         end
        function obj=Node(ID)
            if nargin==0
            obj.ID=0;
            else
                obj.ID=ID;
            end
        end
        % multiple links between two nodes are possible?
        function obj = link(obj,linkobj)
            %remove the unconnected status
            obj.linklist=[obj.linklist linkobj];
        end
        function obj =unlink(obj,node_to_detach)
            deleteID=node_to_detach.ID;
            nodes=[obj.linklist.node];
            keepindex=[nodes.ID]~=deleteID;
            if keepindex==0
                obj.linklist=[];
            else
                obj.linklist=obj.linklist(keepindex);
            end
        end
    end
    
    methods (Static)
        function N=calcN(nodes)
            %calculates the total degrees of freedom of the given node
            %array
            N=0;
            for i=1:length(nodes(:))
                N=N+nodes(i).eqn.DOF;
            end
        end
        function attach(node1,node2,str)
            %links two nodes, str should be the coupling strength from
            %node1 to node2, conjugate is calculated
            link1=Link(node2,str);
            link2=Link(node1,conj(str));%conjugate
            node1.link(link1);
            node2.link(link2);%conjugate
        end
        function detach(node1, node2)
            node1.unlink(node2);
            node2.unlink(node1);
           %node1.unlink(linktodelete);
        end
        function cleaned=deleteEmpty(nodes)
            good_ones=[nodes(:).ID]~=0;
            cleaned=nodes(good_ones);
        end
        function sorted=sortNodes(nodes)
            nodes=nodes(:);
            [~,idx] = sort([nodes.ID]);
            sorted=nodes(idx);
        end
        function nodes=renumber(nodes)
            nodes=nodes(:);
            for i=1:length(nodes)
                nodes(i).ID=i;
            end
        end
    end
end