function data = Data_P2P(results, exp_ranges, plottingObj, set_scope)
    DEBUG = 0;
    
    hydrophone_sensitivity = set_scope{1};
    interval = set_scope{3};
    plottingObj.interval = interval;
    plottingObj.hydrophone_sensitivity = hydrophone_sensitivity;

    %Reshape when multiple parameter dimensions
    if DEBUG disp('Initial -> reshaped (non 1D)'), end
    if DEBUG size(results), end
    
    %If the data is 2D or 3D the data must be deconvoluted
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

        %Signal to peak-to-peak pressure value
        if DEBUG disp('Get P2P values'), end
        f_p2p = @(struct) p2p_local(struct);
        vp2p = cellfun(f_p2p,squeeze(results));
        data = vp2p/plottingObj.hydrophone_sensitivity; %pressure peak to peak
end
    
 function maxval = p2p_local(struct)
    if ~isstruct(struct)
        maxval = 0;
        return
    else
        yy = struct.YData;
    end

    maxval = max(yy) - min(yy);
 end