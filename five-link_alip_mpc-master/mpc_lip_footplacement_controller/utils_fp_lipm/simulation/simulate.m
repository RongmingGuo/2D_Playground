function [traj_info] = simulate(sym_info,gait_info,sim_info)
import casadi.*

%% Extract inputs
% sim_info
dt_sim = sim_info.dt_sim;
dt_opt = sym_info.fp_opt.dt_opt;
x_init = sim_info.x_init;
num_steps = sim_info.num_steps;
num_steps_faster = sim_info.num_steps_faster;
num_steps_stop = sim_info.num_steps_stop;
int_type = sim_info.int_type;

% gait_info
t_step_period = gait_info.t_step_period;
Lx_offset = gait_info.Lx_offset;
Ly_des = gait_info.Ly_des;
torso_pitch_des = gait_info.torso_pitch_des;
mu_x = gait_info.mu_x;
mu_y = gait_info.mu_y;
z_H = gait_info.z_H;      % z_H
z_cl = gait_info.z_cl;
s_cl = gait_info.s_cl;
angle_x = gait_info.angle_x;
angle_y = gait_info.angle_y;

% sym_info
g = sym_info.params.g;
m = sym_info.params.m;
l = sqrt(g/z_H);
n_q = sym_info.dim.n_q;

opti_LS = sym_info.fp_opt.opti_LS;
opti_RS = sym_info.fp_opt.opti_RS;
ufp_stance_max = sym_info.fp_opt.ufp_stance_max;
ufp_stance_min = sym_info.fp_opt.ufp_stance_min;
N_fp = sym_info.fp_opt.N_fp;
N_k = sym_info.fp_opt.N_k;
N_steps_ahead = sym_info.fp_opt.N_steps_ahead;
opt_X_traj = sym_info.fp_opt.opt_X_traj;
opt_Ufp_traj = sym_info.fp_opt.opt_Ufp_traj;
p_x_init = sym_info.fp_opt.p_x_init;
p_Ly_des = sym_info.fp_opt.p_Ly_des;
p_z_H = sym_info.fp_opt.p_z_H;
p_ufp_stance_max = sym_info.fp_opt.p_ufp_max;
p_ufp_stance_min = sym_info.fp_opt.p_ufp_min;
p_k = sym_info.fp_opt.p_k;
p_mu = sym_info.fp_opt.p_mu;
p_stanceLeg = sym_info.fp_opt.p_stanceLeg;
p_leg_width = sym_info.fp_opt.p_leg_width;
p_Lx_offset = sym_info.fp_opt.p_Lx_offset;

fd_lip = sym_info.fp_opt.fd_lip;
k_pre_all = sym_info.fp_opt.k_pre_all;
k_post_all = sym_info.fp_opt.k_post_all;

f_eul = sym_info.func.f_eul;
f_rk4 = sym_info.func.f_rk4;
f_impact = sym_info.func.f_impact;
f_relabel = sym_info.func.f_relabel;

f_p_sw = sym_info.func.f_pos_swing;
f_p_sw_x = sym_info.func.f_pos_swing_x;
f_p_sw_z = sym_info.func.f_pos_swing_z;
f_v_sw = sym_info.func.f_vel_swing;
f_p_st = sym_info.func.f_pos_stance;
f_v_st = sym_info.func.f_vel_stance;
f_p_com_world = sym_info.func.f_pos_com_world;
f_v_com_world = sym_info.func.f_vel_com_world;
f_p_com_stance = sym_info.func.f_pos_com_stance;
f_v_com_stance = sym_info.func.f_vel_com_stance;

f_ha = sym_info.func.f_ha;
f_ha_dot = sym_info.func.f_ha_dot;
f_hd = sym_info.func.f_hd;
f_hd_dot = sym_info.func.f_hd_dot;
f_w = sym_info.func.f_w;
f_s = sym_info.func.f_s;
f_sdot = sym_info.func.f_sdot;
f_uIO = sym_info.func.f_uIO;

f_xc_slip_limit = sym_info.func.f_xc_slip_limit;
f_yc_slip_limit = sym_info.func.f_yc_slip_limit;


%% Initialize Variables
% Initialize variables
N_impacts = 0;
iter = 1;            % simulation iteration number (proportional to t_current)
max_iter = (num_steps+1) * (t_step_period/dt_sim);
iter_impact = 1;
t_current = 0;
t_start = 0;
ground_height_current = 0;
kx = tan(angle_x);
Rx = [cos(angle_x), -sin(angle_x); sin(angle_x), cos(angle_x)];
ky = tan(gait_info.angle_y);
cos_alpha_x = cos(gait_info.angle_x);

