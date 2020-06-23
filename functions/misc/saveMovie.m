function [] = saveMovie(frame_handle, frame_parameters, options)
%STABILITYFIGURE creates and saves a movie composed of several frames.
% == Parameters ========================================================================================================
%   1. frame_handle   (function_handle) - function handle for drawing ith frame. It is passed 
%                                              frame_parameters{i}{:}, and must produces the ith frame on current
%                                              figure.
%
%                                                   Inputs:  frame_parameters{i}{:}
%                                                   Outputs: []
%                                           
%   2. frame_parameters (cell)       - a cell array of cell arrays where frame_parameters{i} stores a cell array
%                                      containing all the parameters for drawing the ith frame.
%   4. options  (struct) - options for movie. The fields are as follows:
%       > path (char) save path of movie
%       > drawnow (bool) if true then runs drawnow after each frame.
% ======================================================================================================================

if(nargin < 3)
    options = struct();
end
default_options = {{'path', 'movie.mp4'},{'drawnow', false}};
options = setDefaultOptions(options, default_options);

v = VideoWriter(options.path,'MPEG-4');
open(v);

for i = 1 : length(frame_parameters)
    frame_handle(frame_parameters{i}{:});
    if(options.drawnow)
        drawnow;
    end
    writeVideo(v,getframe(gcf));
end

close(v);
end