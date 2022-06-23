function datafile_name = main(...
    PL, ...
    exp_params, ...
    exp_ranges, ...
    plottingObj, ...
    measuring_speed, ...
    measuring_delay, ...
    output_path, ...
    old_data, ...
    study_name, ...
    experiment_name_prefix, ...
    experiment_name_tag, ...
    resurface, ...
    FigAxis, ...
    exp_string, ...
    set_signal, ...
    set_scope, ...
    timeres, ...
    smoothing_value, ...
    testmode,...
    nosource, ...
    stophandle,...
    statusreport, ...
    continuePL_index)
    
%     [frequency, voltage, burst_number] = set_signal;
    hydrophone_sensitivity = set_scope{1};
    vrange = set_scope{2};
    plot_interval = set_scope{3};
    averaging = set_scope{4};
    averaging_count = set_scope{5};

    pathify = @(s) strcat(output_path,'/',s);
    if ~exist(pathify(''),'dir') 
        mkdir(pathify(''));
    end            
    
    experiment_name = [experiment_name_prefix exp_params num2str(length(PL)) experiment_name_tag];
    if continuePL_index ~= 0
        experiment_name = strcat(experiment_name,'_from-',num2str(continuePL_index));
        PL = PL(continuePL_index:end,:);
    end
    datafile_name = strcat(pathify(experiment_name),'.mat');

    if isfile(datafile_name) && isempty(old_data)
        disp('Filename exists already')
        if questdlg({['The file ' datafile_name ' already exists.'], ...
            'You sure you want to overwrite it?'},'Overwrite') ~= "Yes"
            disp('Exiting.')
            return
        else
            disp('File will be overwritten...')
            
        end
    end
    
    
    if isempty(old_data)
    %% 2. Finding devices
    if ~testmode
        FindXYZcontroller();
        ScopeObj = FindOscilloscope();
        if ~nosource
            GenObj = FindGenerator();
        end
        disp("Devices found");
    else
        ScopeObj = [];
        GenObj = [];
        disp("Devices found");
    end
    
        
    %% 3. Device settings
    if ~testmode
        InitXYZcontroller();
    end
    
    if ~testmode
        tleftbound = plot_interval(1);
        trange = plot_interval(2) - tleftbound;
        tdelay = tleftbound + trange/2;
        
        InitOscilloscope(ScopeObj, trange, tdelay, vrange);
        if ~nosource
            InitGenerator(GenObj);
        else
            GenObj = 0;
        end
    end
    disp("Oscilloscope set to measure whole period");
    
    %% 4. Loop over measurement space
    results = MeasureParams(ScopeObj, GenObj, ...
        PL, exp_params, ...
        measuring_speed, measuring_delay, ...
        averaging, averaging_count, ...
        testmode, nosource, stophandle,statusreport);
    
    %% In case of in-loop failure run this cell
    %Move back to start
    if ~testmode
        OpenXYZcontroller();
        MoveStage(0,0,0,100);
        CloseXYZcontroller();
    
        if (resurface == 1)
            MoveStage(0,0,30,100)
        end
        
        %close Oscilloscope
        delete(ScopeObj); clear ScopeObj;
        
        if ~nosource
            %close Generator
            CloseGenerator(GenObj);
            delete(GenObj); clear GenObj;
        end
    end
    
    disp('Experiment done.')
    
    %% 5. Export data4
    if ~isempty(results)
        save(datafile_name,'results','PL','exp_params','exp_ranges','plottingObj', ...
            'measuring_speed','measuring_delay', ...
            'old_data', 'study_name', 'experiment_name', 'experiment_name_prefix', 'experiment_name_tag', ...
            'resurface', 'exp_string', 'set_signal', 'set_scope', 'timeres', 'smoothing_value', ...
            'testmode', 'nosource', '-v7.3');
        disp('Data saved to:');
        disp(datafile_name);
    else
        datafile_name = '';
    end

    %% 6. Finalize movement
    if libisloaded('xyz')
        unloadlibrary('xyz'); % if dll loaded then unload
    end
    
    else %if old_data is specified (not '')
        experiment_name = strcat(experiment_name,'_REPLOT');
%         old_data = old_data;
        disp(['Old data is loaded and displayed: ' old_data])
        if isfile(old_data)
            statusreport.Value = 'Reloading data...';
            statusreport.FontColor = 'blue';
            load(old_data, 'results','PL','exp_params','exp_ranges', ... %Only alter plottingObj, so don't load it.
                'measuring_speed','measuring_delay', ...
                'old_data', 'study_name', 'experiment_name', 'experiment_name_prefix', 'experiment_name_tag', ...
                'resurface', 'exp_string', 'set_signal', 'set_scope', 'timeres', 'smoothing_value', ...
                'testmode');
            datafile_name = old_data;
            statusreport.Value = 'Plot made';
            statusreport.FontColor = 'green';
        else
            statusreport.Value = 'Not a plotable file';
            statusreport.FontColor = 'red';
            datafile_name = '';
            return
        end
    end
    
    %% 7. Show figures
    if ~isempty(results)
%         if length(regexp(exp_params,'[xyz]','match')) == length(exp_params)
        try
            %peak-to-peak plot
            Plot_P2P(FigAxis, results, exp_params, exp_ranges, plottingObj, plot_interval, 1, hydrophone_sensitivity,testmode);
%                     FigureLayout('YZ', exp_ranges, plot_interval);
%                     filename = strcat(experiment_name,'_plot.png');
%                     saveas(gcf,pathify(filename));
        catch e
            statusreport.Value = 'Plot canceled';
            statusreport.FontColor = 'red';

            disp(e)
        end
%         end
    end
        
    %% 8. Finalize
    disp('Exit');
end
