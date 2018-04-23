function generate_qc_vis( qc_report, output )
%GENERATE_QC_RPORT Generates qc visuals for a given study across
%acquisition sites

%{
    Arguments:
        qc_report:              Directory containing qc output of ABCD
                                phantom qc pipeline
        output:                 Directory for outputting qc visual report
%}



%Load QC json file, separate out different sites and generate
%visualizations

%Add qc_report to path 
addpath(genpath(qc_report)); 

%First load all directories inside qc_report
qc_dir = dir(qc_report);
dot_ind = cellfun(@(x) isequal(x,'.') || isequal(x,'..'), {qc_dir.name},'un',1);
qc_dir(dot_ind) = [];

%Step 1 - Identify all sites  (luckily we have datman convention!)
split_name = cellfun(@(x) strsplit(x,'_'),{qc_dir.name},'un',0);
sites = cellfun(@(x) char(x{2}), split_name,'un',0);
u_sites = unique(sites);

%For each site we want to extract the relevant qc metrics
qa_metrics = []; 
for site = 1 : length(u_sites)
    
    %Get all scans from site
    site_ind = ~cellfun(@isempty,strfind({qc_dir.name},u_sites{site}));
    site_scans = qc_dir(site_ind);
    
    %For each site, extract relevant metrics
    qa_metrics = [qa_metrics; extract_site_qc(qc_report,site_scans,u_sites(site))]; 
    
    
    
    
end

end

function [qa_metrics] = extract_site_qc(qc_report,site_scans,site)

%extract_site_qc(site) extracts QC metrics generated from ABCD
%phantom pipeline and returns metric struct
qa_metrics = []; 

for i = 1 : length(site_scans)
    
    scans_dir =  dir(fullfile(qc_report,site_scans(i).name)); 
    dot_ind = cellfun(@(x) isequal(x,'.') || isequal(x,'..'), {scans_dir.name},'un',1); 
    scans_dir(dot_ind) = []; 
    
    %For each flip angle extract a qc report 
    for flip = 1:length(scans_dir)
        
        flip_path = fullfile(qc_report,site_scans(i).name,scans_dir(flip).name); 
        flip_dir = dir(flip_path); 
        json = loadjson(fullfile(flip_path,'QA_metrics.json')); 
        
        json.fBIRN_Phantom_QA.QA_metrics.FlipAngle = json.fBIRN_Phantom_QA.SeriesInfo.FlipAngle;  
        json.fBIRN_Phantom_QA.QA_metrics.Site = site; 
        %Create output 
        qa_metrics = [qa_metrics; json.fBIRN_Phantom_QA.QA_metrics]; 
        
    end
    
end

end
