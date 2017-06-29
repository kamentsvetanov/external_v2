function surfrend_fscustom(conname, xSPM, fs_surface)

% function surfrend_fscustom(conname, SPM, fs_surface)
%
% Convert an SPM contrast into a w-file freesurfer overlay
%
% conname - contrast name (will be used to name the output overlay)
% SPM - pass SPM variable for spm99 (Note that you need to add VOX to the
%                                    SPM struct or use the default 3mm) 
%            xSPM variable for spm2
% fs_surface - FreeSurfer surface location (i.e., subject folder with
%              'surf' subfolder)
%
%
%_______________________________________________________________________
% @(#)surfrend_fscustom.m	V1.0 CVS $Author: itamarkahn $ $Date: 2008/04/03 13:10:21 $ $Name:  $ $RCSfile: surfrend_fscustom.m,v $ $Revision: 1.10 $

[SPMver, SPMc] = spm('Ver','',1);
global inclusion_radius
global pb_pointer pb_name
orig_pb_name = pb_name;

if nargin==0, 
  conname = spm_input('W-File (rendered surface) output name:',1, 's','');
  if isempty(conname),
    conname = 'surfrend_canonical';
  end
end

IMAGEformat = spm_input('Image Format',2,'SPM|Analyze');

switch IMAGEformat,
  case 'SPM',

   switch SPMver,
    case 'SPM99'
     if ~exist('xSPM','var'),    
       [SPM,VOL,xX,xCon,xSDM] = spm_getSPM;
       inclusion_radius = max(VOL.VOX);
       surfrendSPM = SPM;    
     else
       surfrendSPM = xSPM;
       if ~exist('xSPM.VOX','var'),
         inclusion_radius = 3;
       else
         inclusion_radius = max(xSPM.VOX);
       end
     end
    case 'SPM2'
    case 'SPM5'
     if ~exist('xSPM','var'),
       [SPM,xSPM] = spm_getSPM;
     end
     surfrendSPM = xSPM;
     inclusion_radius = max(xSPM.VOX);
    otherwise,
     error(['Unknown version (' SPMver ') of SPM']);
   end
  
 case 'Analyze',
  switch SPMver,
   case 'SPM99'
   case 'SPM2'
    P = spm_get(1,'*.img','Select analyze image');
    % NOTE: the analyze format was flipped between SPM99 and SPM2
    %       Use the same SPM version as the analyze format
   case 'SPM5'
    P = spm_select(1,'image','Analyze image');
  end
    IMAGEthreshold = spm_input('Threshold:',3,'e',0);
    V = spm_vol(P);
    [Y,XYZ] = spm_read_vols(V);
    posXYZ = XYZ(:,find(Y>IMAGEthreshold));
    surfrendSPM.Z = Y(find(Y>IMAGEthreshold))';
    surfrendSPM.XYZmm = posXYZ; %V.mat(1:3,:)*[posXYZ; ones(1,size(posXYZ,2))];
    inclusion_radius = max(max(V.mat(1:3,1:3)));
end

fprintf (1,'\n');

global compression_index

compression_index = 1;
orig_dir = pwd;

if ~exist('fs_surface','var'),
  switch SPMver,
   case 'SPM99'
   case 'SPM2'
    fs_surface = spm_get(-1,'','Select FreeSurfer subject folder');
   case 'SPM5'
    fs_surface = spm_select(1, 'dir', 'Select FreeSurfer subject folder');
  end
end

if ~exist([fs_surface '/surf/lh.smoothwm'],'file') | ~exist([fs_surface ...
                    '/surf/lh.smoothwm'],'file'),
  error(['Subject ' fs_surface ' does not have the required' ...
                    ' surfaces ({lh,rh}.smoothwm). Aborting']);
  return;
end

if ~exist([fs_surface '/mri/transforms/talairach.xfm'], 'file'),
   error(['Subject ' fs_surface ' does not have the talairach transoformation file (talairach.xfm). Aborting']);
  return;
end
 
[vertex_coords_lh, vertex_faces_lh] = read_surf([fs_surface '/surf/lh.smoothwm']);
[vertex_coords_rh, vertex_faces_rh] = read_surf([fs_surface '/surf/rh.smoothwm']);
xfm = read_xfm([fs_surface '/mri/transforms/talairach.xfm']);
hxfm = [ xfm ; 0 0 0 1];


surfrendSPM.RAS = [surfrendSPM.XYZmm' ones(length(surfrendSPM.XYZmm),1)] * inv(hxfm');


%% Left hemisphere
fg = spm_figure('FindWin','Interactive');
if ~isempty(fg),
  if ~isempty(pb_pointer),
    set(fg,'Pointer',pb_pointer);
    set(fg,'Name',[orig_pb_name ' - left hemisphere']);
  end;
end;
fprintf(1,'\nLeft Hemisphere: ');

vertex_coords = vertex_coords_lh(1:compression_index:end,:);
coords_ras = surfrendSPM.RAS(find(surfrendSPM.RAS(:,1) < 0),:) ; % lh < 0
coords_Z = surfrendSPM.Z(find(surfrendSPM.RAS(:,1) < 0));

if length(coords_Z) > 0,
  [vertex_index, w_index] = compute_transformation(vertex_coords, coords_ras,coords_Z);
  wfile_name = [conname '-lh.w'];
  fprintf(1,'Saving rendered surface to file: %s\n', wfile_name);
  w = write_wfile(wfile_name, w_index, vertex_index);
else
  fprintf(1,'Hemisphere does not contain above threshold voxels.\n');
end

%% right hemisphere
fg = spm_figure('FindWin','Interactive');
if ~isempty(fg),
  if ~isempty(pb_pointer),
    set(fg,'Pointer',pb_pointer);
    set(fg,'Name',[orig_pb_name ' - right hemisphere']);
  end;
end;
fprintf(1,'\nRight Hemisphere: ');
vertex_coords = vertex_coords_rh(1:compression_index:end,:);
coords_ras = surfrendSPM.RAS(find(surfrendSPM.RAS(:,1) > 0),:) ; % rh > 0
coords_Z = surfrendSPM.Z(find(surfrendSPM.RAS(:,1) > 0));

if length(coords_Z) > 0,
  [vertex_index, w_index] = compute_transformation(vertex_coords, coords_ras,coords_Z);
  wfile_name = [conname '-rh.w'];
  fprintf(1,'Saving rendered surface to file: %s\n', wfile_name);
  w = write_wfile(wfile_name, w_index, vertex_index);
else
  fprintf(1,'Hemisphere does not contain above threshold voxels.\n');
end

fg = spm_figure('FindWin','Interactive');
if ~isempty(fg),
  if ~isempty(pb_pointer),
    set(fg,'Pointer','Arrow');
    set(fg,'Name',[orig_pb_name ' - Done']);
  end;
end;

pb_name = orig_pb_name;

%=========================================================================
function [incremental_vertex_index, incremental_w_index] = compute_transformation(vertex_coords,coords_ras, coords_Z)

global compression_index
global inclusion_radius

fprintf(1,'Computing MNI-space -> surface trasnformation ...\n');
vertex_index = [];
w_index = [];
incremental_vertex_index = [];
incremental_w_index = [];
dist_mat_length = 500;

spm_progress_bar('Init',100);
last_val = 0;
increment_val = 100 / (1+fix(length(coords_Z) / dist_mat_length));
curr_val = 0;

for jj=1:dist_mat_length:length(coords_Z),
  curr_coords_ras = coords_ras(jj:min(jj+dist_mat_length,length(coords_ras)),:); 
  curr_coords_Z = coords_Z(jj:min(jj+dist_mat_length,length(coords_Z)));
  ones_ras = ones(1,length(curr_coords_ras(:,1)));
  ones_surf = ones_ras;
    
  for ii=1:length(curr_coords_ras(:,1)):length(vertex_coords)-length(curr_coords_ras(:,1)),
    coords_surf = vertex_coords(ii:ii+length(curr_coords_ras(:,1))-1,:);
    
    dist_mat_fast = sqrt((ones_surf' * coords_surf(:,1)'.^2)' - ... 
                         2* coords_surf(:,1) * curr_coords_ras(:,1)' + ... ...
                         (ones_ras' * curr_coords_ras(:,1)'.^2) + ...
                         (ones_surf' * coords_surf(:,2)'.^2)' - ... 
                         2* coords_surf(:,2) * curr_coords_ras(:,2)' + ...
                        (ones_ras' * curr_coords_ras(:,2)'.^2) + ...
                         (ones_ras' * coords_surf(:,3)'.^2)' - ... 
                         2* coords_surf(:,3) * curr_coords_ras(:,3)' + ...
                         (ones_ras' * curr_coords_ras(:,3)'.^2));
   
    [item_ii, item_jj, item_v] = find(dist_mat_fast < inclusion_radius);
    vertex_index = [vertex_index item_ii'+ii-1];
    w_index = [w_index curr_coords_Z(item_jj)];
  
  end
  ii = ii + length(curr_coords_ras(:,1));
  
  if (ii < size(vertex_coords,1)),
    coords_surf = [ vertex_coords(ii:end,:); ...
                    zeros(size(curr_coords_ras,1) - size(vertex_coords(ii:end,:),1),3)]; 

    dist_mat_fast = sqrt((ones_surf' * coords_surf(:,1)'.^2)' - ... 
                         2* coords_surf(:,1) * curr_coords_ras(:,1)' + ... 
                         (ones_ras' * curr_coords_ras(:,1)'.^2) + ...
                         (ones_surf' * coords_surf(:,2)'.^2)' - ... 
                         2* coords_surf(:,2) * curr_coords_ras(:,2)' + ... 
                         (ones_ras' * curr_coords_ras(:,2)'.^2) + ...
                         (ones_ras' * coords_surf(:,3)'.^2)' - ...
                         2* coords_surf(:,3) * curr_coords_ras(:,3)' + ...
                         (ones_ras' * curr_coords_ras(:,3)'.^2));
  
    dist_mat_fast = dist_mat_fast(1:length(vertex_coords(ii:end,:)),1:length(vertex_coords(ii:end,:)));  
    [item_ii, item_jj, item_v] = find(dist_mat_fast < inclusion_radius);
    vertex_index = [vertex_index item_ii'+ii-length(curr_coords_ras(:,1))-1];
    w_index = [w_index curr_coords_Z(item_jj)];
  
    [vertex_index,jj] = unique(vertex_index);
    w_index = w_index(jj);
  
  end
  
  if ~isempty(vertex_index),
    incremental_vertex_index = [incremental_vertex_index vertex_index];
    incremental_w_index = [incremental_w_index w_index];
  end
  
  curr_val = curr_val + increment_val;
  if last_val < floor(curr_val),
    spm_progress_bar('Set', min(fix(curr_val),100));
    last_val = curr_val;
  end
  
end

spm_progress_bar('Clear');

%=========================================================================

function vertex_coords = fs_surf(surf_fname)

TRIANGLE_FILE_MAGIC_NUMBER =  16777214 ;
QUAD_FILE_MAGIC_NUMBER =  16777215 ;

fid = fopen(surf_fname, 'rb', 'b') ;

magic_number = fread3(fid) ;

if (magic_number == QUAD_FILE_MAGIC_NUMBER)
	 numof_vertices = fread3(fid) ;
	 numof_faces = fread3(fid) ;
	 vertex_coords = fread(fid, numof_vertices*3, 'int16') ./ 100 ; 
elseif (magic == TRIANGLE_FILE_MAGIC_NUMBER)
   fgets(fid) ;
	 fgets(fid) ;
	 numof_vertices = fread(fid, 1, 'int32');
	 numof_faces = fread(fid, 1, 'int32');
	 vertex_coords = fread(fid, numof_vertices*3, 'float32') ; 
end

vertex_coords = reshape(vertex_coords, 3, numof_vertices)' ;
fclose(fid) ;

%=========================================================================

function xfm = read_xfm(xfm_fname)

fid = fopen(xfm_fname,'r');

fline = [];
while isempty(strfind(fline,'Linear_Transform')),
  fline = fgetl(fid);
end  

[xfm, count] = fscanf(fid,'%f'); 
xfm = reshape(xfm,4,3)';

%=========================================================================
function w = write_wfile(fname, w, vertex_index)

%
% w = write_wfile(fname, w, vertex_index)
% writes a vector into a binary 'w' file
%		fname - name of file to write to
%		w     - vector of values to be written
%		vertex_index  - vector of index values
%

% open it as a big-endian file
fid = fopen(fname, 'wb', 'b') ;
vnum = length(w) ;

vi = vertex_index - 1;
count=fwrite(fid, 0, 'int16');
count=fwrite3(fid, vnum);

for i=1:vnum
  fwrite3(fid, vi(i)) ;
  wt = w(i) ;
  fwrite(fid, wt, 'float') ;
end

fclose(fid) ;

%=========================================================================
function count=fwrite3(fid, val)

count=0;
b1 = bitand(bitshift(val, -16), 255) ;
b2 = bitand(bitshift(val, -8), 255) ;
b3 = bitand(val, 255) ;
count=count+fwrite(fid, b1, 'uchar') ;
count=count+fwrite(fid, b2, 'uchar') ;
count=count+fwrite(fid, b3, 'uchar') ;

