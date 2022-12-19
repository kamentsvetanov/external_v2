function flica_save(Z, fileinfo, outdir, suffix)

if nargin<4, suffix=''; end

for k = 1:length(Z)
    ft = fileinfo.filetype{k};
    mask = fileinfo.masks{k};
    if iscell(ft) && isequal(ft{1},'NIFTI')
        % Save 4D NIFTI file:
        out = zeros([size(fileinfo.masks{k}) size(Z{k},2)], 'single');
        tmp = zeros(size(fileinfo.masks{k}), 'single');
        for i=1:size(out,4)
            tmp(fileinfo.masks{k}) = Z{k}(:,i);
            out(:,:,:,i) = tmp;
        end
        outname = sprintf('%s/niftiOut_mi%g%s.nii.gz',outdir,k,suffix);
        fprintf('Saving "%s"...', outname)
        save_avw(out, outname, 'f', ft{3});
        fprintf(' done.\n')
    elseif isstruct(ft) && numel(ft)==2
        % Save a pair of MGH files:
        vol = zeros([numel(mask) size(Z{k},2)]);
        vol(mask,:) = Z{k};
        vol = permute(vol, [4 1 3 2]);
        mriOut = ft(1);
        mriOut.vol = vol(:,1:end/2,:,:);
        fprintf('Saving modality %g: LH', k)
        MRIwrite(mriOut, sprintf('%s/mriOut_mi%g_l%s.mgh',outdir,k,suffix), 'MGH');
        mriOut = ft(2);
        mriOut.vol = vol(:,end/2+1:end,:,:);
        fprintf(' RH')
        MRIwrite(mriOut, sprintf('%s/mriOut_mi%g_r%s.mgh',outdir,k,suffix), 'MGH');
        fprintf('\n')
    else
        warning('Skipping %g!!!', k) %#ok<WNTAG>
    end
end