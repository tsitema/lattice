classdef Node <  matlab.mixin.Copyable
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
        function [link1,link2]=attach(node1,node2,str)
            %we handle the behaviour of the link here.
            %str can be a number, or a string, 
            
            %links two nodes, str should be the coupling strength from
            %node1 to node2, conjugate is calculated
            if isnumeric(str)
                link1=Link(node2,str);
                link2=Link(node1,conj(str));%conjugate
                link2.isConjugate=true;%mark the conjugate flag
                node1.link(link1);
                node2.link(link2);%conjugate
            elseif isstring(str)||ischar(str)
                link1=Link(node2,str);
                link2=Link(node1,str);%conjugate
                link2.isConjugate=true;%mark the conjugate flag
                link1.isConjugate=false;
                node1.link(link1);
                node2.link(link2);%conjugate
            else
                warning('Invalid coupling strength, has to be a number or string');
            end                
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
        function nodes=cleanup(nodes)
            nodes=Node.deleteEmpty(nodes);
            nodes=Node.renumber(nodes);
        end
        %detach the given node and mark ID=0 so you can remove it from
        %your list
        function deleteNodes(nodes)
            nodes=nodes(:);
            for i=1:length(nodes)
                snode=nodes(i);
                length(snode.linklist)
                for j=1:length(snode.linklist)
                    slink=snode.linklist(1);
                    Node.detach(snode,slink.node);
                end
                snode.ID=0;
            end
        end
        %returns true if two nodes are linked
        function result=islinked(node1,node2)
            result=false;
            for i=1:length(node1.linklist)
                slink=node1.linklist(i);
                if slink.node.ID==node2.ID
                    result= true;
                    return
                end
            end
            %double check for asymmetric links
            for i=1:length(node2.linklist)
                slink=node2.linklist(i);
                if slink.node.ID==node1.ID
                    result= true;
                    disp('Found asymmetric links');
                    return
                end
            end
        end
        function lattice=move(lattice,x,y)
            if isa(lattice,'Node')==1
                nodes=lattice(:);%flatten
            elseif isa(lattice,'Lattice')==1
                nodes=lattice.nodes(:);
            else
                warning('calctime: not a Node or Lattice')
            end
            for i=1:length(nodes)
                snode=nodes(i);
                snode.x=snode.x+x;
                snode.y=snode.y+y;
            end
        end
        function newnodes=duplicateNodes(nodes)
            newnodes=copy(nodes);
            %fix the link references of the nodes
            IDs=[newnodes.ID];
            for i=1:length(newnodes)
                snode=newnodes(i);
                for j=1:length(snode.linklist)
                    slink=snode.linklist(j);
                    index=[IDs==slink.node.ID]; 
                    snode.linklist(j).node=newnodes(index);
                end
            end
            nodes=newnodes;
        end
     end
    methods(Access = protected)
      % Override copyElement method:
%       function cpObj = copyElement(obj)
%          % Make a shallow copy of all four properties
%          cpObj = copyElement@matlab.mixin.Copyable(obj);
%          % Make a deep copy of the DeepCp object
%          try
%             cpObj.linklist = copy(obj.linklist);
%          catch
%             %empty link list
%          end
%       end
   end
end