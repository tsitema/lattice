%static methods for calculations.
classdef Solver
    methods (Static)
       %calculates the linear hamilltonian
        function H=calch(nodes)
            %this function calculates the linear Hamiltonian, it takes an array of
            %nodes.
            nodes=nodes(:);%flatten
            %***!!!!!!!DIVIDED BY 2**********/////////
            N=Node.calcN(nodes)/2;
            H=sparse(N,N);
            %state=ones(length(allnodes(:))*eqn.DOF,1);%state vector
            %go through all nodes
            for i=1:length(nodes)
                snode=nodes(i);%selected node
                sDOF=snode.eqn.DOF;%DOF of selected node
                %*******OVERRIDE DOF**********************
                sDOF=1;
                %*******OVERRIDE DOF**********************
                di=(1:sDOF)+(i-1)*sDOF;%related region of the node in Hamiltonian
                %set the diagonal terms
                H(di,di)=snode.eqn.getlinear;
                %Now, the links. 
                for j=1:length(snode.linklist)
                    slink=snode.linklist(j);%selected connected link
                    sID=slink.node.ID;%ID of the connected node
                    hrow=(sDOF*(snode.ID-1)+1);%row is ID of the 1st
                    hcol=(sDOF*(sID-1)+1);%column of the connected
                    if sID>0 %check for unlinked
                        H(hrow,hcol)=1i.*slink.str;
                    end
                end
            end
        end
       %calculates the link matrix. similar to the linear hamiltonian,
       %except it only contains the link elements.
        function H=calclinks(nodes)
            %this function calculates the linear Hamiltonian, it needs the array of
            %nodes.
            nodes=nodes(:);%flatten
            N=Node.calcN(nodes);
            H=sparse(N,N);
            %state=ones(length(allnodes(:))*eqn.DOF,1);%state vector
            %go through all nodes
            for i=1:length(nodes)
                snode=nodes(i);%selected node
                sDOF=snode.eqn.DOF;%DOF of selected node
                di=(1:sDOF)+(i-1)*sDOF;%related region of the node in Hamiltonian
                %Now, the links. We assume links only for the first internal 
                %equation, i.e. the electric field
                for j=1:length(snode.linklist)
                    slink=snode.linklist(j);%selected connected link
                    nfield=length(slink.str);%number of fields connected
                    sID=slink.node.ID;%ID of the connected node
                    hrow=(sDOF*(snode.ID-1)+1);%row is ID of the 1st
                    hcol=(sDOF*(sID-1)+1);%column of the connected
                    if sID>0 %check for unlinked
                        H(hrow,hcol)=slink.str;
                    end
                end
            end
        end
       %calculates the adjacency matrix
       function A=calcadj(nodes)
            if isa(nodes,'Node')==1
                nodes=nodes(:);%flatten
            elseif isa(nodes,'Lattice')==1
                par=nodes.par;
                nodes=nodes.nodes(:);
            else
                warning('calceig: not a Node or Lattice')
            end
            nodes=nodes(:);%flatten
            N=length(nodes);
            A=sparse(N,N);
            for i=1:length(nodes)
                snode=nodes(i);%selected node
                for j=1:length(snode.linklist)
                    slink=snode.linklist(j);%selected connected link
                    sID=slink.node.ID;%ID of the connected node
                    hrow=snode.ID;%row is ID of the 1st
                    hcol=sID;%column of the connected
                    if sID>0 %check for unlinked
                        if isnumeric(slink.str)
                            %TODO: fix the warning here
                            A(hrow,hcol)=slink.str;
                        else
                            %if str is a symbol, it is stored in the
                            %lattice.par
                            if exist('par','var')
                                if isfield(par,slink.str)
                                    A(hrow,hcol)=par.slink.str;
                                else
                                    error(strcat('No such parameter: ',slink.(str)));
                                end
                            else
                                error('Lattice object has no parameters');
                            end
                        end
                    end
                end
            end
        end
        
        %Give me a lattice or array of nodes, i will give you the
        %EigenSystem. EigenSystem is a container class that contains
        %nodes, eigenvalues and eigenvectors
        function esystem=calceig(nodes)
            if isa(nodes,'Node')==1
                nodes=nodes(:);%flatten
            elseif isa(nodes,'Lattice')==1
                nodes=nodes.nodes(:);
            else
                warning('calceig: not a Node or Lattice')
            end
            A=Solver.calch(nodes);
            A=full(A);
            [vectors,values]=eig(A);
            values=diag(values);
            esystem=EigenSystem(nodes,values,vectors);
        end
        
        %Calculates the time evolution of the fields.
        %For now, we assume all nodes are the same class.
        function sln=calctime(nodes,timelimit)
