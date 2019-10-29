function x0 = initial(obj)
% Returns initial guess for the model parameters
%
% Syntax:
%   x0 = obj.initial()
%
% Description:
%   Initial values for the flobsHRF model. Values taken from:
%       https://www.fmrib.ox.ac.uk/datasets/techrep/tr04mw2/tr04mw2/node9.html
%
% Inputs:
%   none
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   x0                    - 1xnParams vector.
%


% Obj variables
nParams = obj.nParams;

% Assign the x0 variable
x0 = zeros(1,nParams);

% Assemble X0
x0(1) = 0.86;           % eigen1
x0(2) = 0.09;           % eigen2
x0(3) = 0.01;           % eigen3

end

