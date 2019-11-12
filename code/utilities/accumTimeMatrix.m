function [flatTime, breaks] = accumTimeMatrix(timeMatrix, deltaT)

flatTime=timeMatrix(1,:);
breaks(1) = timeMatrix(1,end);

if size(timeMatrix,1)>1
    for ii=2:size(timeMatrix,1)
        block = timeMatrix(ii,:)+flatTime(end)+deltaT;
        flatTime = [flatTime block];
        breaks(ii) = flatTime(end);
    end
end

end