%             if isa(nodes,'Node')==1
%                 nodes=nodes(:);%flatten
%             elseif isa(nodes,'Lattice')==1
%                 nodes=nodes.nodes(:);
%             else
%                 warning('calctime: not a Node or Lattice')
%             end
            props=Eqn.getParArray(nodes);
            %initial state
            %TODO: MAKE IT CLASS INDEPENDENT
            if isa(nodes,'Node')==1
                eq=nodes(1).eqn;
            elseif isa(nodes,'Lattice')==1
                n1=nodes.nodes(1);
                eq=n1.eqn;
            end
            %initial values. each column is another field
            init=Eqn.getInit(nodes);
            link=Solver.calcadj(nodes);
            nlfunct=NLfunct(props,link,eq);
            %assuming the link is only for the first field!
            [t,y] = ode45(@nlfunct.y, [0 timelimit],init);
            %now form the Solution object and return it.
            y=reshape(y,[],nlfunct.N,nlfunct.DOF);
            sln=Solution(nodes);
            sln.initial=init;
            sln.fields=y;
            sln.time=t;
        end
        %evaluate ode system, but with small chunks, and save to disc
        function sln=calctime2(nodes,timelimit)
            timestep=10;
            interp_step=0.1;
            if isa(nodes,'Node')==1
                nodes=nodes(:);%flatten
            elseif isa(nodes,'Lattice')==1
                nodes=nodes.nodes(:);
            else
                warning('calctime: not a Node or Lattice')
            end
            props=Eqn.getParArray(nodes);
            %initial state-
            %TODO: MAKE IT CLASS INDEPENDENT
            eq=nodes(1).eqn;
            %initial values each column is another field
            init=Eqn.getInit(nodes);
            link=Solver.calcadj(nodes);
            nlfunct=NLfunct(props,link,eq);
            %open a temporary file to store solutions
            %assuming the link is only for the first field!
            %calculate the 1st step
            current_t=0;
            [t,y] = ode113(@nlfunct.y, [current_t current_t+timestep],init);
            current_t=timestep;
            %interpolate field
            ti=(t(1):interp_step:t(end))';
            yi=(interp1(t,y,ti));
            %save to file
            filename='temp.mat';
            datafile=matfile(filename,'Writable',true);
            save(filename,'ti','-v7.3');
            save(filename,'yi','-append');
            while current_t<=timelimit
                init=reshape(y(end,:),nlfunct.N,nlfunct.DOF);
                [t,y] = ode113(@nlfunct.y, [current_t current_t+timestep],init);
                %interpolate field
                ti=(t(1):interp_step:t(end))';
                yi=interp1(t,y,ti);
                %append to file
                [nt,~]=size(datafile,'ti');
                datafile.ti(nt+1:nt+length(ti)-1,1)=ti(2:end);
                datafile.yi(nt+1:nt+length(ti)-1,:)=yi(2:end,:);
                %fprintf('time: %d, min step: %2.2d\n',current_t,min(diff(t)));
                current_t=current_t+timestep;
            end
            %now form the Solution object and return it.
            y=reshape(y,[],nlfunct.N,nlfunct.DOF);
            sln=Solution(nodes);
            sln.initial=init;
            sln.fields=datafile.yi;
            sln.time=datafile.ti;
        end
        
        %used by calctime
%         function res=odefcn(y,props,link)
%             blank=zeros(length(link),1);
%             res=[link*y(:,1), blank] + eq.calc(y,props);
%         end
    end
end