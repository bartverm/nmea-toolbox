classdef Field < handle
% Defines a NMEA field in a NMEA message
%
%   Field properties:
%   name - string with field name
%   format - string array with the format of the fields in the NMEA message
%   post_process - post processing function for field data
%
%   Field properties (read only)
%   n_formats - number of format fields to be read
%
%   Field methods (static):
%   default_postproc - default post processing
%   latlong_postproc - latitude, longitude post processing
%   utc_postproc - UTC time post processing
%   mode_postproc - GPS mode post processing
%
%   see also: nmea, nmea.Message
%
%   Copyright 2020, Bart Vermeulen

%     This file is part of the NMEA toolbox.
% 
%     NMEA toolbox is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     NMEA toolbox is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with NMEA toolbox.  If not, see <https://www.gnu.org/licenses/>.



    properties
        % nmea.Field/name property
        %
        %   scalar string holding name of field in output structure
        %   produced by nmea.Message.parse. Default: "field"
        %
        % see also: nmea, nmea.Field, nmea.Message
        name (1,1) string = "field"
        
        % nmea.Field/format property
        %
        %   scalar or row vector of strings holding fields to be read from
        %   NMEA message. See textscan for how the format of these strings.
        %   Default: "%s"
        %
        %   see also: nmea, nmea.Field, nmea.Message, textscan
        format (1,:) string = "%s"
        
        % nmea.Field/post_process property
        %
        %   scalar function handle of function to be called to post-process
        %   data after reading. This function should accept one input which
        %   holds a cell array with one cell element for each format string
        %   given. The function returns the processed data. Default:
        %   @nmea.Field.default_postproc
        %
        %   see also: nmea, nmea.Field, nmea.Field.default_postproc
        post_process (1,:) function_handle = @nmea.Field.default_postproc
    end
    properties (Dependent, SetAccess = private)
        % nmea.Field/n_formats dependent, read only property
        %
        %   n=obj.n_formats()
        %   returns the total number of format fields defined in the Field
        %   objects obj from which the function is called.
        %
        %   see also: nmea, format, nmea.Field
        n_formats
    end
    methods
        function obj = Field(varargin)
            if nargin > 0
                obj.name=varargin{1};
            end
            if nargin > 1
                obj.format=varargin{2};
            end
            if nargin > 2
                obj.post_process=varargin{3};
            end
        end
        function val=get.n_formats(obj)
            val=numel(obj.format);
        end
    end
    methods(Static)
        function out=default_postproc(in)
% returns content of scalar cell, or cell itself when non scalar
%
%   Default post-processing function. If input is a scalar cell, returns
%   the content of the cell. Otherwise returns the cell itself (no change).
%
%   see also: nmea, nmea.Field, latlong_postproc, utc_postproc,
%   mode_postproc
            if isscalar(in)
                out=in{1};
            else
                out=in;
            end
        end
        function out=latlong_postproc(in)
% Returns latitude and longitude in signed decimal degrees
%
%   out=latlong_postproc(in) given the two element cell in, computes the
%   latitude and longitude in decimal degrees. Latitude and longitude are
%   returned negative for South latitude and East longitudes.
%
%   see also: nmea, nmea.Field, latlong_postproc, utc_postproc,
%   mode_postproc
            out=((in{3}=='N' | in{3}=='W')*2-1).*(in{1}+in{2}/60);
        end
        function out=utc_postproc(in)
% Returns Nx3 UTC time with hours, minutes, days
%
%    out = utc_postproc(in) concatenates horizontally the three elements in
%    the input cell
%
%   see also: nmea, nmea.Field, latlong_postproc, utc_postproc,
%   mode_postproc
            out=[in{:}];
        end
        function out=mode_postproc(in)
% Returns GPSMode array from string input representing the GPS mode
%
%   out = mode_postproc(in) returns an array of type nmea.GPSMode holding
%   the type of GPS fix, given the characters in the input cell in.
%
%   see also: nmea, nmea.Field, latlong_postproc, utc_postproc,
%   mode_postproc, nmea.GPSMode
            out=nmea.GPSMode(ones(size(in{1}),'uint8')*255);
            out(cellfun(@(x) ~isempty(x),in{1}))=nmea.GPSMode(uint8([in{1}{:}]));
        end
    end
end