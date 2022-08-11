%% Transform System of Linear Equations into Matrix Vector Form
syms q_1 q_2 q_3 q_4 q_5 q_6 q_7 q_8 q_9 q_10 q_11 q_12
syms dq_1 dq_2 dq_3 dq_4 dq_5 dq_6 dq_7 dq_8 dq_9 dq_10 dq_11 dq_12

%% temporarily modify the equation variable
matlab = "q(7)-sin(q(3)+q(4))*(q(9)+q(10))+sin(q(3)+q(4)-q(5))*(q(9)+q(10)-q(11))+0.1*sin(q(3)+q(4)-q(5)-q(6))*(q(9)+q(10)-q(11)-q(12)),q(8)+cos(q(3)+q(4))*(q(9)+q(10))-cos(q(3)+q(4)-q(5))*(q(9)+q(10)-q(11))-0.1*cos(q(3)+q(4)-q(5)-q(6))*(q(9)+q(10)-q(11)-q(12)),q(9)-q(10)+q(11)+q(12)";
for i = 1 : 12
   matlab = strrep(matlab, strcat("q(", string(i), ")"), strcat("q_", string(i)));
end

%% Generate Matrix from Expression
matlab_parsed = split(matlab, ","); % split expressions

%% Manually Generate Equations from spliited string (copy + paste + (optional) add == )
eqn1 = q_7-sin(q_3+q_4)*(q_9+q_10)+sin(q_3+q_4-q_5)*(q_9+q_10-q_11)+0.1*sin(q_3+q_4-q_5-q_6)*(q_9+q_10-q_11-q_12) == 0;
eqn2 = q_8+cos(q_3+q_4)*(q_9+q_10)-cos(q_3+q_4-q_5)*(q_9+q_10-q_11)-0.1*cos(q_3+q_4-q_5-q_6)*(q_9+q_10-q_11-q_12) == 0;
eqn3 = q_9-q_10+q_11+q_12 == 0;

%% Generate Matrix
[A, B] = equationsToMatrix([eqn1, eqn2, eqn3], [q_7, q_8, q_9, q_10, q_11, q_12]);

%% Convert Matrix Expression Back to MATLAB Form
A_string = string(A);
[m, n] = size(A_string);
for i = 1 : m
    for j = 1 : n
       % do text replacement
       for k = 1 : 12
            A_string(i, j) = strrep(A_string(i, j), strcat("q_", string(k)), strcat("q(", string(k), ")"));
       end
    end
end

