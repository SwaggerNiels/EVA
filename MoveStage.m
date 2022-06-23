function MoveStage(x,y,z,spd)
%% Movement in mm
    calllib('xyz','move_to',spd,[x,y,z]*1E6);                 % move scanner to start position
end

