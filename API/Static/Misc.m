classdef Misc
    methods(Static)
        %arrays of structures to structure of arrays
        function soa= aos2soa(aos)
            props=fieldnames(aos);
            for i=1:length(props)
                sprop=props{i};
                soa.(sprop)=[aos.(sprop)]';
            end
        end
        %noise function
        function fcn=noise(longpass)
            samples=1000;
            rndlist=rand(1,samples);
            tlist=(0:samples-1).*longpass;
            fcn =@(t) interp1(tlist,rndlist,t);
        end
        %returns all available equations
        function eqn_list=getEquations()
            EqnClasses=dir('API/Equations/*.m');
            eqn_list={EqnClasses.name};
            for k = 1 : length(eqn_list)
                cellContents = eqn_list{k};
                % Truncate and stick back into the cell
                eqn_list{k} = cellContents(1:end-2);
            end
        end
        %a wrapper for circular arrow
        function bloch_arrow(figHandle, start, stop,centre_of_mass)
            radius=sqrt(sum((start-stop).^2))./2;
            centre=(start-stop)./2;
            cvector=stop-start;
            theta = 20;
            R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
            cvector=R*cvector'/2;
            angle=atan(cvector(2)/cvector(1));
            centre=start(:)+cvector;
            start=[start(:); 0];
            stop=[stop(:); 0];
            centre=[centre(:); 0];
            Misc.CreateCurvedArrow3(figHandle,start,stop,centre)
        end
        function blochArrow(figHandle, start, stop,centre_of_mass)
            A = start(:); % Point A to be on circle circumference
            B = stop(:); % Same with point B
            d = norm(B-A);
            R = d/2; % Choose R radius >= d/2
            C = (B+A)/2+sqrt(R^2-d^2/4)/d*[0,-1;1,0]*(B-A); % Center of circle
            a = atan2(A(2)-C(2),A(1)-C(1));
            b = atan2(B(2)-C(2),B(1)-C(1));
            b = mod(b-a,2*pi)+a; % Ensure that arc moves counterclockwise
            t = linspace(a,b,10);
            x = C(1)+R*cos(t);
            y = C(2)+R*sin(t);
            plot(figHandle, x,y,'LineWidth',2,'Color','Cyan')
            %axis equal
        end
        %Zac Giles (2020). circular_arrow (https://www.mathworks.com/matlabcentral/fileexchange/59917-circular_arrow),
        %MATLAB Central File Exchange. Retrieved March 2, 2020.
        function circular_arrow(figHandle, radius, centre, arrow_angle, angle, direction, colour, head_size, head_style)
            % This is a function designed to draw a circular arrow onto the current
            % figure. It is required that "hold on" must be called before calling this
            % function.
            %
            % The correct calling syntax is:
            %   circular_arrow(height, centre, angle, direction, colour, head_size)
            %   where:
            %       figHandle - the handle of the figure to be drawn on.
            %       radius - the radius of the arrow.
            %       centre - a vector containing the desired centre of the circular
            %                   arrow.
            %       arrow_angle - the desired orientation angle of the circular arrow.
            %                   This is measured in degrees counter-clockwise
            %       angle - the angle between starting and end point of the arrow in
            %                   degrees.
            %       direction - variable set to determine format of arrow head. Use 1
            %                   to get a clockwise arrow, -1 to get a counter clockwise
            %                   arrow, 2 to get a double headed arrow and 0 to get just
            %                   an arc.
            %       colour (optional) - the desired colour of the arrow, using Matlab's
            %                   <a href="matlab:
            %                   web('https://au.mathworks.com/help/matlab/ref/colorspec.html')">Color Specification</a>.
            %       head_size (optional) - the size of the arrow head.
            %       head_style (optional) - the style of the arrow head.
            %                   For more information, see <a href="matlab:
            %                   web('http://au.mathworks.com/help/matlab/ref/annotationarrow-properties.html#property_HeadStyle')">Annotation Arrow Properties</a>.
            
            %Ensure proper number of arguments
            if (nargin < 6)||(nargin > 9)
                error(['Wrong number of parameters '...
                    'Enter "help circular_arrow" for more information']);
            end
            
            % arguments 7, 8 and 9 are optional,
            if nargin < 9
                head_style = 'vback2';
            end
            if nargin < 8
                head_size = 10;
            end
            if nargin < 7
                colour = 'k';
            end
            
            % display a warning if the headstyle has been specified, but direction has
            % been set to no heads
            if nargin == 9 && direction == 0
                warning(['Head style specified, but direction set to 0! '...
                    'This will result in no arrow head being displayed.']);
            end
            
            
            % Check centre is vector with two points
            [m,n] = size(centre);
            if m*n ~= 2
                error('Centre must be a two element vector');
            end
            
            arrow_angle = deg2rad(arrow_angle); % Convert angle to rad
            angle = deg2rad(angle); % Convert angle to rad
            xc = centre(1);
            yc = centre(2);
            
            % Creating (x, y) values that are in the positive direction along the x
            % axis and the same height as the centre
            x_temp = centre(1) + radius;
            y_temp = centre(2);
            
            % Creating x & y values for the start and end points of arc
            x1 = (x_temp-xc)*cos(arrow_angle+angle/2) - ...
                (y_temp-yc)*sin(arrow_angle+angle/2) + xc;
            x2 = (x_temp-xc)*cos(arrow_angle-angle/2) - ...
                (y_temp-yc)*sin(arrow_angle-angle/2) + xc;
            x0 = (x_temp-xc)*cos(arrow_angle) - ...
                (y_temp-yc)*sin(arrow_angle) + xc;
            y1 = (x_temp-xc)*sin(arrow_angle+angle/2) + ...
                (y_temp-yc)*cos(arrow_angle+angle/2) + yc;
            y2 = (x_temp-xc)*sin(arrow_angle-angle/2) + ...
                (y_temp-yc)*cos(arrow_angle-angle/2) + yc;
            y0 = (x_temp-xc)*sin(arrow_angle) + ...
                (y_temp-yc)*cos(arrow_angle) + yc;
            
            % Plotting twice to get angles greater than 180
            i = 1;
            
            % Creating points
            P1 = struct([]);
            P2 = struct([]);
            P1{1} = [x1;y1]; % Point 1 - 1
            P1{2} = [x2;y2]; % Point 1 - 2
            P2{1} = [x0;y0]; % Point 2 - 1
            P2{2} = [x0;y0]; % Point 2 - 1
            centre = [xc;yc]; % guarenteeing centre is the right dimension
            n = 1000; % The number of points in the arc
            v = struct([]);
            
            while i < 3
                
                v1 = P1{i}-centre;
                v2 = P2{i}-centre;
                c = det([v1,v2]); % "cross product" of v1 and v2
                a = linspace(0,atan2(abs(c),dot(v1,v2)),n); % Angle range
                v3 = [0,-c;c,0]*v1; % v3 lies in plane of v1 and v2 and is orthog. to v1
                v{i} = v1*cos(a)+((norm(v1)/norm(v3))*v3)*sin(a); % Arc, center at (0,0)
                plot(v{i}(1,:)+xc,v{i}(2,:)+yc,'Color', colour) % Plot arc, centered at P0
                
                i = i + 1;
                
            end
            
            position = struct([]);
            
            % Setting x and y for CW and CCW arrows
            if direction == 1
                position{1} = [x2 y2 x2-(v{2}(1,2)+xc) y2-(v{2}(2,2)+yc)];
            elseif direction == -1
                position{1} = [x1 y1 x1-(v{1}(1,2)+xc) y1-(v{1}(2,2)+yc)];
            elseif direction == 2
                position{1} = [x2 y2 x2-(v{2}(1,2)+xc) y2-(v{2}(2,2)+yc)];
                position{2} = [x1 y1 x1-(v{1}(1,2)+xc) y1-(v{1}(2,2)+yc)];
            elseif direction == 0
                % Do nothing
            else
                error('direction flag not 1, -1, 2 or 0.');
            end
            
            % Loop for each arrow head
            i = 1;
            while i < abs(direction) + 1
                h=annotation('arrow'); % arrow head
                set(h,'parent', gca, 'position', position{i}, ...
                    'HeadLength', head_size, 'HeadWidth', head_size,...
                    'HeadStyle', head_style, 'linestyle','none','Color', colour);
                
                i = i + 1;
            end
        end
        
        %Source: https://stackoverflow.com/questions/25895072/curved-arrows-in-matlab
        %% --- Creates a curved arrow
        % from: Starting position - (x,y,z) upplet
        % to: Final position - (x,y,z) upplet
        % center: Center of arc - (x,y,z) upplet => by default the origin
        % count: The number of segment to draw the arrow => by default 15
        function [h] = CreateCurvedArrow3(figHandle,from, to, center, count)
            %[
            % Inputs
            if (nargin < 5), count = 15; end
            if (nargin < 4), center = [0 0 0]; end
            center = center(:); from = from(:); to = to(:);
            
            % Start, stop and normal vectors
            start = from - center; rstart = norm(start);
            stop = to - center; rstop = norm(stop);
            angle = atan2(norm(cross(start,stop)), dot(start,stop));
            normal = cross(start, stop); normal = normal / norm(normal);
            
            % Compute intermediate points by rotating 'start' vector
            % toward 'end' vector around 'normal' axis
            % See: http://inside.mines.edu/fs_home/gmurray/ArbitraryAxisRotation/
            phiAngles = linspace(0, angle, count);
            r = linspace(rstart, rstop, count) / rstart;
            intermediates = zeros(3, count);
            a = center(1); b = center(2); c = center(3);
            u = normal(1); v = normal(2); w = normal(3);
            x = from(1); y = from(2); z = from(3);
            for ki = 1:count
                phi = phiAngles(ki);
                cosp = cos(phi); sinp = sin(phi);
                T = [(u^2+(v^2+w^2)*cosp)  (u*v*(1-cosp)-w*sinp)  (u*w*(1-cosp)+v*sinp) ((a*(v^2+w^2)-u*(b*v+c*w))*(1-cosp)+(b*w-c*v)*sinp); ...
                    (u*v*(1-cosp)+w*sinp) (v^2+(u^2+w^2)*cosp)   (v*w*(1-cosp)-u*sinp) ((b*(u^2+w^2)-v*(a*u+c*w))*(1-cosp)+(c*u-a*w)*sinp); ...
                    (u*w*(1-cosp)-v*sinp) (v*w*(1-cosp)+u*sinp)  (w^2+(u^2+v^2)*cosp)  ((c*(u^2+v^2)-w*(a*u+b*v))*(1-cosp)+(a*v-b*u)*sinp); ...
                    0                    0                      0                                1                               ];
                intermediate = T * [x;y;z;r(ki)];
                intermediates(:,ki) = intermediate(1:3);
            end
            % Draw the curved line
            % Can be improved of course with hggroup etc...
            X = intermediates(1,:);
            Y = intermediates(2,:);
            Z = intermediates(3,:);
            tf = ishold;
            if (~tf), hold on; end
            h = line(X,Y,Z);
            quiver(figHandle,X(end-1), Y(end-1), X(end)-X(end-1), Y(end)-Y(end-1),1,'AutoScaleFactor',10);
            if (~tf), hold off; end
            %]
        end
    end
end