classdef LatticeInteractive < Lattice
    %% PROPERTIES
    properties
        %M=0;%detuning is a property of the internal dynamics
        options;%currently selected options
        primitiveVectors;
    end
    
    %% CONSTANTS
    properties (Constant)
        %named constants
        
        %default option object
        option_list=Options('Boundary',{'Open','Periodic'});
    end
    
    %% METHODS
    methods
        %% CONSTRUCTOR
        function o=LatticeInteractive()
            primitiveVectors=[0 0;0 0]
            %o.nodes=o.buildNodes();
        end
        %moves the lattice with offset x,y
        function getFiniteLattice()
            
        end
        function [vx,vy,vxy]=getOverlappingNodes(lattice)
                %overlap=Node.empty;
                px=lattice.primitiveVectors(1,:);
                py=lattice.primitiveVectors(2,:);
                x= [lattice.nodes.x];
                y= [lattice.nodes.y];
                xy= [x(:) y(:)];
                %calculate positions after translation by the primitive
                %vectors
                xy_shift_x=[(x(:)+px(1)) (y(:)+px(2))];
                xy_shift_y=[(x(:)+py(1)) (y(:)+py(2))];
                xy_shift_xy=[(x(:)+px(1)+py(1)) (y(:)+px(2)+py(2))];
                %this will return the overlap matrix
                check=@(v1,v2) v1(:,1)==v2(:,1)' & v1(:,2)==v2(:,2)';
                vx=check(xy,xy_shift_x);%overlaps after translation by px
                vy=check(xy,xy_shift_y);% after  py
                vxy=check(xy,xy_shift_xy);% after px + py
                %overlap=[vx,vy,vxy];
        end
        function nodes=getUnitCell(lattice)
            [v1,v2,v3]=getOverlappingNodes(lattice);
            %rows that do not overlap after the translation are in the unit
            %cell
            overlapped=sum(v1,2)|sum(v2,2)|sum(v3,2);
            unitcell=~overlapped;
            nodes=lattice.nodes(unitcell);
        end
    end
        %% SET METHODS
end