function Vs = wfu_bpm_hdr_struct(V)
% ______________________________________________________________________
%
% This function performs the following task:
%       Returns a hdr struct based on the dim and mat variables in the
%       input V struct.  If present, dt (datatype) is also set.
%_______________________________________________________________________
% Input parameters
% V         - input hdr struct
%
% Output parameters
% Vs         - ouput hdr struct with scale = 1, descrip = 'WFU BPM'
%_______________________________________________________________________
vdim = V.dim(1:3);
vmat = V.mat;
if isfield(V, 'dt')
    vdt = [spm_type('float64') spm_platform('bigend')];
    Vs = struct('fname', '', 'dim', vdim, 'dt', vdt, ...
        'mat', vmat, 'pinfo', [1 0 0]', 'descrip', 'WFU BPM'); 
else
    vdim(4) = spm_type('double');
    Vs = struct('fname', '', 'dim', vdim, ...
        'mat', vmat, 'pinfo', [1 0 0]', 'descrip', 'WFU BPM'); 
end
% 
% retain any wfu header settings
if isfield(V, 'wfu')
  Vs.wfu = V.wfu;
end

