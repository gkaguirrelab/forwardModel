function genhrf(obj)
% Creates and stores an HRF using the FLOBS eigenvectors
%
% Syntax:
%   obj.genhrf
%
% Description:
%   Creates an HRF kernel for convolution. The stored kernel has unit area
%   so that it preserves signal area after convolution. The kernel is
%   specified in a time x 1 vector orientation.
%
%   Typical values for the FLOBS weights are [0.86 0.09 0.01];
%
% Inputs:
%   none
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   none
%


% Obj variables
stimDeltaT = obj.stimDeltaT;
hrfParams = obj.hrfParams;

% Obtain the FLOBS vectors
flobsbasis = returnFlobsVectors(stimDeltaT);

% Creat the HRF
hrf = flobsbasis*hrfParams';

% Normalize the kernel to have unit area
hrf = hrf/sum(abs(hrf));

% Store the hrf in the object.
obj.hrf = hrf;

end

