function data = Plot_P2P(ax, results, exp_params, exp_ranges, plottingObj, interval, p2p_res, hydrophone_sensitivity,testmode)
    %Plot_P2P
    %   results is formated as cell array of structs. The cells contain
    %   time traces (waveforms) with XData and YData. These are converted
    %   to a static 2D image with a single pixel per cell/trace, to
    %   illustrate the max peak-to-peak (and vmax value) in a given time interval.
    
    %   interval is the time period considered from the original sample.
    %   The spaceres is the spatial resolution used (only for title of
    %   plot). Lastly, the p2p_resolution can be used to discretize the
    %   peak-to-peak measurement, making use that different peaks don't
    %   contribute to eachothers max/min values (only use when 
    %   many/off-baseline peaks are present in the sample interval 
    %   else set to 1).
    DEBUG = 0;
    
    plottingObj.interval = interval;
    plottingObj.p2p_res = p2p_res;
    plottingObj.hydrophone_sensitivity = hydrophone_sensitivity;

    %Reshape when multiple parameter dimensions
    if DEBUG disp('Initial -> reshaped (non 1D)'), end
    if DEBUG size(results), end
    
    switch length(exp_ranges)
        case 2        
            er1 = exp_ranges{1};
            er2 = exp_ranges{2};
            
            [P1,P2] = meshgrid(er1,er2);
            P2(:,2:2:end) = flipud(P2(:,2:2:end));

            PL = [P1(:) P2(:)];

            [~,idx] = sort(PL(:,2));
            [~, idx] = sort(idx);
            [~, order_I] = sort(idx);
            results = results(order_I);

            shape = [length(exp_ranges{1}),length(exp_ranges{2})];
            
            results = transpose(reshape( results, shape ));
            results = permute(results,[2,1]);
             
            if DEBUG size(results), end
        case 3
            er1 = exp_ranges{1};
            er2 = exp_ranges{2};
            er3 = exp_ranges{3};
        
            [P2,P3,P1] = meshgrid(er2,er3,er1);
            
            P3 = flipEvenDim(P3,2,@flipud);
            P3 = flipEvenDim(P3,3,@flipud);
            P3 = flipEvenDim(P3,3,@fliplr);

            PL = [P1(:) P2(:) P3(:)];

            [~,idx] = sort(PL(:,3));
            [~, idx] = sort(idx);
            [~, order_I] = sort(idx);

            results = results(order_I);
            
            shape = [length(er2),length(er1),length(er3)];
            
            results = reshape(results,shape);
            results = flipEvenDim(results,2,@flipud);
            results = permute(results,[2,1,3]);

            if DEBUG size(results), end
    end

    %Apply plotting conversion
    [plottingObj, data,exp_params,exp_ranges] = PlotObjApply(plottingObj, results, exp_params, exp_ranges, testmode, DEBUG);
    disp('Data transformed')
    if DEBUG size(data), end
    
    ll = plottingObj.parameter_labels;
    pp = plottingObj.params;

    %Display the data
    cla(ax, "reset");

    %check if signal selected
    if isfield(plottingObj,'signal_select')
        if ~isequal(plottingObj.signal_select{1},'no')
            disp("Signal plot")
            
            t = data.XData;
            y = data.YData;

            %conversions
            try
                if isequal(plottingObj.signal_select{2},'distance')
                    t = (plottingObj.acoustic_speed).*t;
                end
            catch
                disp('PLOTTING: Signal time->distance not possible')
            end

            try
                if isequal(plottingObj.signal_select{3},'pascal')
                    y = y./plottingObj.hydrophone_sensitivity;
                end
            catch
                disp('PLOTTING: Signal time->distance not possible')
            end

            plot(ax, t, y);
            
            %limits
            ymm = [min(y) max(y)];
            ydif = ymm(2) - ymm(1);
            xlim(ax,[min(t) max(t)]);
            ylim(ax,[ymm(1)-ydif*.1, ymm(2)+ydif*.1]);

            %peak
            try
                if isequal(plottingObj.signal_select{4},'peak')
                    [up,~] = envelope(y);
                    up = movmean(up,round(length(t)/100));
                    up = movmedian(up,round(length(t)/100));
                    mask = (up > mean(abs(up)));
                    mask_ind = find(mask,1);
                    env = up(mask);
                    [pks,locs] = findpeaks(env);
                    hold(ax,"on");
                    plot(t,up,'-',t(mask_ind+locs),pks,'or');
                    hold(ax,"off");
                end
            catch
                disp('PLOTTING: Signal peak detection not possible')
            end

            %onset
            try
                if isequal(plottingObj.signal_select{5},'onset')
                    y_detect = up.*abs(y);
                    onset = find(y_detect > mean(y_detect)+.001*(max(y_detect)-mean(y_detect)),1);
                    hold on
                    plot(t(onset),y(onset),'ro')
                    hold off
                end
            catch
                disp('PLOTTING: Signal onset detection not possible')
            end

            %labelling
            title(ax, [plottingObj.f_label('') ...
                ,['max(p2p)=' num2str(peak2peak(y))]])
            xlabel('Time [s]');
            ylabel('Volt [V]');
            
            if isequal(plottingObj.signal_select{2},'distance')
                xlabel('Traversed distance of signal [m]');
            end
            if isequal(plottingObj.signal_select{3},'pascal')
                ylabel('Pressure [Pa]');
            end

            return
        end
    end

    %plot data in correct dimensionality
    switch length(exp_ranges)
        case 1
            disp("1D plot")
            
            plot(ax, exp_ranges{1}, data);

            %labelling
            xlabel(ax, ll(find(pp == exp_params(1)),2) );
            ylabel(ax, plottingObj.f_label('Acoustic peak-to-peak pressure [Pa]'));
        case 2
            disp("2D plot")
            data = permute(data,[2,1]);

            image(ax, exp_ranges{1}, exp_ranges{2}, data, 'CDataMapping','scaled');
        
            %Manual limit selection
            if isfield(plottingObj,'manual_limits')
                if length(plottingObj.manual_limits) ~= 1
                    if plottingObj.manual_limits(1) < plottingObj.manual_limits(2)
                        caxis(ax, plottingObj.manual_limits);
                    end
                end
            end

            c = colorbar(ax);
            set(ax, 'YDir', 'normal');
            
            %labelling
            xlabel(ax,  ll(find(pp == exp_params(1)),2) );
            ylabel(ax,  ll(find(pp == exp_params(2)),2) );
            
            ylabel(c, plottingObj.f_label('Acoustic peak-to-peak pressure [Pa]'));
        case 3
            disp('3D plot')
            
            er1 = exp_ranges{1};
            er2 = exp_ranges{2};
            er3 = exp_ranges{3};

            xslice = ([max(er1), er1(round(end/2))]);
            yslice = ([max(er2), er2(round(end/2))]);
            zslice = ([min(er3), er3(round(end/2))]);

            if isfield(plottingObj,'alternate_3D')
                switch plottingObj.alternate_3D
                    case 'scatter'
                        [X,Y,Z] = meshgrid(er1,er2,er3);
                        scatter3(ax, X(:),Y(:),Z(:) , [], data(:), "filled", ...
                            "MarkerFaceAlpha", .5);
                    case 'isosurface'
                        [X,Y,Z] = meshgrid(er1,er2,er3);
                        
                        N = 8;
                        color = jet(N);
                        colormap(jet)
                        v = linspace(min(data(:)),max(data(:)),N);

                        hold(ax,"on")
                        for kk = 1:N
                            p = patch(ax, isosurface(X,Y,Z,data,v(kk)),...
                                'FaceColor',    color(kk,:),...
                                'EdgeColor',    'none',...
                                'FaceAlpha',    0.2);
                            isonormals(X,Y,Z,data,p)
                        end

                        lighting gouraud
                    otherwise
                        slice(ax, er1, er2, er3, data, xslice, yslice, zslice);
                end
            else
                slice(ax, er1, er2, er3, data, xslice, yslice, zslice);
            end

            ylim(ax, [min(er2),max(er2)])
            view(ax, -34,24);

            %labelling
            xlabel(ax,  ll(find(pp == exp_params(1)),2) );
            ylabel(ax,  ll(find(pp == exp_params(2)),2) );
            zlabel(ax,  ll(find(pp == exp_params(3)),2) );

            cb = colorbar(ax);
            ylabel(cb, plottingObj.f_label('Acoustic peak-to-peak pressure [Pa]'));
    end

    return
