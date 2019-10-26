function signalOut = resamp2run(signalIn,stimAcqGroups,stimTime,dataAcqGroups,dataTime)

signalOut = [];
for ii=1:max(stimAcqGroups)
    
    % The stim time vector corresponding to this acquisition
    acqStimTime = stimTime(stimAcqGroups==ii);
        
    % The data time vector corresponding to this acquisition
    acqDataTime = dataTime(dataAcqGroups==ii);
    
    % Resample the signal to the temporal domain of the data
    acqSignal = interp1(acqStimTime, signalIn(stimAcqGroups==ii),acqDataTime,'linear',0);
    
    % Add this to the growing output fit variable
    signalOut = [signalOut acqSignal];
end

% Transpose the vector to return in column order
signalOut = signalOut';

end