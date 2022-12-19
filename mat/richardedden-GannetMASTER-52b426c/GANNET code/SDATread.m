function A = SDATread(filename,da_xres)
%function A = SDATread(filename,da_xres)
i = sqrt(-1);
% Open file to read reference scan data.
fid = fopen(filename,'rb', 'ieee-le');
if fid == -1
   err_msg = sprintf('Unable to locate File %s', pfile)
   return;
end
%%Set up a structure to take the data:
A=zeros(da_xres,1);
 totalframes=1;
 totalpoints = totalframes*da_xres*2;

    [raw_data] = freadVAXG(fid, totalpoints, 'float');
 
    TempData=reshape(raw_data,[2 da_xres]);
    A=squeeze(TempData(1,:)+i*TempData(2,:));
 fclose(fid);
end