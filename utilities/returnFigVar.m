function s = returnFigVar(figHandle)
% Brief one line description of the function
%
% Syntax:
%   outputs = func(inputs)
%
% Description:
%   Foo
%   struct2handle(s.hgS_070000,0,'convert');
%
% Inputs:
%   none
%   foo                   - Scalar. Foo foo foo foo foo foo foo foo foo foo
%                           foo foo foo foo foo foo foo foo foo foo foo foo
%                           foo foo foo
%
% Optional key/value pairs:
%   none
%  'bar'                  - Scalar. Bar bar bar bar bar bar bar bar bar bar
%                           bar bar bar bar bar bar bar bar bar bar bar bar
%                           bar bar bar bar bar bar
%
% Outputs:
%   none
%   baz                   - Cell. Baz baz baz baz baz baz baz baz baz baz
%                           baz baz baz baz baz baz baz baz baz baz baz baz
%                           baz baz baz
%
% Examples:
%{
%}

tmpName = tempname;
savefig(figHandle,tmpName);
close(figHandle)

s = load([tmpName '.fig'],'-mat','hgS_070000');

end
