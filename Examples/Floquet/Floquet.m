classdef Floquet < Lattice
    %% PROPERTIES
    properties
        %M=0;%detuning is a property of the internal dynamics
        %nodes=Node.empty();
        options;%currently selected options
        nx;
        ny;
        kx;
        ky;
        J=1;
        eqn;
        init;
        type;
        prtrnd=0.1;%random perturbation intensity
        %prt=0.00;%constant perturbation intensity
        %prtPhase=0;%constant perturbation phase
        %phi=0;
        season=4;%4 seasons of floquet
    end
    
    %% CONSTANTS
    properties (Constant)
        %named constants        
        a=1;%node A
        b=2;%node B
        c=3;%node C
        %default option object
        option_list=Options();
    end
    
    %% METHODS
    methods
        %% CONSTRUCTOR
        function o=Floquet(n,g,k,J,init,season,type)
            o.eqn=KerrNonlinearity(0,g);
            if length(n)==1
                o.nx=n;
                o.ny=n;
            else
                o.nx=n(1);
                o.ny=n(2);
            end
            o.init=init;
            o.kx=k(1);            
            o.ky=k(2);
            o.J=J;
            o.season=season;
            o.type=type;
            o.options=o.option_list;        
            o.buildNodes();
            %o.nodes=o.buildNodes();
        end
        
       function o=buildNodes(o)
            o.nodes=Node();
            
            if strcmp(o.type,'strip')
                NX=2;
                NY=o.ny;
            else                
                NX=o.nx;
                NY=o.ny;
            end
            %create nodes
            cnt=1;
            for yi=1:NY
                for xi=1:NX
                    if rem(xi+yi,2)==0
                    o.nodes(xi,yi).type='a'; 
                    else
                    o.nodes(xi,yi).type='b'; 
                    end
                    o.nodes(xi,yi).eqn=o.eqn;
                    o.nodes(xi,yi).ID=cnt;
                    cnt=cnt+1;
                end
            end
             %% LINKING THE NODES
           %To define the link between two nodes:
           %Node.attach(first node, second node, coupling strength)
           for xi=1:NX
               for yi=1:NY
                   switch o.season
                       case 1
                           if o.nodes(xi,yi).type=='b' && xi~=NX
                              Node.attach(o.nodes(xi,yi),o.nodes(xi+1,yi),o.J);
                           elseif o.nodes(xi,yi).type=='b'  && xi==NX  && strcmp(o.type,'strip')
                              Node.attach(o.nodes(xi,yi),o.nodes(1,yi),o.J.*exp(1i*o.kx));
                           end
                       case 2                           
                           if o.nodes(xi,yi).type=='a' && yi~=NY
                              Node.attach(o.nodes(xi,yi),o.nodes(xi,yi+1),o.J);
                           end
                       case 3                           
                           if o.nodes(xi,yi).type=='a' && xi~=NX
                              Node.attach(o.nodes(xi,yi),o.nodes(xi+1,yi),o.J);
                           elseif o.nodes(xi,yi).type=='a' && xi==NX  && strcmp(o.type,'strip')                            
                              Node.attach(o.nodes(xi,yi),o.nodes(1,yi),o.J.*exp(1i*o.kx));
                           end
                       case 4
                           if o.nodes(xi,yi).type=='b' && yi~=NY
                              Node.attach(o.nodes(xi,yi),o.nodes(xi,yi+1),o.J);
                           end
                       otherwise
                          warning('Wrong floquet season'); 
                   end
                   %SET INITIAL RANDOM PERTURBATION
                    o.nodes(xi,yi).eqn.initial.psi=o.prtrnd.*(2*rand()-1).*exp(2i*pi*rand());
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
            for x=1:sz(1)
                    for y=1:sz(2)
                            o.nodes(x,y).x=x;                               
                            o.nodes(x,y).y=y;
                    end
            end
        end
        %% SET METHODS
         function set.init(o,init)
             if length(init)==1
                o.init=init;
             elseif length(init)==length(o.nodes)
                 for ii=1:length(o.nodes)
                    o.nodes(ii).eqn.initial.psi=init(ii);
                 end
             else
                 warning('Wrong initial state size');
             end
         end
    end
end