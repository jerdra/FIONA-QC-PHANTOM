function MB_fBIRN_QA_process_study( input_nii,input_dcm,output)
%MB_FBIRN_QA_PROCESS_STUDY Runs on input type <study> data folder,
%generates QA measures and outputs for each Phantom
%{
Usage:
    input_nii:      Folder containing nii files to process
    input_dcm:      Folder containing dcm files to process, needed for
                    extracting relevant header metadata
    output:         Output folder
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

filelist = dir(full_nii_path);

%Remove entries without study name 'OPT' for testing purposes
%TODO: Replace with generalization
OPT_ind = cellfun(@(x) ~isempty(strfind(x,'OPT')),{filelist.name},'un',1);
PHA_ind = cellfun(@(x) ~isempty(strfind(x,'PHA')),{filelist.name},'un',1); 
SESS_ind = logical(OPT_ind.*PHA_ind); 
OPT = filelist(SESS_ind);

%Pre-process each OPT, limit cores so MATLAB doesn't break computer 
parfor (i = 1 : length(OPT), 3)
%for i = 1 : length(OPT) 
    disp(['Pre-processing '  OPT(i).name])
    
    %Locate dMRI nii files
    scanlist = dir(fullfile(full_nii_path,OPT(i).name));
    scanlist([scanlist.isdir] == 1) = [];
    scan_nii = cellfun(@(x) ~isempty(strfind(x,'fMRI')) && ~isempty(strfind(x,'nii')) && ~isempty(strfind(x,'ABCD')), {scanlist.name},'un',1);
    nii = {scanlist(scan_nii).name}; %Possibly may have more than one type of flip angle
    split_nii = cellfun(@(x) char(strsplit(x,'/')),nii,'un',0);
    strip_ind = regexp(split_nii,'.nii');
    
    %If directory already exists then move on. 
    if exist(fullfile(output,OPT(i).name),'dir')
        disp([OPT(i).name ' already exists, skipping'])
        continue; 
    else
        mkdir(output,OPT(i).name); 
    end
        
    %Generate qc outputs for each flip angle, then run noise decomposition
    %(assuming that flip angles constitute multiple scans - which is not..)
    for j = 1 : length(split_nii)
        
        sub_id = split_nii{j}(1:strip_ind{j} - 1);
        
        %Generate full nii input path for AFNI
        nii_path = fullfile(full_nii_path,OPT(i).name,nii{j});
        
        %Get associated metadata for study
        meta = get_meta_data(input_nii,input_dcm,fullfile(OPT(i).name,sub_id));
        
        %Make directories for output
        mkdir(fullfile(output,OPT(i).name),sub_id);
        
        %Pre-processing routine
        [vol,fwhm] = preprocess_nii_phantom(nii_path,fullfile(output,OPT(i).name,sub_id));
        
        %Modified QA routine adding noise decomposition?? 
        MB_fBIRN_phantom_ABCD(vol, meta, fullfile(output,OPT(i).name,sub_id),fwhm);
        
    end
    
    
end









end

