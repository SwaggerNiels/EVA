function InitOscilloscope(ScopeObj, range, delay, vrange)
    % Instrument Configuration and Control

    % Communicating with instrument object, obj1.
    %time base settings%
    OsciStruct.timebase_range=num2str(range);%something like 400E-6
    OsciStruct.timebase_delay=num2str(delay);%something like 200E-6
    OsciStruct.timebase_reference='center';
    %trigger settings%
    OsciStruct.trigger_mode='edge';
    OsciStruct.trigger_source='channel2';
    OsciStruct.trigger_level='-2.0';
    OsciStruct.trigger_slope='positive';
    %acquisition settings%
    OsciStruct.acquire_type='average'; %average% %normal%
    OsciStruct.acquire_count='1024';
%     OsciStruct.acquire_srate='4E9'; %not working
    %waveform settings%
    OsciStruct.waveform_points_mode='raw';
    OsciStruct.waveform_points='10000';
    %channel1 settings%
    OsciStruct.ch1_display='1';
    OsciStruct.ch1_probe='1';
    OsciStruct.ch1_range=num2str(vrange);%something like 1400E-3
    OsciStruct.ch1_offset='0';
    OsciStruct.ch1_coupling='DC';
    OsciStruct.ch1_impedance='fifty'; %ONEMeg%
    %channel2 settings%
    OsciStruct.ch2_display='0';
    OsciStruct.ch2_probe='1';
    OsciStruct.ch2_range='40';
    OsciStruct.ch2_offset='-10';
    OsciStruct.ch2_coupling='DC';
    OsciStruct.ch2_impedance='onemeg'; %ONEMeg%
    %channel3 settings%
    OsciStruct.ch3_display='0';
    OsciStruct.ch3_probe='1';
    OsciStruct.ch3_range='20';
    OsciStruct.ch3_offset='0';
    OsciStruct.ch3_coupling='DC';
    OsciStruct.ch3_impedance='onemeg'; %ONEMeg%
    %channel4 settings%
    OsciStruct.ch4_display='0';
    OsciStruct.ch4_probe='1';
    OsciStruct.ch4_range='20';
    OsciStruct.ch4_offset='5';
    OsciStruct.ch4_coupling='DC';
    OsciStruct.ch4_impedance='onemeg'; %ONEMeg%
    
    fopen(ScopeObj);
    Config_Equipment('oscilloscope',ScopeObj,OsciStruct,1);
    fclose(ScopeObj);
end

