classdef NNN < Lattice
    %% PROPERTIES
    properties
        nx;
        ny;
        eqna;
        eqnb;
        J=1;%coupling strength
        phi=pi;
        %M=0;%detuning is a property of the internal dynamics
        nodes=Node.empty();
        options;%currently selected options
    end
    
    %% CONSTANTS
    properties (Constant)
        %named constants
        a=1;
        b=2;
        nab=2;
        %default option object
        option_list=Options('edges',{'default','baklava','b'},...
            'pump',{'default','edge'},...
            'BC',{'default','periodic1','periodic2'});
    end
    
    %% METHODS
    methods
        %% CONSTRUCTOR
        function o=NNN(eqna,eqnb,nx,ny,opt)
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
        %% SET METHODS
        function o=set.J(o,J)
            %I J is not the default value,
            %we have to rebuild the nodes.
            o.J=J;
            o.buildNodes;
        end
        %%
        
        function o=buildNodes(o)
            A=o.a;
            B=o.b;
            NX=o.nx;
            NY=o.ny;
            %N=nx*ny*o.nab;%total number of nodes
            Hab=o.J*exp(1i*o.phi/4)*csc(o.phi/2);
            Ha=o.J*csc(o.phi/2);
            o.nodes(NX,NY,o.nab)=Node();
            cnt=1;
            %create nodes
            for yi=1:NY
                for xi=1:NX
                    o.nodes(xi,yi,A).type='a';
                    o.nodes(xi,yi,A).eqn=o.eqna;
                    o.nodes(xi,yi,A).ID=cnt;
                    o.nodes(xi,yi,B).type='b';
                    o.nodes(xi,yi,B).eqn=o.eqnb;
                    o.nodes(xi,yi,B).ID=cnt+1;
                    cnt=cnt+2;
                end
            end
            %link nodes
            for yi=1:NY
                for xi=1:NX
                    if yi<NY
                        %a site interacts in a's y direction BL1
                        Node.attach(o.nodes(xi,yi,A),o.nodes(xi,yi+1,A),Ha);
                        %Hab 4th term
                        Node.attach(o.nodes(xi,yi+1,B),o.nodes(xi,yi,A),Hab);
                    end
                    if xi<(NX)
                        %b interaction in x direction
                        Node.attach(o.nodes(xi,yi,B),o.nodes(xi+1,yi,B),Ha);
                        %Hab 3rd term
                        Node.attach(o.nodes(xi+1,yi,B),o.nodes(xi,yi,A),Hab);
                    end
                    if xi<NX&&yi<NY
                        %Hab 2nd term
                        Node.attach(o.nodes(xi,yi,A),o.nodes(xi+1,yi+1,B),Hab);
                    end
                    %Hab 1st term
                    Node.attach(o.nodes(xi,yi,A),o.nodes(xi,yi,B),Hab);
                end
            end
            
            %% ******EDGES************************************************
            %here we add extra nodes to edges to make all edges b-type
            if strcmp(o.options.custom.edges,'b')
                %********b-type edge with open BC*****************************
                if strcmp(o.options.custom.BC,'default')
                    %corner node
                    o.nodes(NX+1,NY+1,B).type='b';
                    o.nodes(NX+1,NY+1,B).eqn=o.eqnb;
                    o.nodes(NX+1,NY+1,B).ID=cnt;
                    cnt=cnt+1;
                    for yi=1:NY
                        %add one last b to end of x diagonal
                        o.nodes(NX+1,yi,B).type='b';
                        o.nodes(NX+1,yi,B).eqn=o.eqnb;
                        o.nodes(NX+1,yi,B).ID=cnt;
                        cnt=cnt+1;
                        Node.attach(o.nodes(NX+1,yi,B),o.nodes(NX,yi,A),Hab);
                        Node.attach(o.nodes(NX,yi,B),o.nodes(NX+1,yi,B),Ha);
                        if yi<NY
                            Node.attach(o.nodes(NX,yi,A),o.nodes(NX+1,yi+1,B),Hab);
                        end
                    end
                    for xi=1:NX
                        o.nodes(xi,NY+1,B).type='b';
                        o.nodes(xi,NY+1,B).eqn=o.eqnb;
                        o.nodes(xi,NY+1,B).ID=cnt;
                        cnt=cnt+1;
                        Node.attach(o.nodes(xi,NY+1,B),o.nodes(xi+1,NY+1,B),Ha);
                        Node.attach(o.nodes(xi,NY+1,B),o.nodes(xi,NY,A),Ha);
                        Node.attach(o.nodes(xi+1,NY+1,B),o.nodes(xi,NY,A),Ha);
                    end
                elseif strcmp(o.options.custom.BC,'periodic1')
                    %********b-type edge with periodic BC*****************
                    for yi=1:NY
                        %add one last b to end of x diagonal
                        Node.attach(o.nodes(1,yi,B),o.nodes(NX,yi,A),Hab);
                        Node.attach(o.nodes(NX,yi,B),o.nodes(rem(xi,NX)+1,yi,B),Ha);
                        if yi<NY
                            Node.attach(o.nodes(NX,yi,A),o.nodes(1,yi+1,B),Hab);
                        end
                    end
                    for xi=1:NX
                        o.nodes(xi,NY+1,B).type='b';
                        o.nodes(xi,NY+1,B).eqn=o.eqnb;
                        o.nodes(xi,NY+1,B).ID=cnt;
                        cnt=cnt+1;
                        Node.attach(o.nodes(xi,NY+1,B),o.nodes(rem(xi,NX)+1,NY+1,B),Ha);
                        Node.attach(o.nodes(xi,NY+1,B),o.nodes(xi,NY,A),Ha);
                        if xi<NX
                            Node.attach(o.nodes(xi+1,NY+1,B),o.nodes(xi,NY,A),Ha);
                        end
                    end
                    
                elseif strcmp(o.options.custom.BC,'periodic2')
                    %********b-type edge with periodic BC*****************
                    for yi=1:NY
                        %add one last b to end of x diagonal
                        Node.attach(o.nodes(1,yi,B),o.nodes(NX,yi,A),Hab);
                        Node.attach(o.nodes(NX,yi,B),o.nodes(rem(xi,NX)+1,yi,B),Ha);
                        if yi<NY
                            Node.attach(o.nodes(NX,yi,A),o.nodes(1,yi+1,B),Hab);
                        end
                    end
                    for xi=1:NX
                        Node.attach(o.nodes(xi,1,B),o.nodes(rem(xi,NX)+1,1,B),Ha);
                        Node.attach(o.nodes(xi,1,B),o.nodes(xi,NY,A),Ha);
                        if xi<NX
                            Node.attach(o.nodes(xi+1,1,B),o.nodes(xi,NY,A),Ha);
                        end
                    end
                end
            elseif strcmp(o.options.custom.edges,'baklava')
                %delete some nodes
                for xi=1:NX
                    o.deleteNode(o.nodes(xi,1,B));
                end
                for yi=1:NY
                    o.deleteNode(o.nodes(NX,yi,A));
                end
            end
            %WE HAVE TO CALL THIS, AFTER ALL ATTACHED
            NNN.setPosition(o.nodes);
            %% ***********CUSTOM PUMP*************************************
            %pump only the edges
            if strcmp(o.options.custom.pump,'edge')...
                    &&strcmp(o.options.custom.edges,'baklava')
                for yi=1:NY
                    for xi=1:NX
                        if yi==NY||yi==1
                            o.nodes(xi,yi,A).type='c';
                            o.nodes(xi,yi,A).type='c';
                        else
                            o.nodes(xi,yi,A).eqn.par.pump=0;
                        end
                        if xi==NX||xi==1
                            o.nodes(xi,yi,B).type='c';
                            o.nodes(xi,yi,B).type='c';
                        else
                            o.nodes(xi,yi,B).eqn.par.pump=0;
                        end
                    end
                end
            end
            %IF SEMI_INFINITE AND EDGE PUMPED
            if strcmp(o.options.custom.pump,'edge')...
                    &&strcmp(o.options.custom.edges,'b')...
                    &&strcmp(o.options.custom.BC,'periodic1')
                for yi=1:NY+1
                    for xi=1:NX
                        if yi==NY+1||yi==1
                            o.nodes(xi,yi,B).type='c';
                            o.nodes(xi,yi,B).type='c';
                        else
                            o.nodes(xi,yi,B).eqn.par.pump=0;
                        end
                    end
                end
            end
            %IF B-type boundary AND EDGE PUMPED
            if strcmp(o.options.custom.pump,'edge')...
                    &&strcmp(o.options.custom.edges,'b')...
                    &&strcmp(o.options.custom.BC,'default')
                for yi=1:NY+1
                    for xi=1:NX+1
                        if yi==NY+1||yi==1
                            o.nodes(xi,yi,B).type='c';
                            o.nodes(xi,yi,B).type='c';
                        else
                            o.nodes(xi,yi,B).eqn.par.pump=0;
                        end
                        if xi==NX+1||xi==1
                            o.nodes(xi,yi,B).type='c';
                            o.nodes(xi,yi,B).type='c';
                        else
                            o.nodes(xi,yi,B).eqn.par.pump=0;
                        end
                    end
                end
            end
            %% CLEANUP NODES
            o.nodes=Node.sortNodes(o.nodes);
            o.nodes=Node.deleteEmpty(o.nodes);
            Node.renumber(o.nodes);
            o.nodes=o.nodes;
        end
    end
    %% STATIC METHODS
    methods (Static)
        %a function specific to NNN. maybe we can consider to make this
        %abstract.
        function setPosition(nodes)
            sz=size(nodes);
            for i=1:sz(1)
                for j=1:sz(2)
                    for k=1:sz(3)
                        if strcmp(nodes(i,j,k).type,'b')
                            nodes(i,j,k).x=i-0.5;
                            nodes(i,j,k).y=j-0.5;
                        else
                            nodes(i,j,k).x=i;
                            nodes(i,j,k).y=j;
                        end
                    end
                end
            end
        end
    end
end