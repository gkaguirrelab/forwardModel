function signalOut = resamp2run(signalIn,stimAcqGroups,stimTime,dataAcqGroups,dataTime)

signalOut = nan(size(dataAcqGroups));
for ii=1:max(stimAcqGroups)
    
    % The stim time vector corresponding to this acquisition
    acqStimTime = stimTime(stimAcqGroups==ii);
        
    % The data time vector corresponding to this acquisition
    acqDataTime = dataTime(dataAcqGroups==ii);
    
    % Resample the signal to the temporal domain of the data
    acqSignal = interp1(acqStimTime, signalIn(stimAcqGroups==ii),acqDataTime,'linear',0);
    
    % Add this to the growing output fit variable
    signalOut((ii-1)*length(acqSignal)+1:(ii-1)*length(acqSignal)+length(acqSignal)) = acqSignal;
end

% Return in column order
if size(signalOut,1)==1
signalOut = signalOut';
end

end