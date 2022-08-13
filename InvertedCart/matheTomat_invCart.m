%% Mathematica to Matlab
mathematica = "9.81 Cos[\[Theta][t]]-0.5 Cos[\[Theta][t]] Sin[\[Theta][t]] (\[Theta]^\[Prime])[t]^2+0.5 Cos[\[Theta][t]]^2 (\[Theta]^\[Prime]\[Prime])[t]+1. Sin[\[Theta][t] (\[Theta]^\[Prime])[t]] \[Theta][t] (-0.5 Sin[\[Theta][t] (\[Theta]^\[Prime])[t]]+(x^\[Prime])[t]) ((\[Theta]^\[Prime])[t]^2+\[Theta][t] (\[Theta]^\[Prime]\[Prime])[t])-1. Cos[\[Theta][t] (\[Theta]^\[Prime])[t]] \[Theta][t] ((x^\[Prime]\[Prime])[t]-0.5 Cos[\[Theta][t] (\[Theta]^\[Prime])[t]] ((\[Theta]^\[Prime])[t]^2+\[Theta][t] (\[Theta]^\[Prime]\[Prime])[t]))==0";
%% Replacement Starts
% Sin and Cos
matlab = strrep(mathematica, "Sin", "sin");
matlab = strrep(matlab, "Cos", "cos");
% q
matlab = strrep(matlab, "x[t]", "q_1");
matlab = strrep(matlab, "\[Theta][t]", "q_2");
% dq
matlab = strrep(matlab, "(x^\[Prime])[t]", "q_3");
matlab = strrep(matlab, "(\[Theta]^\[Prime])[t]", "q_4");
% ddq
matlab = strrep(matlab, "x^\[Prime]\[Prime])[t]", "dq_3");
matlab = strrep(matlab, "(\[Theta]^\[Prime]\[Prime])[t]", "dq_4");
% add multiplications
matlab = strrep(matlab, " ", "*");
% Miscel
matlab = strrep(matlab, "[", "(");
matlab = strrep(matlab, "]", ")");
matlab = strrep(matlab, "{", "");
matlab = strrep(matlab, "}", "");

%% MATLAB to Mathematica
mathematica = strrep(matlab, "cos", "Cos");
mathematica = strrep(mathematica, "sin", "Sin");
mathematica = strrep(mathematica, "q(1)", "x[t]");
mathematica = strrep(mathematica, "q(2)", "y[t]");
mathematica = strrep(mathematica, "q(3)", "\[Theta]1[t]");
mathematica = strrep(mathematica, "q(4)", "\[Theta]2[t]");
mathematica = strrep(mathematica, "q(5)", "\[Theta]3[t]");
mathematica = strrep(mathematica, "q(6)", "\[Theta]4[t]");

mathematica = strrep(mathematica, "q(7)", "(x'[t]");
mathematica = strrep(mathematica, "q(8)", "(y'[t]");
mathematica = strrep(mathematica, "q(9)", "(\[Theta]1'[t]");
mathematica = strrep(mathematica, "q(10)", "(\[Theta]2'[t]");
mathematica = strrep(mathematica, "q(11)", "(\[Theta]3'[t]");
mathematica = strrep(mathematica, "q(12)", "(\[Theta]4'[t]");