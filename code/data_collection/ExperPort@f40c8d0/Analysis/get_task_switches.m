function [first_dd, first_pd] = get_task_switches(trials, t_pd);
% GET_TASK_SWITCHES.m
%    Given the list of PD trials, determines the trials where 
%    the task was changed from a PD trial to a DD trial, and vice versa.

is_pd = zeros(trials,1);
is_pd(t_pd) = 1;

d = diff(is_pd);
first_dd = find(d == -1); first_dd = first_dd + 1;
first_pd = find(d == 1);  first_pd = first_pd + 1;
