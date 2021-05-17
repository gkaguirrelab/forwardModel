function [flatTime, breaks] = accumTimeMatrix(dataTime,dataAcqGroups,deltaT)

flatTime = [];
breaks = 0;
idx = 1;
startTime = 0;
for ii = 1:max(dataAcqGroups)    
    flatTime = [flatTime; startTime+dataTime(dataAcqGroups==ii)+deltaT];
    idx = length(flatTime)+1;
    startTime = max(flatTime);
    breaks = [breaks; startTime];
end


end

