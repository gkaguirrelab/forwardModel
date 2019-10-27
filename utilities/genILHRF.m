
function hrf = genILHRF(t,pp)

% With the constraints that:
%   T2 - T1 > (D1 + D2)k
%
% and
%
%   T3 - T2 > (D2 + D3)k
%
% where k = log10((c^(-1) - 1)^(-1))
%{
    c = 0.99;
    k = log10((c^(-1) - 1)^(-1));
%}
%
% Examples:
%{
    pp = [1.0 15 27 66 1.33 2.5 2]
    t = 0:1:80;
    hrf = genILHRF(t,pp);
    plot(hrf)
%}

ILfun = @(t) exp(t)./(1+exp(t));

d1 = pp(1);
T1 = pp(2);
T2 = pp(3);
T3 = pp(4);
A1 = pp(5);
A2 = pp(6);
A3 = pp(7);
d2 = -d1*(ILfun((1-T1)/A1) - ILfun((1-T3)/A3))/(ILfun((1-T2)/A2) + ILfun((1-T3)/A3));
d3 = abs(d2)-abs(d1);

% Superimpose 3 IL functions
hrf = d1*ILfun((t-T1)/A1)+d2*ILfun((t-T2)/A2)+d3*ILfun((t-T3)/A3); 

end