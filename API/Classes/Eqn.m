%this class defines the internal equation of a node, it does not define
%coupling
classdef (Abstract) Eqn 
    properties (Abstract, Constant)
         %degrees of freedom
         DOF;
    end
    properties (Abstract)
         par;%parameters is a struct of class specific parameters
         %fields is a struct with length=DOF. Fields has to be specified in
         %the same order  specified in the equation.
         fields;
    end
    methods (Static)
        %you give this function an array o Eqn objects, and it will
        %return you a struct that contains the arrays of parameters.
        %but all elements of the equation array should be in the same
        %class.
        %it can take equation array, node array or lattice as input
        function str=getParArray(eqnarr)
            if isa(eqnarr,'Eqn')==1
            elseif isa(eqnarr,'Node')==1
                eqnarr=[eqnarr.eqn];
            elseif isa(eqnarr,'Lattice')==1
                eqnarr=eqnarr.nodes(:);
                eqnarr=[eqnarr.eqn];
            else
                warning('Eqn.getpararray: input is not an Eqn, Node or Lattice')
            end
            eqnarr=eqnarr(:);%flatten
            props=[eqnarr.par];
            str=Misc.aos2soa(props);
        end
        %TODO: Consider moving these static methods to Solver class
        function init=getInit(eqnarr)
            if isa(eqnarr,'Eqn')==1
            elseif isa(eqnarr,'Node')==1
                eqnarr=[eqnarr.eqn];
            elseif isa(eqnarr,'Lattice')==1
                eqnarr=eqnarr.nodes(:);
                eqnarr=[eqnarr.eqn];
            else
                warning('Eqn.getinit: input is not an Eqn, Node or Lattice')
            end
            eqnarr=eqnarr(:);%flatten
        %TODO: If eqnarr is multi-equation DOF should be redefined          
            DOF=eqnarr(1).DOF;
            %return the init in 1 column per field format
            inits=[eqnarr.initial];
            fields=fieldnames(inits);
            for i=1:DOF
                init(:,i)= [inits.(fields{i})]';
            end
        end
        
    end
    methods (Static, Abstract)
       %  function y=calc(x,p)
    end
end
