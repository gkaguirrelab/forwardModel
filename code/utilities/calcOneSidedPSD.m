function [psd, psdSupport] = calcOneSidedPSD( signal, signalSupport )
% Return the power spectral denisty of the input signal.
%
% Syntax:
%  [psd, freqSupport] = calcOneSidedPSD( signal, temporalSupport )
%
% Description:
%   The one-sided power spectrum of the signal. The time-base
%	is set to the one-sided frequency range (in Hz). The length
%   is one-half the input length. The values are in units of power, with
%   each row of the values field corresponding to each row of the values
%   field in the input dataStruct. The sum of the values in the one-sided
%   spectrum is equal to the variance of the input signal
%
% Inputs:
%   signal                - 1xn vector of values that is the time-series
%                           data. Must be of even length (sorry!).
%   signalSupport         - 1xn vector of values (in units of msecs) that
%                           is the temporal support for the signal.
%
% Outputs:
%   psd                   - 1x(n/2) vector of values that is the power at
%                           each frequency
%   psdSupport            - 1x(n/2) vector of values (in units of Hz) that
%                           is the frequency support for the power
%                           spectrum.
%

% Length of the signal
dataLength = length(signal);

% Apologize for not having the solution for odd-length vectors yet
if mod(dataLength,2)
    error('Currently implemented for even-length signals only. Sorry.');
end

% derive the deltaT from the stimulusTimebase (units of msecs)
check = diff(signalSupport);
deltaT = check(1);

% meanCenter
signal = signal - mean(signal);

% Calculate the FFT
X=fft(signal);
psd=X.*conj(X)/(dataLength^2);
psd=psd(1:dataLength/2);

% Produce the psd support in Hz
psdSupport = (0:dataLength/2-1)/(deltaT*dataLength/1000);

end % function