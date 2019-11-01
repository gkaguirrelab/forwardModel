function [wm,wsd,dist]=wtmedian(x,sd,cnt)
% wtmedian  Calculate interpolated weighted median & standard deviation
%  2016-11-28  Matlab  Copyright (c) 2016, W J Whiten  BSD License
%
% [wm,wsd,dist]=wtmedian(x,sd,cnt)
% x    Vector of values
% sd   Vector of corresponding standard deviations (default ones(size(x)))
% cnt  Number of repeats for bootstrap calculation (default 1000)
%
% wm   Weighted median
% wsd  Bootstrap estimated standard deviation of weighted median
% dist Bootstrap samples of weighed median i.e. distribution 
%       e.g. n=length(dist);plot(dist,(1:n)/(n+1))
%
% Weighted mean is calculated as interpolated value of x corresponding 
%  to 50% point in cummulative distribution of 1./sd. Note: weights 
%  (1./sd) are placed in a bar graph with ith bar covering i-0.5 to
%  i+0.5 and the cummulative weight distribution is the integral
%  of this. This gives consistent values of the weighted mean but 
%  may differ maginally from other methods of calculation.
% The calculated standard deviation is a bootstrap estimate and as such 
%  will vary slightly. A larger value of cnt will reduce the variation.
% set default values for missing arguments
if(nargin==1)
    sd=ones(size(x));
    cnt=1000;
elseif(nargin==2)
    if(length(sd)==1)
        cnt=sd;
        sd=ones(size(x));
    else
        cnt=1000;
    end
end
% sort data into order
[x,ind]=sort(x);
sd=sd(ind);
% cummulative distribution of weights
sd1=1./sd;
c=cumsum(sd1);
c2=c(end)/2;   % mid point value of distribution
c=c-sd1/2;     % make distribution symmetric about indices
% lower subscript for 50% cummulative weight
m=sum(c<c2);
% proportion for 50% in interval
p=(c2-c(m))/(c(m+1)-c(m));
% weighted median as proportion within interval
wm=x(m)*(1-p)+x(m+1)*p;
% check if sd required
if(nargout>1)
    
    % bootstrap calculation of distribution
    dist=zeros(cnt,1);
    s1=size(sd);
    for i=1:cnt
        % set effective number of values selected (weighted likelihood)
        sd2=sd./sqrt(-log(rand(s1)));
        dist(i)=wtmedian(x,sd2);
    end
    
    % calculate standard deviation
    wsd=std(dist);
    
    % sort distribution if required
    if(nargout==3)
        dist=sort(dist);
    end
end
return
end