function Config_Equipment(type,obj,cfgstruct,cfgtype)
    %type='oscilloscope' or 'fgenerator'%
    %obj = equipment object file%
    %cfgtype=1,2,3,4 (for oscilloscope channels), 5 (for general oscilloscope
    %configuration,6 (function generator channel config), 7 (function generator general config) 
    
    
    if(strcmp(type,'oscilloscope')==1)
    
        if(cfgtype==5||cfgtype==1)
    %         fprintf(obj,'*RST; :AUTOSCALE');
            fprintf(obj,'DISPlay:INTensity:WAVeform 80');
            
            % fprintf(obj,':STOP');
    %         pause(3);
            %Configure timebase
            fprintf(obj,strcat('TIMebase:RANGe ',32,cfgstruct.timebase_range));
            fprintf(obj,strcat('TIMebase:DELay ',32,cfgstruct.timebase_delay));
            fprintf(obj,strcat('TIMebase:REFerence ',32,cfgstruct.timebase_reference));
            CheckError('time',obj);
            
            %Configure Trigger
            fprintf(obj,strcat('TRIGger:MODE ',32,cfgstruct.trigger_mode)); %Normal triggering
            fprintf(obj,strcat('TRIGger:SOURCe ',32,cfgstruct.trigger_source)); %Normal triggering
            fprintf(obj,strcat('TRIGger:LEVel ',32,cfgstruct.trigger_level)); %' Trigger level to whatever.
            fprintf(obj,strcat('TRIGger:SLOPe ',32,cfgstruct.trigger_slope)); %' Trigger on pos. slope.
            CheckError('trigger',obj);
            
           %configure acquisition
            fprintf(obj,strcat(':ACQUIRE:TYPE ',32,cfgstruct.acquire_type));
            fprintf(obj,strcat(':ACQUIRE:COUNT ',32,cfgstruct.acquire_count));
%             fprintf(obj,strcat(':ACQUIRE:SRATe ',32,cfgstruct.acquire_srate));
            CheckError('acquisition',obj);
            
            %configure waveform
            fprintf(obj,strcat(':WAV:POINTS:MODE ',32,cfgstruct.waveform_points_mode));
            fprintf(obj,strcat(':WAV:POINTS ',32,cfgstruct.waveform_points));
            CheckError('waveform',obj);
        end
        
        if(cfgtype==5||cfgtype==1)
            fprintf(obj,strcat('CHANnel1:DISPlay ',32,cfgstruct.ch1_display)); %Turn on channel display.
            fprintf(obj,strcat('CHANnel1:PROBe ',32,cfgstruct.ch1_probe)); %Probe attenuation to 1:1.
            fprintf(obj,strcat('CHANnel1:RANGe ',32,cfgstruct.ch1_range)); %' Vertical range 10 V full scale.
            fprintf(obj,strcat('CHANnel1:OFFSet ',32,cfgstruct.ch1_offset)); %' Offset to -20.
            fprintf(obj,strcat('CHANnel1:COUPling ',32,cfgstruct.ch1_coupling)); %' Coupling to DC.
            fprintf(obj,strcat('CHANnel1:IMP ',32,cfgstruct.ch1_impedance)); %' impedance
            CheckError('chan1',obj);
        end
        if(cfgtype==5||cfgtype==2)
            fprintf(obj,strcat('CHANnel2:DISPlay ',32,cfgstruct.ch2_display)); %Turn on channel display.
            fprintf(obj,strcat('CHANnel2:PROBe ',32,cfgstruct.ch2_probe)); %Probe attenuation to 1:1.
            fprintf(obj,strcat('CHANnel2:RANGe ',32,cfgstruct.ch2_range)); %' Vertical range 10 V full scale.
            fprintf(obj,strcat('CHANnel2:OFFSet ',32,cfgstruct.ch2_offset)); %' Offset to -20.
            fprintf(obj,strcat('CHANnel2:COUPling ',32,cfgstruct.ch2_coupling)); %' Coupling to DC.
            fprintf(obj,strcat('CHANnel2:IMP ',32,cfgstruct.ch2_impedance)); %' impedance
            CheckError('chan2',obj);
        end
        if(cfgtype==5||cfgtype==3)
            fprintf(obj,strcat('CHANnel3:DISPlay ',32,cfgstruct.ch3_display)); %Turn on channel display.
            fprintf(obj,strcat('CHANnel3:PROBe ',32,cfgstruct.ch3_probe)); %Probe attenuation to 1:1.
            fprintf(obj,strcat('CHANnel3:RANGe ',32,cfgstruct.ch3_range)); %' Vertical range 10 V full scale.
            fprintf(obj,strcat('CHANnel3:OFFSet ',32,cfgstruct.ch3_offset)); %' Offset to -20.
            fprintf(obj,strcat('CHANnel3:COUPling ',32,cfgstruct.ch3_coupling)); %' Coupling to DC.
            fprintf(obj,strcat('CHANnel3:IMP ',32,cfgstruct.ch3_impedance)); %' impedance
            CheckError('chan3',obj);
        end
        if(cfgtype==5||cfgtype==4)
            fprintf(obj,strcat('CHANnel4:DISPlay ',32,cfgstruct.ch4_display)); %Turn on channel display.
            fprintf(obj,strcat('CHANnel4:PROBe ',32,cfgstruct.ch4_probe)); %Probe attenuation to 1:1.
            fprintf(obj,strcat('CHANnel4:RANGe ',32,cfgstruct.ch4_range)); %' Vertical range 10 V full scale.
            fprintf(obj,strcat('CHANnel4:OFFSet ',32,cfgstruct.ch4_offset)); %' Offset to -20.
            fprintf(obj,strcat('CHANnel4:COUPling ',32,cfgstruct.ch4_coupling)); %' Coupling to DC.
            fprintf(obj,strcat('CHANnel4:IMP ',32,cfgstruct.ch4_impedance)); %' impedance
            CheckError('chan4',obj);
        end
    end
end

function CheckError(tag,ScopeObj)
    instrumentError = query(ScopeObj,':SYSTEM:ERR?');
%     disp(strcat(tag,", found errors:"))
    while ~isequal(instrumentError,['+0,"No error"' char(10)])
        disp(['Instrument Error: ' instrumentError]);
        instrumentError = query(ScopeObj,':SYSTEM:ERR?');
    end
end