n_xlip = 4;
n_ufp = 2;
ufp_guess_prev = zeros(n_ufp,N_fp);
x_guess_prev = zeros(n_xlip,N_k);

p_sw_com_init = full(f_p_com_world(x_init) - f_p_sw(x_init));
p_st_world_current = full(f_p_st(x_init))';
p_sw_world_current = full(f_p_sw(x_init))';
v_st_world_current = full(f_v_st(x_init));
v_sw_world_current = full(f_v_sw(x_init));

p_st_to_st_current = zeros(2,1);
p_st_to_sw_current = full(f_p_sw(x_init) - f_p_st(x_init))';
v_st_to_st_current = zeros(2,1);
v_st_to_sw_current = full(f_v_sw(x_init) - f_v_st(x_init));

p_st_sw_z_init = p_st_to_sw_current(2);

% Storage
time_traj(1) = t_current;
t_impact_traj = t_current;
s_traj = [];
mu_traj = [];

p_sw_world_traj = [];
p_st_world_traj = [];
v_sw_world_traj = [];
v_st_world_traj = [];
p_st_to_sw_traj = [];
p_st_to_st_traj = [];
v_st_to_sw_traj = [];
v_st_to_st_traj = [];

impact_traj = [];
ufp_sol_traj = {};
xlip_sol_traj = {};
ufp_rel_traj = [];
ufp_world_traj = [];
time_calc = [];
x_traj = [];
u_sol_traj = [];
w_sol_traj = [];
w_aligned_traj = [];

p_com_world_traj = [];
v_com_world_traj = [];
p_com_stance_traj = [];
v_com_stance_traj = [];
Ly_stance_traj = [];

Ly_des_traj = [];

ha_traj = [];
ha_dot_traj = [];
ha_ddot_traj = [];
hd_traj = [];
hd_dot_traj = [];
hd_ddot_traj = [];
y_traj = [];
y_dot_traj = [];
y_ddot_traj = [];

p_sw_com_grant_traj = [];
p_sw_com_yukai_traj = [];

ufp_stance_max_traj = [];
ufp_stance_min_traj = [];

xc_hip_limit_traj = [];
xc_slip_limit_traj = [];
yc_slip_limit_traj = [];

%% Main Loop

