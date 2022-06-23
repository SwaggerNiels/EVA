function position = ChangeParam(GenObj, measuring_speed,position,param,param_val,testmode,nosource)    
    if testmode
        return
    end

    switch param
        case 'x'
            OpenXYZcontroller();
            MoveStage(param_val,position(2),position(3),measuring_speed);
            CloseXYZcontroller();
            position(1) = param_val;
        case 'y'
            OpenXYZcontroller();
            MoveStage(position(1),param_val,position(3),measuring_speed);
            CloseXYZcontroller();
            position(2) = param_val;
        case 'z'
            OpenXYZcontroller();
            MoveStage(position(1),position(2),param_val,measuring_speed);
            CloseXYZcontroller();
            position(3) = param_val;
        case 'f'
            if ~nosource
                SetSignal(GenObj,'f', param_val,0,0);
            else
                disp('Cannot use parameter f, because source is not connected')
            end
        case 'b'
            if ~nosource
                SetSignal(GenObj,'b', 0,param_val,0);
            else
                disp('Cannot use parameter b, because source is not connected')
            end
        case 'v'
            if ~nosource
                SetSignal(GenObj,'v', 0,0,param_val);
            else
                disp('Cannot use parameter v, because source is not connected')
            end
    end
end