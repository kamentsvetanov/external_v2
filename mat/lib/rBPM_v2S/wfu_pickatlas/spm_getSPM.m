function [SPM,xSPM,xX,xCon,xSDM] = wfu_spm_getSPM(wfu_params)
%spmversion=spm('Ver');
spmversion = wfu_get_ver;
conjunctionToolbox = which('spm_uc_FDR.m'); 

if ~isempty(conjunctionToolbox)
	switch spmversion
		case 'SPM99' 
			%In SPM99 the second output is Vol, not xSPM
			%We pass xSPM through as a placeholder for Vol
			[SPM,xSPM,xX,xCon,xSDM] = wfu_spm_getSPM99_conj;
		case 'SPM2B'
			[SPM,xSPM] = wfu_spm_getSPM2_conj;
		case 'SPM2'
			[SPM,xSPM] = wfu_spm_getSPM2_conj;
		case 'SPM5'
			if exist('wfu_params')
				[SPM,xSPM] = wfu_spm_getSPM5(wfu_params);
			else
				[SPM,xSPM] = wfu_spm_getSPM5;
            end
		otherwise
			[SPM,xSPM] = wfu_spm_getSPM2_conj;
	end
else
    switch spmversion
		case 'SPM99' 
			%In SPM99 the second output is Vol, not xSPM
			%We pass xSPM through as a placeholder for Vol
			[SPM,xSPM,xX,xCon,xSDM] = wfu_spm_getSPM99;
		case 'SPM2B'
			[SPM,xSPM] = wfu_spm_getSPM2;
		case 'SPM2'
			[SPM,xSPM] = wfu_spm_getSPM2;
		case 'SPM5'
			if exist('wfu_params')
				[SPM,xSPM] = wfu_spm_getSPM5(wfu_params);
			else
				[SPM,xSPM] = wfu_spm_getSPM5;
            end
		otherwise
			[SPM,xSPM] = wfu_spm_getSPM2;
	end
end
    
