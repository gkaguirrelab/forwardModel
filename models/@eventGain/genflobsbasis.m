function genflobsbasis(obj)
% Generates and stores a matrix of FLOBS covarariates
%
% Syntax:
%   obj.genflobsbasis
%
% Description:
%   
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
stimulus = obj.stimulus;
stimDeltaT = obj.stimDeltaT;
stimAcqGroups = obj.stimAcqGroups;

% Obtain the FLOBS eigenvectors, sampled to the stimulus deltaT. Also
% returns the multivariate normal mean and covariance matrix, which we
% store in the model object.
[obj.flobsbasis, obj.mu, obj.C] = returnFlobsVectors(stimDeltaT);


end
