classdef Gvizlayout < Abstractlayout
% Use the graphVIZ package to determine the optimal layout for a graph.
%
% Matthew Dunham
% University of British Columbia 
% http://www.cs.ubc.ca/~mdunham/
   properties
     xmin;               % The left most point on the graph axis in data units           
     xmax;               % The right most point on the graph axis in data units
     ymin;               % The bottom most point on the graph axis in data units
     ymax;               % The top most point on the graph axis in data units
     adjMatrix;          % The adjacency matrix
     maxNodeSize;        % The maximum diameter of a node in data units
     image;              % An image for the button that will lanuch this layout
     name;               % A unique name for instances of this class. 
     shortDescription;   % A short descriptions used in tooltips.
     nodeSize;           % The calculated node size, call dolayout() before accessing
     centers;            % The calculated node centers in an n-by-2 matrix
   end
    
   properties(GetAccess = 'protected', SetAccess = 'protected')
        layoutFile = 'layout.dot';
        adjFile   =  'adjmat.dot';
   end
    
   methods
     
       function obj = Gvizlayout(name)
       % constructor
            if(nargin < 1)
                obj.name = 'Gvizlayout';
            else
                obj.name = name;
            end
            load glicons;
            obj.image = icons.energy;
            obj.shortDescription = 'Minimum Energy Layout (GraphViz)';
       end
       
       function available = isavailable(obj)
        % Make sure graphViz is available. 
            available = Gvizlayout.queryGviz('neato');
            if(not(available))
                  fprintf('Please install or upgrade graphViz\n');
            end
        end
       
       
   end

   
   methods(Access = 'protected')
       
       function calcLayout(obj)
       % Have graphViz calculate the layout
          obj.writeDOTfile();
          obj.callGraphViz();
          obj.readLayout();
          obj.cleanup();
       end
      
       function writeDOTfile(obj)
       % Write the adjacency matrix into a dot file that graphViz can
       % understand. 
            fid = fopen('adjmat.dot','w');
            fprintf(fid,'digraph G {\ncenter = 1;\nsize="10,10";\n');
            n = size(obj.adjMatrix,1);
            for i=1:n, fprintf(fid,'%d;\n',i); end
            edgetxt = ' -> ';
            for i=1:n
                for j=1:n
                   if(obj.adjMatrix(i,j))
                      fprintf(fid,'%d%s%d;\n',i,edgetxt,j);
                   end
                end 
            end
            fprintf(fid,'}');
            fclose(fid);
       end
       
       function callGraphViz(obj)
       % Call GraphViz to determine an optimal layout. Write this layout in
       % layout.dot for later parsing. 
           err = system(['neato -Tdot -Gmaxiter=5000 -Gstart=7 -o ',obj.layoutFile,' ',obj.adjFile]);
           if(err),error('Sorry, unknown GraphViz failure, try another layout'); end
       end
       
       function readLayout(obj)
       % Parse the layout.dot file for the graphViz node locations and 
       % dimensions. 
            fid = fopen(obj.layoutFile,'r');
            text = textscan(fid,'%s','delimiter','\n'); 
            fclose(fid);
            text = text{:};
            [start,dims] = strtok(text{cellfun(@(x)~isempty(x),strfind(text,'graph [bb="'))},'"');
            dims = textscan(strtok(dims,'"'),'%n','delimiter',',');
            dims = dims{:}';
            text(cellfun(@(x)~isempty(x),strfind(text,' -> ')))=[]; % delete edge info, we don't need it
            text(cellfun(@(x)isempty(x),strfind(text,'pos')))=[];   % keep only positions
            [start,remaining] = strtok(text,'"');
            [locations,remaining] = strtok(remaining,'"');
            locations = cellfun(@(str)textscan(str,'%n','delimiter',','),locations,'UniformOutput',false);
            locations = [locations{:}];
            locations = [locations{:}]';
            obj.scaleLocations(locations,dims);
       end
       
       function scaleLocations(obj,locations,graphVizDims)
       % Scale the graphViz node locations to the smartgraph dimensions and
       % set the node size. 
            dims = graphVizDims; loc = locations;
            loc(:,1) = (loc(:,1)-dims(1)) ./ (dims(3)-dims(1))*(obj.xmax - obj.xmin) + obj.xmin;
            loc(:,2) = (loc(:,2)-dims(2)) ./ (dims(4)-dims(2))*(obj.ymax - obj.ymin) + obj.ymin;
            [loc(1,:) loc(2,:)]=deal(loc(2,:),loc(1,:)); % Swap poisitions of 1st and 2nd node, kat 20141015
            x_center = loc(2,1);
            y_center = loc(2,2);
            center = repmat([x_center, y_center],size(loc,1),1);
            
            % define a 60 degree counter-clockwise rotation matrix
            theta = pi/6;       % pi/3 radians = 60 degrees
            R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
            % do the rotation...
            s = loc - center;     % shift points in the plane so that the center of rotation is at the origin
            so = R*s';so=so';           % apply the rotation about the origin
            vo = so + center;   % shift again so the origin goes back to the desired center of rotation
            sl = vo(2,1)-0.5;
            vo(:,1) = vo(:,1)-sl;
            vo(:,2) = vo(:,2)-0.1;
            % this can be done in one line as:
            % vo = R*(v - center) + center
            % pick out the vectors of rotated x- and y-data
%             x_rotated = vo(1,:);
%             y_rotated = vo(2,:);
            vo=[0.5008 0.8376;0.500 0.4000;0.1198    0.1805; 0.8794    0.1819];
            obj.centers = vo;%loc;
            
            a = min(abs(loc(:,1) - obj.xmin));
            b = min(abs(loc(:,1) - obj.xmax));
            c = min(abs(loc(:,2) - obj.ymin));
            d = min(abs(loc(:,2) - obj.ymax));
            obj.nodeSize = min(2*min([a,b,c,d]),obj.maxNodeSize);
            
       end
       
       function cleanup(obj)
       % delete the temporary files. 
           delete(obj.adjFile);
           delete(obj.layoutFile);
       end
       
   end
  
   methods(Access = 'protected',Static = true)
      
       function available = queryGviz(name)
            %err = system([name,' -V']);
            [j, err] = evalc('system([name,'' -V'']);');
            available = ~err;
       end
       
   end
   
 
end % end of graphVIZlayout class