% max_iter = 31;
while(  ( N_impacts < num_steps && iter < max_iter ) ) %&& ctrl_info.iter < 500)
    %% limits
    ufp_stance_max_traj = [ufp_stance_max_traj, ufp_stance_max];
    ufp_stance_min_traj = [ufp_stance_min_traj, ufp_stance_min];
    
    xc_slip_limit = full(f_xc_slip_limit(z_H,mu_x,kx));
    yc_slip_limit = full(f_yc_slip_limit(z_H,mu_y,ky));
    xc_slip_limit_traj = [xc_slip_limit_traj, xc_slip_limit];
    yc_slip_limit_traj = [yc_slip_limit_traj, yc_slip_limit];
    
    xc_mech_hip_limit = 0.5 * (ufp_stance_max * cos_alpha_x);
    xc_hip_limit_traj = [xc_hip_limit_traj, xc_mech_hip_limit];
    
    %% Change desired values after N_ steps
    if N_impacts >= num_steps_faster && N_impacts < num_steps_stop
        xcdot_des = 2.0;
        Ly_des = m * z_H * xcdot_des;
    elseif N_impacts >= num_steps_stop
        Ly_des = 0;
    end
    Ly_des_traj = [Ly_des_traj, Ly_des]; % update desired trajectory
    
    %% phase variable
    s = full(f_s(t_current,t_start,t_step_period));
    sdot = full(f_sdot(t_step_period));
    
    %% Predict state at end of step
    p_com_stance_est = full(f_p_com_stance(x_init));
    z_H_current = p_com_stance_est(2) - kx*p_com_stance_est(1);
    pred_info = struct(...
        'g',                g,...
        'm',                m,...
        'z_H_current',              z_H_current,...
        'dt_opt',           dt_opt,...
        'x_init',           x_init,...
        'f_p_st',           f_p_st,...
        'f_p_com_stance',   f_p_com_stance,...
        'f_v_com_stance',   f_v_com_stance,...
        's',                s,...
        't_step_period',    t_step_period,...
        'fd_lip',           fd_lip);
    [xlip_eos] = predict_lip_eos_state(pred_info);
    
    %% Foot placement calc
    %     if isequal(sim_info.method,'grant')
    % MPC method
    fp_info = struct(...
        'use_codegen',          sim_info.use_codegen,...
        'use_function',         sim_info.use_function,...
        'g',                    g,...
        'm',                    m,...
        'z_H',                  z_H,...
        'xlip_init',            xlip_eos,...
        'Lx_offset',            Lx_offset,...
        'Ly_des',               Ly_des,...
        'ufp_stance_max',       ufp_stance_max,...
        'ufp_stance_min',       ufp_stance_min,...
        'k',                    [kx;ky],...
        'mu_x',                 mu_x,...
        'mu_y',                 mu_y,...
        'stanceLeg',            1,...
        'leg_width',            gait_info.leg_width,...
        'N_steps',              N_steps_ahead,...
        'N_fp',                 N_fp,...
        'N_k',                  N_k,...
        'n_xlip',               4,...
        'n_ufp',                2,...
        'f_opti_LS',            sym_info.fp_opt.f_opti_LS,...
        'f_opti_RS',            sym_info.fp_opt.f_opti_RS,...
        'opti_LS',              opti_LS,...
        'opti_RS',              opti_RS,...
        'opt_X_traj',           opt_X_traj,...
        'opt_Ufp_traj',         opt_Ufp_traj,...
        'p_x_init',             p_x_init,...
        'p_Ly_des',             p_Ly_des,...
        'p_z_H',                p_z_H,...
        'p_ufp_stance_max',     p_ufp_stance_max,...
        'p_ufp_stance_min',     p_ufp_stance_min,...
        'p_k',                  p_k,...
        'p_mu',                 p_mu,...
        'p_stanceLeg',          p_stanceLeg,...
        'p_leg_width',          p_leg_width,...
        'p_Lx_offset',          p_Lx_offset,...
        'k_post_all',           k_post_all,...
        'fd_lip',               fd_lip,...
        'iter',                 iter,...
        'ufp_guess_prev',       ufp_guess_prev,...
        'x_guess_prev',         x_guess_prev);
    [ufp_sol,xlip_sol] = compute_fp(fp_info);
    ufp_guess_prev = ufp_sol;
    x_guess_prev = xlip_sol;
    p_sw_com_des_grant = xlip_sol(1,k_pre_all(1)) - ufp_sol(1,1);
    p_sw_com_grant_traj = [p_sw_com_grant_traj, p_sw_com_des_grant];
    
    %% Yukai method
    t_remain = t_step_period * (1 - s);
    H = z_H;
    T = t_step_period;
    p_com_stance_est = full(f_p_com_stance(x_init));
    xc_est = p_com_stance_est(1);
    
    p_st_world = full(f_p_st(x_init));
    L_est = L_world_reference_point_mex(x_init(1:n_q),x_init(n_q+1:end),[p_st_world(1);0;p_st_world(2)]);
    Ly_est = L_est(2);
    Ly_eos_est = m*H*l*sinh(l*t_remain)*xc_est + cosh(l*t_remain)*Ly_est;
    p_sw_com_des_yukai = (1 / (m * H * l * sinh(l*T))) * (Ly_des - cosh(l*T) * Ly_eos_est);
    p_sw_com_yukai_traj = [p_sw_com_yukai_traj, p_sw_com_des_yukai];

    %% Choose method
    if isequal(sim_info.fp_method,'grant')
        p_sw_com_des = p_sw_com_des_grant;
    elseif isequal(sim_info.fp_method,'yukai')
        p_sw_com_des = p_sw_com_des_yukai;
    end
    
    %% IO controller
    % Actual virtual outputs
    ha_current = full(f_ha(x_init,kx));
    ha_dot_current = full(f_ha_dot(x_init,kx));
    
    % Desired virtual outputs
    ufp_sol_x = ufp_sol(1);
    hd_current = full(f_hd(s,sdot,torso_pitch_des,z_H,p_sw_com_init,p_sw_com_des,kx,s_cl,z_cl,p_st_sw_z_init,ufp_sol_x));
    hd_dot_current = full(f_hd_dot(s,sdot,torso_pitch_des,z_H,p_sw_com_init,p_sw_com_des,kx,s_cl,z_cl,p_st_sw_z_init,ufp_sol_x));
    
    % Output
    y_current = ha_current - hd_current;
    y_dot_current = ha_dot_current - hd_dot_current;
    
    % input and wrench
    u_sol_io = full(f_uIO(x_init,s,sdot,torso_pitch_des,z_H,p_sw_com_init,p_sw_com_des,kx,s_cl,z_cl,p_st_sw_z_init,ufp_sol_x)); %
    w_sol_io = full(f_w(x_init,u_sol_io));
    
    %% Center of Mass / Angular Momentum Info
    p_com_world = full(f_p_com_world(x_init))';
    v_com_world = full(f_v_com_world(x_init));
    p_com_stance = full(f_p_com_stance(x_init))';
    v_com_stance = full(f_v_com_stance(x_init));
    
    p_st_world = full(f_p_st(x_init));
    
    L_stance = L_world_reference_point_mex(x_init(1:n_q),x_init(n_q+1:end),[p_st_world(1);0;p_st_world(2)]);
    Ly_stance = L_stance(2);
    
    %% Store trajectory and time
    time_traj(iter) = t_current;
    s_traj = [s_traj, s];
    impact_traj = [impact_traj, N_impacts];
    
    x_traj = [x_traj, x_init];
    
    p_com_world_traj = [p_com_world_traj, p_com_world];
    v_com_world_traj = [v_com_world_traj, v_com_world];
    p_com_stance_traj = [p_com_stance_traj, p_com_stance];
    v_com_stance_traj = [v_com_stance_traj, v_com_stance];
    Ly_stance_traj = [Ly_stance_traj, Ly_stance];
    
    ha_traj = [ha_traj, ha_current];
    ha_dot_traj = [ha_dot_traj, ha_dot_current];
    hd_traj = [hd_traj, hd_current];
    hd_dot_traj = [hd_dot_traj, hd_dot_current];
    y_traj = [y_traj, y_current];
    y_dot_traj = [y_dot_traj, y_dot_current];
    
    u_sol_traj = [u_sol_traj , u_sol_io];
    w_sol_traj = [w_sol_traj , w_sol_io];
    w_aligned_traj = [w_aligned_traj, Rx*w_sol_io];
    
    ufp_sol_traj = [ufp_sol_traj, {ufp_sol}];
    xlip_sol_traj = [xlip_sol_traj, {xlip_sol}];
    ufp_rel_traj = [ufp_rel_traj, ufp_sol(:,1)];
    ufp_world_traj = [ufp_world_traj, [ufp_sol(1,1)+p_st_world_current(1); p_st_world_current(2)]];
    
    p_sw_world_traj = [p_sw_world_traj, p_sw_world_current];
    p_st_world_traj = [p_st_world_traj, p_st_world_current];
    v_sw_world_traj = [v_sw_world_traj, v_sw_world_current];
    v_st_world_traj = [v_st_world_traj, v_st_world_current];
    p_st_to_sw_traj = [p_st_to_sw_traj, p_st_to_sw_current];
    p_st_to_st_traj = [p_st_to_st_traj, p_st_to_st_current];
    v_st_to_sw_traj = [v_st_to_sw_traj, v_st_to_sw_current];
    v_st_to_st_traj = [v_st_to_st_traj, v_st_to_st_current];
    
    mu_traj = [mu_traj, [mu_x; mu_y]];
    
    update_info = struct(...
        'int_type', int_type,...
        'f_eul',    f_eul,...
        'f_rk4',    f_rk4,...
        'dt_sim',   dt_sim,...
        't_init',   t_current,...
        'x_init',   x_init,...
        'u',        u_sol_io);
    
    %% Apply the control and forward integrate dynamics
    [t_next,x_next] = update_state(update_info);
    
    %% Check for Impact and Update
    p_sw_world_current = full(f_p_sw(x_next))';
    p_st_world_current = full(f_p_st(x_next))';
    v_sw_world_current = full(f_v_sw(x_next));
    v_st_world_current = full(f_v_st(x_next));
    p_st_to_st_current = zeros(2,1);
    p_st_to_sw_current = full(f_p_sw(x_next) - f_p_st(x_next))';
    v_st_to_st_current = zeros(2,1);
    v_st_to_sw_current = full(f_v_sw(x_next) - f_v_st(x_next));
    
    sw_above_ground = check_swingfoot_clearance(p_sw_world_current, kx, ground_height_current);
    
    if  ~sw_above_ground && v_sw_world_current(2) < -0.05
        disp("-> Impact occured, find when it happened!");
        
        % Forward Integrate until Impact, Apply Impact, Integrate until 
        % t_current + DT has been reached
        impact_info = struct(...
            't_init',                   t_current,...
            'x_init',                   x_init,...
            'u',                        u_sol_io,...
            'dt',                       dt_sim,...
            'kx',                       kx,...
            'f_rk4',                    f_rk4,...
            'f_p_sw_x',                 f_p_sw_x,...
            'f_p_sw_z',                 f_p_sw_z,...
            'f_impact',                 f_impact,...
            'f_relabel',                f_relabel,...
            'ground_height_current',    ground_height_current);
        
        [t_next,x_next,t_impact] = impact_update(impact_info);
        
        % Update initial swing foot pos
        p_sw_com_init = full(f_p_com_world(x_next) - f_p_sw(x_next));
        
        % Update time
        t_start = t_current;
        t_impact_traj = [t_impact_traj, t_impact];
        
        % Update impact counter
        N_impacts = N_impacts + 1;
        iter_impact = 0;
        disp("-> Step # " + N_impacts);
        new_step = true;
        
        % Update stance foot position with previous swing foot impact pos
        p_sw_world_current = full(f_p_sw(x_next))';
        p_st_world_current = full(f_p_st(x_next))';
        v_sw_world_current = full(f_v_sw(x_next));
        v_st_world_current = full(f_v_st(x_next));
        p_st_to_st_current = zeros(2,1);
        p_st_to_sw_current = full(f_p_sw(x_next) - f_p_st(x_next))';
        v_st_to_st_current = zeros(2,1);
        v_st_to_sw_current = full(f_v_sw(x_next) - f_v_st(x_next));
        
        p_st_sw_z_init = p_st_to_sw_current(2);

        %         ground_height_current = p_st_world_current(end);
    end
    
    %% Update state and time, warm start, shift reference
    t_current = t_next;
    x_init = x_next;
    iter = iter + 1;  % update iteration counter
    iter_impact = iter_impact + 1;
    
    % Print every n iterations
    if mod(iter-1,10) == 0
        disp("Iteration = " + (iter-1));
    end
    %     disp('=======================================');
