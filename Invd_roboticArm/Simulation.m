%% Initial Condition
q = [1/2 * pi; 2/3 * pi; 0; 0];
dq = [0; 0; 0; 0];

%% Euler-Lagrange Equation Based Simulation
Result = [q; 0];
% Specify Torque
Ks1 = 70;
Bs1 = 5;
Ks2 = 30;
Bs2 = 5;
theta_eq1 = 2/3 * pi;
theta_eq2 = 1/2 * pi;

%% Simulation Starts
tStep = 0.005;
for t = 0 : tStep : 10
    
    % Obtain Inertia Matrix
    M = [2.1875 - 0.625 * cos(q(2)), 0.104167 - 0.3125 * cos(q(2)); 0.104167 - 0.3125 * cos(q(2)), 0.104167];
    
    % Obtain Coriolis Term
    H = [49.05  * cos(q(1)) - 6.13125 * cos(q(1)) * cos(q(2)) + 6.13125 * sin(q(1)) * sin(q(2)) + 0.625 * sin(q(2)) * q(3) * q(4) + 0.3125 * sin(q(2)) * q(4)^2;
         -6.13125 * cos(q(1)) * cos(q(2)) + 6.13125 * sin(q(1)) * sin(q(2)) - 0.3125 * sin(q(2)) * q(3)^2];
    
    % Obtain Passive Joint Forces
    T_passive = [-Ks1 * (q(1) - theta_eq1) - Bs1 * q(3); -Ks2 * (q(2) - theta_eq2) - Bs2 * (q(4))];
    
    % Obtain Ground Reaction Force
    T_GRF = [0; 0];
    % Input Commanded Torque
    cmdTorque = [0; 0];
    
    % Compute All Externals
    k = (-1) * H + T_passive + T_GRF + cmdTorque;
    
    % M(q)ddq + H = T_passive + T_GRF + cmdTorque
    dq(1:2) = q(3:4);
    dq(3) = (M(1, 2) * k(2) - M(2, 2) * k(1)) / (M(1, 2) * M(2, 1) - M(1, 1) * M(2, 2));
    dq(4) = - (M(1, 1) * k(2) - M(2, 1) * k(1)) / (M(1, 2) * M(2, 1) - M(1, 1) * M(2, 2));
    
    q = q + tStep * dq;
    
    % Store Result
    Result = [Result, [q; t]];
end


%% Animation
% Initialize Painter
figure(1)
plot(0, 0, 'k.', 'MarkerSize', 20);
xlim([-1, 1]);
ylim([-1, 1]);
hold on
grid on
axis equal
title("2DOF Robotic Arm Simulation")
xlabel("x(m)")
ylabel("y(m)")
hold on
for i = 1 : 10036
    i
    figure(1);
    plotRobo(Result(1:4, i));
end


