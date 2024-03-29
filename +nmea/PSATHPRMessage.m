classdef PSATHPRMessage < nmea.Message
    methods
        function obj=PSATHPRMessage()
            obj.talker_id_pattern = 'PSAT,';
            obj.msg_id_pattern = 'HPR';
            obj.name = 'PSATHPR';
            cp = nmea.Field.common_patterns;
            obj.fields = [...
                nmea.UTCField, ...
                nmea.Field('heading', "%f32", cp.float),...
                nmea.Field('pitch', "%f32", cp.float),...
                nmea.Field('roll', "%f32", cp.float),...
                nmea.SkipField("\w")];
        end
    end
end