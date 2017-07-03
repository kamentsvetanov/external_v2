function wfu_bpm(varargin)
%------------------------------------------------------------------------
%               WFU Biological Parametric Mapping (BPM) Toolbox 
%-------------------------------------------------------------------------
%                           wfu_bpm
%  The BPM toolbox has been developed to perform SPM analysis with
%  imaging covariates.  For a detailed description, refer to:
%
% Biological parametric mapping: A statistical toolbox for multimodality
%     brain image analysis  - SHORT COMMUNICATION
% 
% NeuroImage, Volume 34, Issue 1, 1 January 2007, Pages 137-143 
% 
% Ramon Casanova, Ryali Srikanth, Aaron Baer, Paul J. Laurienti,
% Jonathan H. Burdette, Satoru Hayasaka, Lynn Flowers, Frank Wood and
% Joseph A. Maldjian
%
%-------------------------------------------------------------------------
%  
%  Advanced NeuroScience Imaging Research (ANSIR) Laboratory
%  Wake Forest University Medical School
%  Winston Salem, North Carolina, USA
%--------------------------------------------------------------------------
%            wfu_bpm can be executed from the command line 
%--------------------------------------------------------------------------  
%   Format: 
%   wfu_bpm(type,flist,contrast,STAT,mask,conf,thr,result_dir,title, Inf_Type, bRobust, filter)
%--------------------------------------------------------------------------
%  Examples:
%    >> wfu_bpm; %-launches GUI  
%    >> wfu_bpm('CORR','flist.txt',[],[],'mask.img',[],[],[],[],'HCF');
%    >> wfu_bpm('ANCOVA','master_flist.txt',[ 1 -1 0],'T',[],[],[ 1 0.1],[],[],[]);
% -------------------------------------------------------------------------
%  Input Parameters:
%
%   type     - Type of analysis to be performed. Possible values are:
%               'ANOVA'         =   Anova 
%               'ANCOVA'        =   BPM Ancova              
%               'CORR_V-V'      =   Voxel-wise Correlation
%               'PCORR'         =   Partial Correlation
%               'REGRESSION'    =   BPM Regression
%
%   flist    - The master file. It contains a list of txt files, one per
%              each modality involved in the analysis.
%             
%   contrast - a given contrast 
%
%   STAT     - Statistic type ('T','F')
%   
%   mask     - (optional) full path name of the file containing the brain 
%              mask. If the user does not supply one, BPM will build one by
%              default. The user must check the resulting mask.img file.
%
%   conf     - path and name of the file containing the non-imaging confounds 
%    
%   thr      - threshold to build the default brain mask when the user
%              does not supply one. thr is a vector with 2 elements. The
%              first one indicates the type of the threshold (1 is 
%              proportional 2 absolute). The second element is the value of
%              the threshold.
%
% result_dir - the full path name of the existing directory where results
%              will be stored.
%
% title      - name assigned to the contrast 
%
% Inf_Type   - specify the type of inference to use with the correlation
%              option
%              'HCF'  = Homologous Correlation Field
%              'TF'   = T-fields
%
% bRobust    - 1: use robust regression, 0: use non robust regression
%
% ofilter     - Threshold of outlier filter
%--------------------------------------------------------------------------

global wfu_startdir
%if isunix
%    if ~strcmp(spm('Ver'), 'SPM5')
%        wfu_startup([],2); % Set spm2 paths, set spm2 defaults, unset spm99 paths
%    end
%end
wfu_startdir = pwd;
if nargin < 1 % launch GUI
    wfu_titlebar_text = 'Biological Parametric Mapping Toolbox';
    color1 = [.663, .663, .675];
    color2 = [0, .181, .24];
    wfu_version = 'Version 1.5 Beta Robust';
    version_color = [1, 1, 1];
%
% create FIGURE based on SPM Interactive Window size
%
    I = spm('WinSize', 'Interactive');
    if strcmp(spm('ver', [], 1), 'SPM5')
