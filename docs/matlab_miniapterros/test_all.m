% TEST_ALL  Verifications rapides (sans materiel).
hw = hw_sim();  cfg = default_config();

% 1) PID altitude : sortie dans [0,1] et anti-windup qui evite la derive
st = pid_altitude_state(); u = zeros(1,200);
for k = 1:200, [u(k), st] = pid_altitude(5, 0, 0, st, cfg.alt); end
assert(all(u >= 0 & u <= 1)); assert(abs(st.ik) < 1e3);

% 2) PID attitude : sortie dans [-1,1], signe correct
st = pid_attitude_state();
[u1, st] = pid_attitude(0.5, 0, 0, st, cfg.roll);  assert(u1 > 0);
st = pid_attitude_state();
[u2, st] = pid_attitude(-0.5, 0, 0, st, cfg.roll); assert(u2 < 0);

% 3) PID angle plateau
st = pid_mcc_angle_state(); [u3, st] = pid_mcc_angle(10, 0, st, cfg.mcc); assert(u3 > 0 && u3 <= 1);

% 4) Hall : depliage multi-tours (359 -> 1 degre = +2, pas -358)
st = hall_state(); p = struct('ratio',1,'offset_deg',0);
hw2 = hw; 
raw = @(deg) round(deg/360*16384);
hw2.i2c_read = @(b,a,r,n) uint8([floor(raw(359)/64), mod(raw(359),64)]);
[a, st] = hall_read_angle(hw2, 'B', 64, st, p);
hw2.i2c_read = @(b,a,r,n) uint8([floor(raw(1)/64), mod(raw(1),64)]);
[a, st] = hall_read_angle(hw2, 'B', 64, st, p);
assert(abs(a - 361) < 0.1);

% 5) Lidar : 150 cm -> 1.5 m
[d, sl] = lidar_read(hw, 'A', 98, lidar_state()); assert(abs(d - 1.5) < 1e-9);

% 6) Xsens : trame construite puis decodee
f  = @(v) typecast(single(v), 'uint8'); f = @(v) fliplr(f(v));   % big-endian
pl = [f(10) f(20) f(30)];
euler = [32 48 12 pl];                                            % ID 0x2030, len 12
gyro  = [128 32 12 fliplr(typecast(single(1),'uint8')) fliplr(typecast(single(2),'uint8')) fliplr(typecast(single(3),'uint8'))];
msg = xbus_frame(hex2dec('36'), [euler gyro]);
[o, rest] = xsens_parse([uint8([1 2 3]) msg]);
assert(isequal(o.euler_deg, [10 20 30])); assert(isequal(o.gyro, [1 2 3])); assert(isempty(rest));

% 7) Turbines : repos a 50 % -> 0.075 ; roulis +1 -> w1 = 0.1, w2 = 0.05
d = turbines_mix(0, 0, 0.5);  assert(abs(d.roll_12-0.075)<1e-12 && abs(d.roll_34-0.075)<1e-12);
d = turbines_mix(1, 1, 0.5);  assert(abs(d.roll_12-0.1)<1e-12 && abs(d.roll_34-0.05)<1e-12 && abs(d.thrust-0.1)<1e-12);
d = turbines_mix(0, -1, 0.5); assert(abs(d.roll_12-0.05)<1e-12);
d = turbines_mix(5, 5, 0);    assert(d.thrust <= 0.1 && d.roll_12 <= 0.1 && d.roll_34 >= 0.05);

% 8) Moteur CC : zone morte, sens complementaires, PWM = 0.6*|u|
global HWLOG
hw = hw_sim();  io = cfg.io;
motor_drive(hw, io.mcc1, 0.5, cfg.motor);
assert(isequal(HWLOG{1}(2:3), {'B/DIO2',1}) && isequal(HWLOG{2}(2:3), {'B/DIO3',0}));
assert(abs(HWLOG{3}{3} - 0.3) < 1e-12 && HWLOG{3}{4} == 15000);
hw = hw_sim(); motor_drive(hw, io.mcc2, 0.01, cfg.motor); assert(HWLOG{3}{3} == 0);
hw = hw_sim(); motor_drive(hw, io.mcc2, -0.5, cfg.motor); assert(HWLOG{1}{3} == 0 && HWLOG{2}{3} == 1);

% 9) Remise a zero : 5 sorties PWM a 0.05 / 50 Hz
hw = hw_sim(); outputs_zero(hw, io);
assert(numel(HWLOG) == 5 && all(cellfun(@(c) c{3}==0.05 && c{4}==50, HWLOG)));

% 10) Adresse lidar : changement puis reinitialisation (sans erreur en simulation)
hw = hw_sim();
lidar_change_address(hw, 'A', hex2dec('62'), hex2dec('64'), hex2dec('30'), hex2dec('52'));
lidar_reinit_address(hw, 'A');

% 11) Modele du moteur : boucle fermee avec le PID (sans erreur, valeurs finies)
sm = cfg.simmot; th = 0; om = 0; u = 0; st = pid_mcc_angle_state();
for k = 1:300
    [th, om] = motor_cc_model(u, th, om, th*pi/180, sm);
    [u, st]  = pid_mcc_angle(3, th, st, struct('K',0.5,'Ti',1,'Td',0.05,'Ts',sm.Ts,'N',0));
end
assert(isfinite(th) && isfinite(om));

% 12) Boucle complete en simulation
cfg.ramp_wait_s = 0;  cfg.Ts = 0;
hw = hw_sim();
log = main_control(hw, cfg, 20); assert(size(log,1) == 20);
% 13) Simulation complete : ne diverge pas et suit grossierement la consigne
res = apteros_simulation(5, struct('alt',1.0), false);
assert(all(isfinite(res.log(:))));
assert(abs(res.log(end,2) - 1.0) < 0.5);
disp('Tous les tests passent.');

% 14) Rapport de performance : tourne sans erreur, renvoie 4 lignes
T = apteros_performance_report(6, false);
if isstruct(T)
    assert(numel(T.Boucle) == 4);
else
    assert(height(T) == 4);
end
disp('Tous les tests passent.');