end

function [po, data,exp_params,exp_ranges] = PlotObjApply(po, results, exp_params, exp_ranges, testmode, DEBUG)

    %Signal to peak-to-peak pressure value
    if DEBUG disp('Get P2P values'), end
    f_p2p = @(struct) p2p_local(struct, po.interval, po.p2p_res);
    if testmode
        f_p2p = @(struct) max(struct.YData);
    end
    vp2p = cellfun(f_p2p,squeeze(results));
    data = vp2p/po.hydrophone_sensitivity; %pressure peak to peak
    label_add = '';

    %Normalisation
    switch po.normalise
        case 'no'
        case 'all'
            data = data./max(data(:));
            label_add = [label_add 'normalised'];
        case '1'
            data = normalize(data,1,'range');
            label_add = [label_add 'p1-normalised'];
        case '2'
            data = normalize(data,2,'range');
            label_add = [label_add 'p2-normalised'];
        otherwise
            disp("PLOTTING: Normalisation not possible");
    end

    %Dimension reduction
    if ~isequal(po.reduced_dimension,'no')
        reduced_dimension = str2num(po.reduced_dimension);
        reduced_param = exp_params(reduced_dimension);
        
        ll = po.parameter_labels;
        pp = po.params;
        param_label = ll(find(pp == exp_params(reduced_dimension)),2);
        [param_name,param_unit] = getParamNameAndUnit(param_label);

        if DEBUG disp('Reducing...'), end
        %Reduce dimension based on summary statistic
        try
            switch po.reduce_method
                case 'max'
                    label_add = [label_add 'maximum' param_name];
                    data = max(data,[],reduced_dimension);
                case 'min'
                    label_add = [label_add 'minimum' param_name];
                    data = min(data,[],reduced_dimension);
                case 'var'
                    label_add = [label_add 'variance in' param_name];
                    data = var(data,0,reduced_dimension);
                case 'std'
                    label_add = [label_add 'standard deviation in' param_name];
                    data = std(data,0,reduced_dimension);
                case 'mean'
                    label_add = [label_add 'mean' param_name];
                    data = mean(data,reduced_dimension);
                case 'median'
                    label_add = [label_add 'median' param_name];
                    data = median(data,reduced_dimension);
                otherwise
                    if startsWith(po.reduce_method,'select')                        
                        if DEBUG disp('by selection'), end

                        ms = convertStringsToChars(po.reduce_method);
                        si = ms(8:end);
                        si = str2num(si);
                        er = exp_ranges{reduced_dimension};
                        label_add = [label_add 'selected: ' ...
                            param_name(1:end-1) '=' num2str(er(si)) param_unit];
                        dims = length(size(data));

                        switch dims
                            case 3
                                if DEBUG disp('3D->2D'), end
                                if DEBUG size(data), end

                                switch reduced_dimension
                                    case 3
                                        data=data(:,:,si);
                                    case 1
                                        data=permute(data(si,:,:),[2 3 1]);
                                    case 2
                                        data=permute(data(:,si,:),[1 3 2]);
                                end

                                if DEBUG size(data), end

                            case 2
                                if DEBUG disp('2D->1D'), end
                                if DEBUG size(data), end

                                switch reduced_dimension
                                    case 1
                                        data = data(si,:);
                                    case 2
                                        data = data(:,si);
                                end
                                
                                if DEBUG size(data), end

                        end
                    else
                        disp('PLOTTING: Reduction not possible, unknown function')
                    end
            end
            data = squeeze(data);

            %keep only dimensions left
            keep_dims = (1:length(exp_ranges));
            keep_dims = keep_dims(find(keep_dims ~= reduced_dimension));
            exp_ranges = exp_ranges(keep_dims);
            exp_params = exp_params(keep_dims);

            if DEBUG disp('Reduced succesfully'), end
        catch
            disp('PLOTTING: Reduction not possible')
        end
    end
    
    %Signal selection
    if isfield(po,'signal_select')
        if ~isequal(po.signal_select{1},'no')
            try
                sig_i = str2num(po.signal_select{1});

                er = exp_ranges;

                ll = po.parameter_labels;
                pp = po.params;    
            
                switch length(sig_i)
                    case 1
                        i1 = sig_i;
                        
                        param_label1 = ll(find(pp == exp_params(1)),2);
                        [param_name1,param_unit1] = getParamNameAndUnit(param_label1);
                        label_add = ['Signal at ' ...
                            param_name1 '=' num2str(er(i1)) param_unit1];
    
                        data = results{i1};
                    case 2
                        data = permute(results,[2,1]);

                        i1 = sig_i(1);
                        i2 = sig_i(2);

                        er1 = er{1};
                        er2 = er{2};
                        param_label1 = ll(find(pp == exp_params(1)),2);
                        [param_name1,param_unit1] = getParamNameAndUnit(param_label1);
                        param_label2 = ll(find(pp == exp_params(2)),2);
                        [param_name2,param_unit2] = getParamNameAndUnit(param_label2);
                        label_add = ['Signal at ' ...
                            param_name1 '=' num2str(er1(i1)) param_unit1 ',' ...
                            param_name2 '=' num2str(er2(i2)) param_unit2];
    
                        data = data{i1,i2};
                    case 3
                        data = permute(results,[2,1,3]);

                        i1 = sig_i(1);
                        i2 = sig_i(2);
                        i3 = sig_i(3);

                        er1 = er{1};
                        er2 = er{2};
                        er3 = er{3};
                        param_label1 = ll(find(pp == exp_params(1)),2);
                        [param_name1,param_unit1] = getParamNameAndUnit(param_label1);
                        param_label2 = ll(find(pp == exp_params(2)),2);
                        [param_name2,param_unit2] = getParamNameAndUnit(param_label2);
                        param_label3 = ll(find(pp == exp_params(3)),2);
                        [param_name3,param_unit3] = getParamNameAndUnit(param_label3);
                        label_add = ['Signal at ' ...
                            param_name1 '=' num2str(er1(i1)) param_unit1 ',' ...
                            param_name2 '=' num2str(er2(i2)) param_unit2 ',' ...
                            param_name3 '=' num2str(er3(i3)) param_unit3];
    
                        data = results{i1,i2,i3};
                    otherwise
                        disp('Wrong number of dimensions for signal selection')
                end
            catch
                disp('PLOTTING: Signal selection not possible')
            end
        end
    end

    %label update
    po.f_label = @(s) {label_add,s};
