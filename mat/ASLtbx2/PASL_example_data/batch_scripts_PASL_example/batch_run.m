
% Batch mode scripts for running spm2 in TRC
% Created by Ze Wang, 08-05-2004
% zewang@mail.med.upenn.edu

%example code for processing PASL data

%set the parameters
par;

% set the center to the center of each images
batch_reset_orientation;

%set the center to AC
batch_setorigin;

%realign the functional images to the first functional image of eachsubject
batch_realign;

%coreg the functional images to the anatomical image
batch_coreg;

%smooth the coreged functional images
batch_smooth;

%create perfusion mask
batch_create_mask;


batch_perf_subtract;