%         I(3) = I(3) * 1.25;
          I(3) = I(3) * 1.6;
    end
    B = [I(1), I(2)+I(4)+50, I(3), I(4)/4];
    f = figure('Position', B, ...
               'Name', wfu_titlebar_text, ...
               'Color', color1,...
               'HandleVisibility', 'on',...
               'IntegerHandle', 'off',...
               'Renderer', 'painters',...
               'NumberTitle', 'off',...
               'MenuBar', 'none', ...
               'Toolbar', 'none' ... 
               );
%
% create PANEL to hold buttons
%
	edge = B(4)/10;
	panelw = B(3) - edge * 2;
	panelh = B(4) - edge * 2;
	p = uicontrol(f, 'Style', 'frame', ...
        'BackgroundColor', color2, ...
        'Position', [edge, edge, panelw, panelh], ...
        'Parent', f);
%
% create version label
%
    version_pos = [edge * 2, panelh - edge * 1.5, panelw - edge * 2, edge * 2];
    versionLabel = uicontrol(f, 'Style', 'text', ...
        'ForegroundColor', version_color, ...
        'BackgroundColor', color2, ...
        'HorizontalAlignment', 'c', ...
        'Position', version_pos, ...
        'String', wfu_version, ...
        'Parent', f);
%
% create BUTTONS 1-5
%
    nbutton = 5;
    buttonmargin = edge * 1.5;
    buttonw = (panelw - buttonmargin*(nbutton+1))/nbutton;
    buttonh = edge * 2.25;
    buttonx = edge + buttonmargin;
    buttony = edge + panelh/2 - buttonh * .75;
    button1 = uicontrol(f, 'Style', 'pushbutton', ...
        'Position', [buttonx, buttony, buttonw, buttonh], ...
        'String', 'BPM Analysis', ...
        'Parent', f, ...
        'Callback', @button1Callback);
	
    buttonx = buttonx + buttonw + buttonmargin;
    button2 = uicontrol(f, 'Style', 'pushbutton', ...
        'Position', [buttonx, buttony, buttonw, buttonh], ...
        'String', 'Contrast Manager', ...
        'Parent', f, ...
        'Callback', @button2Callback);
    buttonx = buttonx + buttonw + buttonmargin;
    button3 = uicontrol(f, 'Style', 'pushbutton', ...
        'Position', [buttonx, buttony, buttonw, buttonh], ...
        'String', 'SPM Insertion Tool', ...
        'Parent', f, ...
        'Callback', @button3Callback);
    buttonx = buttonx + buttonw + buttonmargin;
    button4 = uicontrol(f, 'Style', 'pushbutton', ...
        'Position', [buttonx, buttony, buttonw, buttonh], ...
        'String', 'BnPM Analysis', ...
        'Parent', f, ...
        'Callback', @button4Callback);
    buttonx = buttonx + buttonw + buttonmargin;
    button5 = uicontrol(f, 'Style', 'pushbutton', ...
        'Position', [buttonx, buttony, buttonw, buttonh], ...
        'String', 'BnPM Results', ...
        'Parent', f, ...
        'Callback', @button5Callback); 
   
%
% set FONT for buttons
%
    if isunix
        uihandles = findall(f, 'Type', 'uicontrol');
        set(uihandles, 'FontName', 'Helvetica', 'FontSize', 10);
     end
else % INVOKE COMMAND LINE OPTIONS
    wfu_bpm_analysis(varargin{:});
end
%
% BUTTON CALLBACKS
%
function button1Callback(src, evt)
global wfu_startdir
if isempty(wfu_startdir), wfu_startdir = pwd; end
disp('calling wfu_bpm_analysis ...');
cd(wfu_startdir);
wfu_bpm_analysis;
disp('all done ... analysis');
%
function button2Callback(src, evt)
disp('calling contrast manager ...');
wfu_bpm_con_man;
disp('all done ... contrast manager');
%
function button3Callback(src, evt)
disp('calling Tmap insertion tool ...');
wfu_insert_map;
disp('all done ... insertion');
%
function button4Callback(src, evt)
disp('calling BnPM analysis ...');
error = van_bnpm_analysis;
if error > 0
    close(H)
    return
end
disp('all done ... BnPM analysis');
%
function button5Callback(src, evt)
disp('calling BnPM analysis ...');
van_bnpm_results;
disp('all done ... BnPM results');