classdef Message < matlab.mixin.Heterogeneous
% Generic NMEA messages class. This is an abstract class that is used to
% define NMEA messages and cannot be used directly, apart from the static
% method get_all_messages.
%
% Message properties (read only):
%   regular_expression - for a generic NMEA string
%   fields - returns the fields in the current message
%   format - returns the format for use with textscan
%   name - name of the message, same as message identifier in the message
%
% Message methods:
%   parse - parse a string containing nmea messages
%   checksum_is_valid - check validity of NMEA checksum
%
% Message methods (static):
%   get_all_messages - returns all available NMEA messages
%   parse_all - parse nmea data
%
% Message abstract methods:
%
%   name_static - defining the msg_id of the message
%   fields_static - returning the fields in the message
%  
%   see also:nmea, nmea.Field
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


    properties(Access = protected)
        regexp_talker_id (1,:) char = '(?<talker_id>[a-zA-Z]{2})';
        regexp_msg_id (1,:) char = '(?<msg_id>[a-zA-Z]{3})';
        regexp_content (1,:) char = '(?<content>(?:,[^,\*]*)*)';
        regexp_csum (1,:) char = '(?<csum>\*[a-fA-F0-9]{2})';
    end
    properties(Dependent, SetAccess=protected)
% nmea.Message/regular_expression read only property
%
%   returns the regular expression defining a generic NMEA string.
%
%   see also: nmea, nmea.Message
        regular_expression
        
% nmea.Message/fields read only property
%
%   returns an array of nmea.Field defining the data in the nmea message
%
%   see also: nmea, nmea.Message, nmea.Field
        fields
        
% nmea.Message/format read only property
%
%   returns a concatenation of the format strings defined in the fields, to
%   be used with textscan to extract data from NMEA messages.
%
%   see also: nmea, nmea.Message, nmea.Field, textscan
        format

% nmea.Message/name read only property
%
%   returns the name of the current message. Matches with the message
%   identiefier in the NMEA message. Three characater row vector.
%
%   see also: nmea, nmea.Message
        name
    end
    methods
        function val=get.name(obj)
            val=obj.name_static();
        end
        function val=get.regular_expression(obj)
            val=['\$',obj.regexp_talker_id, obj.regexp_msg_id, obj.regexp_content, obj.regexp_csum];
        end
        function val=get.fields(obj)
            val=obj.fields_static();
        end
        function val=get.format(obj)
            val=join([obj.fields.format]);
        end
    end
    methods (Access=protected)
        function out = post_process(obj,in)
            idx_dat=1;
            if isscalar(obj)
                for cf=1:numel(obj.fields)
                    out.(obj.fields(cf).name)=obj.fields(cf).post_process(in(idx_dat:idx_dat+obj.fields(cf).n_formats-1));
                    idx_dat=idx_dat+obj.fields(cf).n_formats;
                end
            else
                error('running post_process on object array not supported')
            end
        end
    end
    methods (Sealed)
        function dat=parse(obj,str)
% function to parse NMEA data
%
%   dat=parse(obj,str) will parse the string data in str, using the
%   Messgages defined in the nmea.Message array obj. Returns a structure
%   containing one field with the name of the message, that holds a
%   structure with all the data read by the message.
%   Next to the message data each of the message structures will contain
%   the following additional fields:
%
%   talker_id - holding the talker ID of the nmea messages
%   char_pos - holding the starting position of the message in str. This
%   differs when str is a array of characters of a string array or a cell
%   of character arrays. See help of MATLAB builtin regexp function for an
%   explanation of its format.
%
%   see also: nmea, nmea.Message, get_all_messages, regexp
            % generic NMEA part
            dat=struct;
            [msgs,matched,pos]=regexp(str,obj(1).regular_expression,'names','match','start'); % find NMEA strings
            if isempty(msgs)
                return
            end
            isvalid=nmea.Message.checksum_is_valid(matched); % check checksum
            msgs(~isvalid)=[]; % remove invalid strings
            pos(~isvalid)=[];
            clearvars matched isvalid % clear unused data
            
            % process individual messages
            for co=1:numel(obj)
                msg_idx=strcmp({msgs.msg_id}, obj(co).name); % find strings with right message id
                if ~any(msg_idx)
                    continue
                end
                dat.(obj(co).name)=textscan(strjoin({msgs(msg_idx).content}+",",'\n'),","+obj(co).format,'Delimiter',','); % convert the data (trailing comma added to correctly read null f
                dat.(obj(co).name)=obj(co).post_process(dat.(obj(co).name));
                dat.(obj(co).name).talker_id=vertcat(msgs(msg_idx).talker_id);
                dat.(obj(co).name).char_pos=reshape(pos(msg_idx),[],1);
            end
        end 
    end
    methods (Abstract, Static, Access=protected)
% returns the message identifier of the message
%
%   val=name_static() returns a three element row vector of characters
%   holding the message identifier for the current message.
%
%   see also: nmea, nmea.Message
        val=name_static();

% returns the fields held in the message
%
%   val=fields_static() returns the fields in the current message as an
%   array of nmea.Field objects. 
%
%   see also: nmea, nmea.Message, nmea.Field
        val=fields_static();
    end
    methods (Static, Sealed)
        function val=checksum_is_valid(str)
% Checks validity of NMEA message checksum
%
%   val=checksum_is_valid(str) returns whether checksum of message in str
%   is correct. If a cell of strings or string array is given returns
%   validity of each message.
%
%   see also: nmea, nmea.Message
            if ischar(str)
                msgu = uint8(str(2:end-3));    % convert characters in string to numbers
                cs_calc=zeros(1,'uint8');
                for count = 1:length(msgu)       
                    cs_calc = bitxor(cs_calc,msgu(count));
                end
                val=hex2dec(str(end-1:end))==cs_calc;
            elseif iscellstr(str) || isstring(str)
                val=cellfun(@nmea.Message.checksum_is_valid,str);
            end
        end
        function msgs=get_all_messages()
% Returns array with all available NMEA message objects
%
%   msgs=get_all_messages() Returns array with all available NMEA messages.
%   see under 'see also' below, for supported messages.
%
%   see also: nmea, Message, GGAMessage, VTGMessage, HDTMessage,
%   ZDAMessage, GMPMessage, TROMessage, LINMessage, SPDMessage, ROTMessage,
%   INFMessage
            msgs=[nmea.GGAMessage;...
              nmea.VTGMessage;...
              nmea.HDTMessage;...
              nmea.ZDAMessage;...
              nmea.GMPMessage;...
              nmea.TROMessage;...
              nmea.LINMessage;...
              nmea.SPDMessage;...
              nmea.ROTMessage;...
              nmea.INFMessage];
        end
        function val=parse_all(str)
% Parse string data using all available messages
%
%   dat=nmea.Message.parse_all(str) reads all known messages in the given
%   string or cell of character arrays and returns the data available per
%   message.
%
%   see also: nmea, Message, parse
           msgs=nmea.Message.get_all_messages();
           val=msgs.parse(str);
        end
    end
end