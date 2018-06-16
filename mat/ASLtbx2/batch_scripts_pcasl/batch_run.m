
% Batch mode scripts for running spm2 in TRC
% Created by Ze Wang, 08-05-2004
% zewang@mail.med.upenn.edu


%set the parameters
par;

% set the center to the center of each images
% batch_3Dto4D;
batch_reset_orientation;


%realign the functional images to the first functional image of eachsubject
batch_realign;

%coreg the functional images to the anatomical image
batch_coreg;

batch_filtering;

%smooth the coreged functional images
batch_smooth;

%create perfusion mask
batch_create_mask;


batch_perf_subtract;

%coreg the result images to MNI template image
batch_norm_spm12;

