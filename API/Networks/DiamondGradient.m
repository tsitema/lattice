classdef DiamondGradient < Lattice
    %% PROPERTIES
    properties
        %M=0;%detuning is a property of the internal dynamics
        %nodes=Node.empty();
        options;%currently selected options
        nx;
        phi;
        k;
        eqn;
        init;
        prtrnd=0.00;%random perturbation intensity
        prt=0.00;%constant perturbation intensity
        prtPhase=0;%constant perturbation phase
        
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
        function o=DiamondGradient(n,phi,g,k,init)
            o.eqn=KerrNonlinearity(0,g);
            o.nx=n;
            o.phi=phi;
            o.init=init;
            o.k=k;
            o.options=o.option_list;        
            o.buildNodes();
            %o.nodes=o.buildNodes();
        end
        
       function o=buildNodes(o)
            o.nodes=Node();
            %Specific to BHZ
            %TODO: it is not flexible to do it this way. check if
            %self-linking works
            J=-exp(1i.*o.phi);
            %Get constants
            A=o.a;
            B=o.b;
            C=o.c;
            NX=o.nx;
            %create nodes
            cnt=1;
            for xi=1:NX
                o.nodes(xi,A).type='a';
                o.nodes(xi,A).eqn=o.eqn;
                o.nodes(xi,A).ID=cnt;
                o.nodes(xi,B).type='b';
                o.nodes(xi,B).eqn=o.eqn;
                o.nodes(xi,B).ID=cnt+1;
                o.nodes(xi,C).type='c';
                o.nodes(xi,C).eqn=o.eqn;
                o.nodes(xi,C).ID=cnt+2;
                cnt=cnt+3;
            end
            %% LINKING THE NODES
            %To define the link between two nodes:
            %Node.attach(first node, second node, coupling strength)
            for xi=1:NX
                Node.attach(o.nodes(xi,A),o.nodes(xi,B),J);
                Node.attach(o.nodes(xi,B),o.nodes(xi,C),J);
            %
            %% *!!! SET PERIODIC VS OPEN BC HERE* 
              if xi<NX%NX for open NX+1 for Per
                Node.attach(o.nodes(xi,B),o.nodes(mod(xi,NX)+1,A),-1);
                Node.attach(o.nodes(xi,B),o.nodes(mod(xi,NX)+1,C),-1);
              end
            end
            %set initial condition  \
%             if length(o.init)==3
%                 for xi=1:NX
%                     o.nodes(xi,A).eqn.initial.psi=o.init(1).*exp(1i.*(xi-1).*o.k)...
%                                                     +o.prtrnd.*rand().*exp(2i*pi*rand())+o.prt.*exp(1i*o.prtPhase)%;.*(xi<30)*(xi>10);
%                     o.nodes(xi,B).eqn.initial.psi=o.init(2).*exp(1i.*(xi-1).*o.k)...
%                                                     +o.prtrnd.*rand().*exp(2i*pi*rand())+o.prt.*exp(1i*o.prtPhase)%;.*(xi<30)*(xi>10);
%                     o.nodes(xi,C).eqn.initial.psi=o.init(3).*exp(1i.*(xi-1).*o.k)...
%                                                     +o.prtrnd.*rand().*exp(2i*pi*rand())+o.prt.*exp(1i*o.prtPhase)%;.*(xi<30)*(xi>10);
%                 end
%             elseif length(o.init)==3*NX
%                 for xi=1:NX
%                     o.nodes(xi,A).eqn.initial.psi=o.init(3*xi-2);
%                     o.nodes(xi,B).eqn.initial.psi=o.init(3*xi-1);
%                     o.nodes(xi,C).eqn.initial.psi=o.init(3*xi);
%                 end 
%             else
%                     warning('initial value of diamond chain is wrong');
%             end
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
                    for m=1:sz(2)
                        %Give a little offset to b nodes
                        if strcmp(o.nodes(i,m).type,'b')
                            o.nodes(i,m).x=i;                               
                            o.nodes(i,m).y=0;
                        elseif strcmp(o.nodes(i,m).type,'a')
                            o.nodes(i,m).x=i-0.5;                                                        
                            o.nodes(i,m).y=1;
                        elseif strcmp(o.nodes(i,m).type,'c')
                            o.nodes(i,m).x=i-0.5;                                                        
                            o.nodes(i,m).y=-1;
                        else
                            disp('unidentified node')
                        end                     
                        %o.nodes(i,j,k).x=o.nodes(i,j,k).x+rand()*0.1;
                        %o.nodes(i,j,k).y=o.nodes(i,j,k).y+rand()*0.1;
                    end
            end
        end
        %% SET METHODS
        function set.prtPhase(o,val)
            o.prtPhase=val;
            o.buildNodes();
        end
    end
end