function result = WT_Set_Coeff(varargin)
% data
% value
% scale
% direction
% position

% FracLab 2.05 Beta, Copyright © 1996 - 2009 by INRIA
% -- --
% For details on use and redistribution refer to $fraclab/licence.txt
%--------------------------------------------------------------------------

% set coefficient of specified scale, direction and position to value
if (nargin == 5) 
	data = varargin{1};
	value = varargin{2};
	scale = varargin{3};
	scale = data.scales - scale +1;
	direction = varargin{4};
	position = varargin{5};
	
	erg = data;
	erg.wt(data.wti(scale,direction)+position-1) = value;
end

% set all coefficients of specified scale and direction to value
if (nargin == 4) 
	data = varargin{1};
	value = varargin{2};
	scale = varargin{3};
	scale = data.scales - scale +1;	
	direction = varargin{4};
	
	erg = data;
	erg.wt(data.wti(scale,direction):(data.wti(scale,direction)+data.wtl(scale,1)*data.wtl(scale,2)-1)) = value;
end

% set all coefficients of specified scale to value
if (nargin == 3) 
	data = varargin{1};
	value = varargin{2};
	scale = varargin{3};
	scale = data.scales - scale +1;	
	erg = data;
	
	if (size(value,1)==1)
		erg.wt(data.wti(scale,1):(data.wti(scale,1)+data.wtl(scale,1)*data.wtl(scale,2)-1)) = value;
		erg.wt(data.wti(scale,2):(data.wti(scale,2)+data.wtl(scale,1)*data.wtl(scale,2)-1)) = value;
		erg.wt(data.wti(scale,3):(data.wti(scale,3)+data.wtl(scale,1)*data.wtl(scale,2)-1)) = value;
	elseif (size(value,1)==3)
		erg.wt(data.wti(scale,1):(data.wti(scale,1)+data.wtl(scale,1)*data.wtl(scale,2)-1)) = value(1,:);
		erg.wt(data.wti(scale,2):(data.wti(scale,2)+data.wtl(scale,1)*data.wtl(scale,2)-1)) = value(2,:);
		erg.wt(data.wti(scale,3):(data.wti(scale,3)+data.wtl(scale,1)*data.wtl(scale,2)-1)) = value(3,:);
	else
		ERROR = 'wrong format';
	end
			
	
	
end


result = erg;
