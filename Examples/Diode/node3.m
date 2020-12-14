classdef node3 < Lattice
    %% PROPERTIES
    properties
        %M=0;%detuning is a property of the internal dynamics
        %nodes=Node.empty();
        options;%currently selected options
        ext=1;%external coupling constant
        eqn;
        init;
        prtrnd=0.1;%random perturbation intensity
        %prt=0.00;%constant perturbation intensity
        %prtPhase=0;%constant perturbation phase
        %phi=0;
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
        function o=node3(par)
            o.par=par;
            o.eqn=ClassBdetuning();
            o.eqn.par.alpha=3;
            o.eqn.par.tr=100;
            o.options=o.option_list;        
            o.buildNodes();
            %o.nodes=o.buildNodes();
        end
        
       function o=buildNodes(o)
            o.nodes=Node();
            %create nodes
            for yi=1:3
                    o.nodes(yi).type='a'; 
                    o.nodes(yi).eqn=o.eqn;
                    o.nodes(yi).ID=yi;
            end
            Node.attach(o.nodes(1),o.nodes(2),o.par.J1);
            
            Node.attach(o.nodes(2),o.nodes(3),o.par.J2);
            
            
            Node.attach(o.nodes(1),o.nodes(3),o.par.J3);
            %add input to the 1st node
            o.nodes(1).eqn.par.ext=1;%External coupling constant
            o.nodes(1).eqn.par.input=2;
            %outout to the last node
            o.nodes(3).eqn.par.ext=2;
            %detuning
            o.nodes(2).eqn.par.M=o.par.M1;
            o.nodes(3).eqn.par.M=o.par.M2;
            %pump            
            o.nodes(2).eqn.par.pump=o.par.pump1;
            o.nodes(3).eqn.par.pump=o.par.pump2;
            %loss            
            o.nodes(2).eqn.par.loss=o.par.loss1;
            o.nodes(2).eqn.par.loss=o.par.loss2;
            o.nodes(3).eqn.par.loss=o.par.loss3;
            %
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
            for i=1:sz(2)
                  o.nodes(i).x=i;                               
                  o.nodes(i).y=0;
            end
            o.nodes(2).y=1;
        end
        %% SET METHODS
        
        function forward(o,bias)            
            o.nodes(1).eqn.par.input=bias;            
            o.nodes(3).eqn.par.input=0;
        end
        function reverse(o,bias)            
            o.nodes(1).eqn.par.input=0;            
            o.nodes(3).eqn.par.input=bias;
        end
        function off(o)            
            o.nodes(1).eqn.par.input=0;            
            o.nodes(3).eqn.par.input=0;
        end
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