end


function maxval = p2p_local(struct, interval, p2p_res)
    if ~isstruct(struct)
        maxval = 0;
        return
    else
        xx = struct.XData;
        yy = struct.YData;
    end

    if (p2p_res == 1)
        xi = find(xx > interval(1) & xx < interval(2));
        maxval = peak2peak(yy(xi));
    else
        n = uint32((interval(2)-interval(1))/p2p_res);
        interval_starts = linspace(interval(1),interval(2),n);
        
        maxval = 0;
        for(i=1:n-1)
            xi = find(xx > interval_starts(i) & xx < interval_starts(i+1));
            val = peak2peak(yy(xi));
    
            if (val>maxval)
                maxval = val;
            end
        end
    end
end

function [param_name, param_unit] = getParamNameAndUnit(param_label)
    if contains(param_label,'[')
        param_name = regexp(param_label,'(^[^\[\s]+) \[','tokens');
        param_name = param_name{1}; param_name = param_name{1};
        param_name = [' ' param_name{1} ' '];
    
        param_unit = regexp(param_label,'(\[.*\]$)','tokens');
        param_unit = param_unit{1}; param_unit = param_unit{1};
        param_unit = [' ' param_unit{1} ' '];
    else
        param_name = [' ' param_label{1} ' '];
        param_unit = '[#]';
    end
end

function arr3d = flipEvenDim(arr3d,dim,func)
    switch dim
        case 1
            arr3d(2:2:end,:,:) = func(arr3d(2:2:end,:,:));
        case 2
            arr3d(:,2:2:end,:) = func(arr3d(:,2:2:end,:));
        case 3
            arr3d(:,:,2:2:end) = func(arr3d(:,:,2:2:end));
    end
end
