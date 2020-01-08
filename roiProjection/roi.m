% region of interest (roi) object
% David S. White
% 2020-01-07

% for use in mZAP

% updates;
% 2020-01-07 DSW created object


classdef roi 
    properties
        info                % file name, etc
        rawData             % image spot for viewing, unmodified time series
        timeSeries          % use for modifications eg background, truncation
        discFit             % result from fitting with DISC
    end
    methods 
        function show(obj)
            figure;
            plot(obj.timeSeries)
        end
    end
end