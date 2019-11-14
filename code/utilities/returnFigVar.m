function s = returnFigVar(figHandle)
% Returns a structure with figure data
%
% Syntax:
%   s = returnFigVar(figHandle)
%
% Description:
%   When passed a handle to a figure, the routine will close the figure and
%   return a structure that contains all information needed to recreate the
%   figure. Given the returned structure, "s", this command will
%   reinstantiate the figure:
%
%       figHandle = struct2handle(s.hgS_070000,0,'convert');
%
%   To make an invisible figure visible, use:
%
%       set(figHandle,'Visible','on');
%
% Inputs:
%   figHandle             - Handle to a figure object.
%
% Optional key/value pairs:
%   none
%
% Outputs:
%   s                     - Structure. Contains fields that define the
%                           creation and appearance of a Matlab figure.
%
% Examples:
%{
    % Create a figure with some stuff in it
    figHandle = figure;
    plot(rand(10));
    title('This is my figure');

    % Call the routine. The figure is closed
    s = returnFigVar(figHandle);

    % Invoking struct2handle recreates the figure
    struct2handle(s.hgS_070000,0,'convert');
%}

% Save the figure to a temporary file location
tmpName = tempname;
savefig(figHandle,tmpName);

% Close the figure
close(figHandle)

% Reload the figure data into a structure
s = load([tmpName '.fig'],'-mat','hgS_070000');

end
