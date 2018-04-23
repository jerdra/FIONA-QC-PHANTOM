function MB_fBIRN_QA_process_study( input_nii,input_dcm,output, type )
%MB_FBIRN_QA_PROCESS_STUDY Runs on input type <study> data folder,
%generates QA measures and outputs for each Phantom
%{
Usage:
    input_nii:      Folder containing nii files to process
    input_dcm:      Folder containing dcm files to process, needed for
                    extracting relevant header metadata
    output:         Output folder
    type:           dMRI/fMRI
%}


tic

if nargin < 2
    error('MB_fBIRN_QA_process_study: not enough inputs!')
end

%General housekeeping, feed in 1 NII at a time!
what_nii = what(input_nii);
full_nii_path = what_nii.path;

what_dcm = what(input_dcm);
full_dcm_path = what_dcm.path;

filelist = dir(input_nii);

%Remove entries without study name 'OPT' for testing purposes
%TODO: Replace with generalization
OPT_ind = cellfun(@(x) ~isempty(strfind(x,'OPT')),{filelist.name},'un',1);
OPT = filelist(OPT_ind);

%Pre-process each OPT
parfor i = 1 : length(OPT)
    disp(['Pre-processing '  OPT(i).name])
    
    %Locate dMRI nii files
    scanlist = dir(fullfile(pwd,input_nii,OPT(i).name));
    scanlist([scanlist.isdir] == 1) = [];
    scan_nii = cellfun(@(x) ~isempty(strfind(x,type)) && ~isempty(strfind(x,'nii')), {scanlist.name},'un',1);
    nii = {scanlist(scan_nii).name}; %Possibly may have more than one type of flip angle
    split_nii = cellfun(@(x) char(strsplit(x,'/')),nii,'un',0);
    strip_ind = regexp(split_nii,'.nii');
    
    mkdir(output,OPT(i).name); 
    
    %Allocate cells for signal noise decomposition 
    Iave = cell(length(split_nii),1); 
    Isd = cell(length(split_nii),1); 
    
    %Generate qc outputs for each flip angle, then run noise decomposition
    for j = 1 : length(split_nii)
        
        sub_id = split_nii{j}(1:strip_ind{j} - 1);
        
        %Generate full nii input path for AFNI
        nii_path = fullfile(full_nii_path,OPT(i).name,nii{j});
        
        %Get associated metadata for study
        meta = get_meta_data(input_nii,input_dcm,fullfile(OPT(i).name,sub_id));
        
        %Make FA directories for output
        fa_dir = ['flip-' num2str(meta.FA)];
        mkdir(fullfile(output,OPT(i).name),fa_dir);
        
        %Pre-processing routine
        [vol,fwhm] = preprocess_nii_phantom(nii_path,fullfile(output,OPT(i).name,fa_dir));
        
        %Modified QA routine adding noise decomposition?? 
        [Iave{j}, Isd{j}] = MB_fBIRN_phantom_ABCD(vol, meta, fullfile(output,OPT(i).name,fa_dir),fwhm);
        
    end
    
    
end









end

