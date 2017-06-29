%Aim is to lod up and compare GE and Philips phantom data - experiments
%matched - 32x2 scabs, 4k points at 5 kHz, (26 mm)^3, 3s 68ms.

%Load GE data

%Load Philps data
%[MRS_struct_Philips] = GannetLoadPhantom({'./matlab folder/Philips_phantom_bu.SDAT'},{'./matlab folder/Philips_phantom_bu_w.SDAT'});
[MRS_struct_Philips] = GannetLoadPhantom({'./matlab folder/RE_phantom/Phil_bu_10_2_raw_act.SDAT'},{'./matlab folder/RE_phantom/Phil_bu_11_1_raw_act.SDAT'});

%Load GE data
[MRS_struct_GE] = GannetLoadPhantom({'./matlab folder/GE_phantom_cu.7'});

%Apply a circshift to teh data to line up to 3 ppm
%MRS_struct_Philips.gabaspec=circshift(MRS_struct_Philips.gabaspec,[0 -200]);
MRS_struct_Philips.gabaspec=circshift(MRS_struct_Philips.gabaspec,[0 -100]);
MRS_struct_GE.gabaspec=circshift(MRS_struct_GE.gabaspec,[0 -220]);

%Fit Philips data
[MRS_struct_Philips] = GannetFitPhantom(MRS_struct_Philips);

%Fit GE data
[MRS_struct_GE] = GannetFitPhantom(MRS_struct_GE);