end

%% Return Trajectory info
% time
traj_info.time_traj = time_traj;
traj_info.t_impact_traj = t_impact_traj;
traj_info.s_traj = s_traj;

% states, control, wrench
traj_info.x_traj = x_traj;
traj_info.u_io_traj = u_sol_traj;
traj_info.w_io_traj = w_sol_traj;
traj_info.w_aligned_traj = w_aligned_traj;

% com
traj_info.p_com_world_traj = p_com_world_traj;
traj_info.v_com_world_traj = v_com_world_traj;
traj_info.p_com_stance_traj = p_com_stance_traj;
traj_info.v_com_stance_traj = v_com_stance_traj;
traj_info.Ly_stance_traj = Ly_stance_traj;

% lip sol
% traj_info.xlip_ideal_traj = xlip_ideal_traj;

% foot placement
traj_info.ufp_sol_traj = ufp_sol_traj;
traj_info.xlip_sol_traj = xlip_sol_traj;
traj_info.ufp_rel_traj = ufp_rel_traj;
traj_info.ufp_world_traj = ufp_world_traj;

% limits
traj_info.ufp_stance_max_traj = ufp_stance_max_traj;
traj_info.ufp_stance_min_traj = ufp_stance_min_traj;
traj_info.xc_slip_limit_traj = xc_slip_limit_traj;
traj_info.xc_mech_hip_limit_traj = xc_hip_limit_traj;

