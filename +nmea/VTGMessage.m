classdef VTGMessage < nmea.Message
% VTG Course over ground and ground speed data
%
%   Defines VTG message with the following fields:
%   track_dir_true - Course over ground in degrees True
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


    methods (Static, Access=protected)
        function val=name_static()
            val='VTG';
        end
        function val=fields_static()
            val=[nmea.Field('track_dir_true',       "%f32 T"),...
                nmea.Field('track_dir_magn',        "%f32 M"),...
                nmea.Field('speed_over_ground_kts', "%f32 N"),...
                nmea.Field('speed_over_ground_kmh', "%f32 K"),...
                nmea.Field('mode_indicator',        "%s",@nmea.Field.mode_postproc)];
        end
    end
end
