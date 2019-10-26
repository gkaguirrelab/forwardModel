function genhrf(obj)
% Creates and stores an HRF using a double-gamma model
%
% Syntax:
%   obj.genhrf
%
% Description:
%   Creates an HRF kernel for convolution. The stored kernel has unit area
%   so that it preserves signal area after convolution. The kernel is
%   specified in a time x 1 vector orientation.
%
%   Typical values for the HRF parameters (which are in units of seconds)
%   are [6 12 10 20].
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
dataDeltaT = obj.dataDeltaT;
hrfParams = obj.hrfParams;

% Unpack hrfParams
gamma1 = hrfParams(1);
gamma2 = hrfParams(2);
gammaScale = hrfParams(3);
duration = hrfParams(4);

% Define an initial timebase for creation in 100 msec units
genDeltaT = 0.1;
timebase = 0:genDeltaT:duration;

% Create the double gamma function
hrf = gampdf(timebase,gamma1, 1) - ...
    gampdf(timebase, gamma2, 1)/gammaScale;

% Set to zero at onset
hrf = hrf - hrf(1);

% Normalize the kernel to have unit area, accounting for the final temporal
% resolution of the vector
areaTimeScale = genDeltaT / dataDeltaT;
hrf = hrf/(sum(abs(hrf)) * areaTimeScale);

% Resample the HRF to the data timebase
hrf = interp1(timebase, hrf, 0:dataDeltaT:ceil(duration/dataDeltaT),'linear',0);

% Store the hrf in the object. Transpose the vector so that it is time x 1
obj.hrf = hrf';

end