% virtual constraints and outputs
traj_info.ha_traj = ha_traj;
traj_info.ha_dot_traj = ha_dot_traj;
traj_info.ha_ddot_traj = ha_ddot_traj;
traj_info.hd_traj = hd_traj;
traj_info.hd_dot_traj = hd_dot_traj;
traj_info.hd_ddot_traj = hd_ddot_traj;
traj_info.y_traj = y_traj;
traj_info.y_dot_traj = y_dot_traj;
traj_info.y_ddot_traj = y_ddot_traj;

% Foot positions & velocities
traj_info.pos_sw_world_traj = p_sw_world_traj;
traj_info.pos_st_world_traj = p_st_world_traj;
traj_info.vel_sw_world_traj = v_sw_world_traj;
traj_info.vel_st_world_traj = v_st_world_traj;
traj_info.pos_sw_rel_traj = p_st_to_sw_traj;
traj_info.pos_st_rel_traj = p_st_to_st_traj;
traj_info.vel_sw_rel_traj = v_st_to_sw_traj;
traj_info.vel_st_rel_traj = v_st_to_st_traj;

% Foot placement computations
traj_info.p_sw_com_yukai_traj = p_sw_com_yukai_traj;
traj_info.p_sw_com_grant_traj = p_sw_com_grant_traj;

% Impact
traj_info.impact_traj = impact_traj;

% Statistics
traj_info.stats.time_calc = time_calc;

traj_info.num_impacts = N_impacts;
traj_info.iter_impact = iter_impact;
traj_info.iter = iter;

% Params
traj_info.mu_traj = mu_traj;
traj_info.params.kx = kx;
% traj_info.params.max_step_flat = ufp_max_hip;

% Desired
traj_info.Ly_des_traj = Ly_des_traj;
end