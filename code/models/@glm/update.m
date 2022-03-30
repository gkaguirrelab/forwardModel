function x0 = update(obj,x,x0,floatSet,signal)
% Update x0 with the result of the search
%
% Syntax:
%   x0 = obj.update(x,x0, floatSet)
%
% Description:
%   Update the x0 parameters based upon the results of a stage of search.
%   This method is the place to support more complex updating of the
%   parameters.
%
% Inputs:
%   x                     - Vector of parameters that were the subject of
%                           the prior stage of search.
%   x0                    - Vector of the entire set of parameters of the
%                           model at the time of the start of the
%                           just-completed search
%   floatSet              - Vector of index values that indicate the
%                           mapping of vector x into vector x0 
%   signal                - 1 x time vector. The data to be fit. This
%                           variable is unused in the simple updating case. 
%
% Outputs:
%   x0                    - Vector of the entire set of parameters of the
%                           model to be used in the next stage of search
%

x0(floatSet) = x;

end