function [ vol4D, meta, fwhm ] = read_nifti_phantom( input, fwhm_out )
%READ_NIFTI_PHANTOM Summary of this function goes here
%{
Description:
    Reads NIFTI fMRI phantoms for ABCD QC and pulls metadata
    as well as a smoothed version of the original input file
   
Arguments:
    input - phantom nifti file
    output - name of smoothed file to be outputted
%}


img = load_untouch_nii(input);

% Pull voxel dimensions and TR
pixdim = img.hdr.dime.pixdim;
d1 = pixdim(2);
d2 = pixdim(3);
d3 = pixdim(4);
tr = pixdim(5);

% Get required metadata
meta = struct();
meta.TR = tr;
meta.sx = d1;
meta.sy = d2;
meta.sz = d3;
[vol4D, fwhm] = getFWHM(input,fwhm_out);

end

function [vol4D, fwhm] = getFWHM(input, output)

nifti_image = load_nii(input);
vol4D = rot90(flip(double(nifti_image.img),1),3);

cmd = sprintf('mkdir %s/AFNI', output);
unix(cmd);
cmd = sprintf('3dcopy %s %s/AFNI/dset+orig', input, output);
unix(cmd)

afni_output = [output, '/AFNI'];
cmd = sprintf('3dvolreg -prefix %s/volreg %s/dset+orig',afni_output, afni_output);
unix(cmd);
cmd = sprintf('3dDetrend -polort 2 -prefix %s/voldetrend %s/volreg+orig', afni_output, afni_output);
unix(cmd);
cmd = sprintf('3dTstat -mean -prefix %s/volmean %s/volreg+orig', afni_output, afni_output);
unix(cmd);
cmd = sprintf('3dAutomask -q -prefix %s/volmask %s/volmean+orig', afni_output, afni_output);
unix(cmd);
cmd = sprintf('3dFWHMx -dset %s/voldetrend+orig -mask %s/volmask+orig -out %s/FWHMVALS', afni_output, afni_output, afni_output);
unix(cmd);

fname = fullfile(afni_output,'FWHMVALS');
fileID = fopen(fname,'r');
formatSpec = '%f';
sizeA = [3 size(vol4D,4)];
A = fscanf(fileID,formatSpec,sizeA);
fclose(fileID);

fwhm_x = A(1,:);
fwhm_x(fwhm_x==-1)=0;
fwhm(1)=mean(nonzeros(fwhm_x));

fwhm_y = A(2,:);
fwhm_y(fwhm_y==-1)=0;
fwhm(2)=mean(nonzeros(fwhm_y));

fwhm_z = A(3,:);
fwhm_z(fwhm_z==-1)=0;
fwhm(3)=mean(nonzeros(fwhm_z));

end


