function [ sw_SFNR, bg_SFNR ] = FA_signal_noise_decomp(Iave,Isd)
%FA_SIGNAL_NOISE_DECOMP Performs signal flucuation noise decomposition 
%   Using both FA of ABCD phantom acquisition pipelines decompose the noise
%   contributions from background noise and signal flucuation noise 

%   Ideal case modelling case: 
%       Temporal stability of background signal independent noise
%       Signal-dependent noise from scanner instability


% Implementation details: 
% Greve, D. N., Mueller, B. A., Liu, T., Turner, J. A., Voyvodic, J., Yetter, E., … 
% The FBIRN. (2011). 
% A Novel Method for Quantifying Scanner Instability in fMRI. 
% Magnetic Resonance in Medicine, 65(4), 1053–1061.
% http://doi.org/10.1002/mrm.22691

%{
 Arguments: 
    vol4D - 4D MR volume 
    Iave  - Average Signal Intensity
    Isd   - Temporal Standard Deviation 

% Detrending fits are estimated with a second
degree polynomial in time. 

%}

%First compute flip angle scale factor matrix 
%Assumes a first-degree linear model between Intensity and Flip-Angle
M = Iave{1} ./ Iave{2};

%Compute temporal variabiltiy 
Ivar = cellfun(@(x) x.^2, Isd,'un',0); 

%Compute signal weighted and background noise
var_SW = M.^2*(Isd{1} - Isd{2})./(M.^2 - 1); 
var_BG = (M.^2*Isd{2} - Isd{1})./(M.^2 - 1); 

%Compute decomposed Signal-Flucuation Noise Ratio 
sw_SFNR = Iave{1}./sqrt(var_SW); 
bg_SFNR = Iave{1}./sqrt(var_BG); 

%TODO: Correct variance/std ambiguity 






end

