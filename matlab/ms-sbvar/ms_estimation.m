function [options_, oo_]=ms_estimation(M_, options_, oo_)
%function ms_estimation()
% MS Sbvar Estimation
%
% INPUTS
%    M_
%    options_
%    oo_
%
% OUTPUTS
%    options_
%    oo_
%
% SPECIAL REQUIREMENTS
%    none

% Copyright (C) 2011 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

disp('Estimation');

% cleanup old files
clean_ms_files(options_.ms.output_file_tag);

% general setup
ms_sbvar_setup(options_);

% setup command line options
opt = ['-estimate -seed ' num2str(options_.DynareRandomStreams.seed)];
opt = [opt ' -ft ' options_.ms.output_file_tag];
opt = [opt ' -cb ' num2str(options_.ms.convergence_starting_value)];
opt = [opt ' -ce ' num2str(options_.ms.convergence_ending_value)];
opt = [opt ' -ci ' num2str(options_.ms.convergence_increment_value)];
opt = [opt ' -ib ' num2str(options_.ms.max_iterations_starting_value)];
opt = [opt ' -ii ' num2str(options_.ms.max_iterations_increment_value)];
opt = [opt ' -mb ' num2str(options_.ms.max_block_iterations)];
opt = [opt ' -repeat_max ' num2str(options_.ms.max_repeated_optimization_runs)];
opt = [opt ' -repeat_tol_obj ' num2str(options_.ms.function_convergence_criterion)];
opt = [opt ' -repeat_tol_parms ' num2str(options_.ms.parameter_convergence_criterion)];
opt = [opt ' -random ' num2str(options_.ms.number_of_large_perturbations)];
opt = [opt ' -random_small ' num2str(options_.ms.number_of_small_perturbations)];
opt = [opt ' -random_small_ndraws ' num2str(options_.ms.number_of_posterior_draws_after_perturbation)];
opt = [opt ' -random_max ' num2str(options_.ms.max_number_of_stages)];
opt = [opt ' -random_tol_obj ' num2str(options_.ms.random_function_convergence_criterion)];
opt = [opt ' -random_tol_parms ' num2str(options_.ms.random_parameter_convergence_criterion)];

% estimation
[err] = ms_sbvar_command_line(opt);
mexErrCheck('ms_sbvar_command_line estimation', err);

options_ = set_ms_estimation_flags_for_other_mex(options_);
oo_ = set_oo_w_estimation_output(options_, oo_);
options_ = initialize_ms_sbvar_options(M_, options_);
end