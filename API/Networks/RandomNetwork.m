classdef RandomNetwork < Lattice
    %% PROPERTIES
    properties
        %M=0;%detuning is a property of the internal dynamics
        size;%network size
        maxlink;%maximum number of link per node
        maxJ=1;%max coupling constant
        %nodes=Node.empty();
        options;%currently selected options
        eqn;
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
        function o=RandomNetwork(size,maxlink,eqn)
            o.size=size;
            o.maxlink=maxlink;
            o.eqn=eqn;
            o.buildNodes();
        end
        
        function o=buildNodes(o)
            %requirements
            %1-every node should have at least 1 connection
            %2-no grouping
            %3-every node should have at most <maxlink> connection
            %create nodes
            for xi=1:o.size
                o.nodes(xi).eqn=o.eqn;
                o.nodes(xi).ID=xi;
            end
            %link nodes
            %start with a line
            for xi=1:o.size-1
                Node.attach(o.nodes(xi),o.nodes(xi+1),rand().*o.maxJ);
            end
            %increase connections
            for xi=1:o.size
                %number of links for this node
                nlink=randi(o.maxlink);
                %current number of nodes for this node
                cn=length(o.nodes(xi).linklist);
                %so we have to add nlink-cn links
                nodestoadd=nlink-cn;
                if nodestoadd>0
                    sn=xi+nlink-cn;%selected node
                    for xj=xi+1:sn
                        if xj<=o.size
                            Node.attach(o.nodes(xi),o.nodes(xj),rand().*o.maxJ);
                        end
                    end
                end
            end
            %check requirements and fix
        end
        function o=randomize(o,parameter,range)
            if nargin==1
                range=1;
            end
            for i=1:o.size
                o.nodes(i).eqn.par.(parameter)=rand(range);
            end
        end
        
    end
        %% SET METHODS
end