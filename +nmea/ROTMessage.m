classdef ROTMessage < nmea.Message
% Octans rotation rate message
%
%   Defines ROT Octans message with the following fields:
%   x_rot - rotation around x axis in degrees/s (signed)
%   y_rot - rotation around y axis in degrees/s (signed)
%   z_rot - rotation around z axis in degrees/s (signed)
%
%   see also: nmea, nmea.Message
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
            val='ROT';
        end
        function val=fields_static()
            val=[nmea.Field('x_rot',"%f32"), ...
                 nmea.Field('y_rot', "%f32"),...
                 nmea.Field('z_rot', "%f32")];
        end
    end
end