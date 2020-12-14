%this is a special class that I define for the ode solver. Hopefully, it
%will be faster than using an anonymous function to pass parameters.
classdef NLfunct
    properties
        props;%struct of property arrays
        link;%adjacency matrix
        eqn;%eqn class
        DOF;%DOF of eqn 
        N;%number of nods
        input_i;
        input;
        output_i;
        output;
    end
    methods
        %props is a struct that contains array of properties specific to 
        function obj=NLfunct(props,link,eqn,input,output)
            if nargin>2
                obj.props=props;
                obj.link=link;
                obj.eqn=eqn;
                obj.DOF=eqn.DOF;
                obj.N=length(link);
            elseif nargin>3
                obj.input=input;
                obj.output=output;
            end
            %obj.input=
        end
        function fy=y(o,~,x)
            %link*y(:,1), blank] + eq.calc(y,props) ode function converts
            %the vectors in single-column format. We convert it back to
            %one-column-per-field format.
            x=reshape(x,[o.N,o.DOF]);
            %calculate the internal dynamics
            fy=o.eqn.calc(x,o.props);
            %*****LINK********************
            %link only the first field.
            fy(:,1)=fy(:,1)-(1i).*o.link*x(:,1);            
            fy=fy(:);
        end
    end
end