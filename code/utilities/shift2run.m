function f = shift2run(a,b,c)

% function f = conv2run(a,b,c)
%
% <a> is a 2D matrix with time x cases
% <b> is a scalar specifying the number of samples to shift
% <c> is a column vector with the same number of rows as <a>.
% elements should be positive integers.
%
% shift <a> by <b>, returning a matrix the same size as <a>.
% the shift is performed separately for each group indicated
% by <c>. for example, the shift is performed separately
% for elements matching <c>==1, elements matching <c>==2, etc.
% this ensures that there is no shift bleedage across groups.
%
% this function is useful for performing shifts for multiple
% runs (where time does not extend across consecutive runs).
%
% example:
% a = [1 0 0 4 0 0 1 0 0 0 0]';
% b = [1 1 1 1 1]';
% c = [1 1 1 2 2 2 3 3 3 3 3]';
% f = shift2run(a,b,c);
% [a f]


% init
f = zeros(size(a),class(a));

% loop over cases
for p=1:max(c)
  temp = fshift(a(c==p,:),b);
  f(c==p,:) = temp;
end
