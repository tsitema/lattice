classdef Link 
    properties
    node% the node the link is pointing.
    str%Link/coupling strength, hopping constant
    isConjugate=false;%=1 to mark as the conjugate link
    end
    methods
        %str can be a matrix or scalar. If scalar,only the first field is
        %connected
        function obj=Link(node, str)
            obj.node=node;
            obj.str=str;
            
            %node should be two-element Node array.NO
            %if str is a single number, then the link is hermitian
            %if str is a two element number array, then the link is
            %not neccessarily hermitian
            %if str is a string, then it is a symbolic hermitian
            %if str is two strings, then it is symbolic-non hermitian
            
            %Problems: 
            %how do we know the directionality?
            %we add the same pointer to two nodes, so link from 1-2 is str
            %link from 2-1 is conj(str).
            %but if i want to return the value of the link strengths, how
            %do i know which one user wants?
            %maybe i just have to change the behhaviour of str
            
            %Solution
            %We do not care about the type here.
            %str can be many things, maybe we can just add a validity check
            %its the responsibility of the Solver methods or whatever to
            %handle the conjugates
            %strength just shows the forward hopping rate, you have to
            %calculate the backward hopping yourself when building the
            %adjacency matrix or hamiltonian.
            %we also do not need to specify two nodes. If the str is
            %symbolic and hermitian, then conjugate link will be added by
            %just by isConjugate flag.
         end
%         function str=set.str(o,str)
%             o.str=str;
%         end
    end
end