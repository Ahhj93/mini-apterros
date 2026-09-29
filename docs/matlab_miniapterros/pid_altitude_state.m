function st = pid_altitude_state()
% Etat initial de pid_altitude (Feedback Nodes a 0).
st = struct('vk',0,'zk',0,'ik',0,'uk',0,'wk',0);
end
