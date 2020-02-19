classdef BHZ < Lattice
    %% PROPERTIES
    properties
        %nodes=Node.empty();
        options;%currently selected options
        eqn;%internal dynamics equation of orbitals
        nx;
        ny;
        JA=1;%coupling strength between orbitals a and b
        JB=1;%coupling strength between the same orbital type
        
    end
    %% CONSTANTS
    properties (Constant)
        %named constants
        a=1;%orbital A
        b=2;%orbital B
        leftedge=3;%label for the left edge. we will apply custom initial conditions on these
        %default option object
        option_list=Options('initialpulse',{'none','leftedge'}...
            ,'pulseintensity',0);
    end
    
    %% METHODS
    methods
        %% CONSTRUCTOR
        function o=BHZ(eqn,nx,ny,JA,JB,opt)
            if nargin>5
                o.options=opt;
            else %if not specified, default options
                o.options=o.option_list;
            end
            o.eqn=eqn;
            o.nx=nx;
            o.ny=ny;
            o.JA=JA;
            o.JB=JB;
            o.buildNodes();
            %o.initPosition();
        end
        
        function o=buildNodes(o)
            %Specific to BHZ
            %TODO: it is not flexible to do it this way. check if
            %self-linking works
            eqnb=o.eqn;
            eqnb.par.W=-eqnb.par.W;
            %Get constants
            A=o.a;
            B=o.b;
            NX=o.nx;
            NY=o.ny;
            %create nodes
            cnt=1;
            for yi=1:NY
                for xi=1:NX
                    o.nodes(xi,yi,A).type='a';
                    o.nodes(xi,yi,A).eqn=o.eqn;
                    o.nodes(xi,yi,A).ID=cnt;
                    o.nodes(xi,yi,B).type='b';
                    o.nodes(xi,yi,B).eqn=o.eqn;
                    o.nodes(xi,yi,B).ID=cnt+1;
                    cnt=cnt+2;
                end
            end
            %% LINKING THE NODES
            %To define the link between two nodes:
            %Node.attach(first node, second node, coupling strength)
            for yi=1:NY
                for xi=1:NX
                    %links between same orbital types
                    if xi<NX
                    Node.attach(o.nodes(xi,yi,A),o.nodes(xi+1,yi,A),o.JB);
                    Node.attach(o.nodes(xi,yi,B),o.nodes(xi+1,yi,B),-o.JB);
                    end
                    if yi<NY
                    Node.attach(o.nodes(xi,yi,A),o.nodes(xi,yi+1,A),o.JB);
                    Node.attach(o.nodes(xi,yi,B),o.nodes(xi,yi+1,B),-o.JB);
                    end
                    %links between different orbital types
                    if xi<NX
                    Node.attach(o.nodes(xi,yi,B),o.nodes(xi+1,yi,A),-o.JA);
                    Node.attach(o.nodes(xi,yi,A),o.nodes(xi+1,yi,B),o.JA);
                    end
                    if yi<NY
                    Node.attach(o.nodes(xi,yi,A),o.nodes(xi,yi+1,B),-1i*o.JA);
                    Node.attach(o.nodes(xi,yi,B),o.nodes(xi,yi+1,A),-1i*o.JA);
                    end
                end
            end
            %If initial pulse is defined, we modify the lattice
            if  strcmp(o.options.custom.initialpulse,'leftedge')
                for yi=1:NY
                    %turn off random initial conditions for this node
                    o.nodes(1,yi,A).eqn.options.custom.Init_psi='default';
                    o.nodes(1,yi,A).eqn.initial.psi=o.options.custom.pulseintensity;%assign the new value
                    o.nodes(1,yi,A).type='c';
                end
            end
            
            %% TODO the code below (init position and cleanup) must be called after building the lattice
            % otherwise plots do not work properly. Either fix plots or move this code to the Lattice
            % superclass.
            %% SET POSITION WE HAVE TO CALL THIS, AFTER ALL ATTACHED
            o.initPosition();
            %% CLEANUP NODES
            o.nodes=Node.sortNodes(o.nodes);
            o.nodes=Node.deleteEmpty(o.nodes);
            Node.renumber(o.nodes);
            o.nodes=o.nodes;
        end
        %I modified the static method from NNN.
        function o=initPosition(o)
            sz=size(o.nodes);
            for i=1:sz(1)
                for j=1:sz(2)
                    for k=1:sz(3)
                        %Give a little offset to b nodes
                        if strcmp(o.nodes(i,j,k).type,'b')
                            o.nodes(i,j,k).x=i+0.3;
                            o.nodes(i,j,k).y=j+0.3;
                        elseif strcmp(o.nodes(i,j,k).type,'a')
                            o.nodes(i,j,k).x=i;
                            o.nodes(i,j,k).y=j;
                        elseif strcmp(o.nodes(i,j,k).type,'c')
                            o.nodes(i,j,k).x=i;
                            o.nodes(i,j,k).y=j;
                        else
                            disp('unidentified node')
                        end
                    end
                end
            end
        end
    end
end