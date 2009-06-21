function dynareroot = dynare_config(path_to_dynare)
%function dynareroot = dynare_config(path_to_dynare)
% This function tests the existence of valid mex files (for qz
% decomposition, solution to sylvester equation and kronecker
% products...) and, if needed, add paths to the matlab versions
% of these routines.
% Also adds other directories to the path.
%
% INPUTS
%   none
%             
% OUTPUTS
%   none
%        
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2001-2009 Dynare Team
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

if nargin
    addpath(path_to_dynare);
end
dynareroot = strrep(which('dynare.m'),'dynare.m','');

addpath([dynareroot '/distributions/'])
addpath([dynareroot '/kalman/'])
addpath([dynareroot '/kalman/likelihood'])
addpath([dynareroot '/AIM/'])

% For functions that exist under Octave and not under Matlab, or vice-versa,
% we provide some replacement functions
if exist('OCTAVE_VERSION')
    % Functions missing under Octave
    addpath([dynareroot '/octave/'])
else
    % Functions missing under Matlab
    addpath([dynareroot '/matlab/'])
    if isempty(ver('stats'))
        % Replacements for functions of the stats toolbox
        addpath([dynareroot '/matlab/stats/'])
    end
end

% Add path to MEX files
if exist('OCTAVE_VERSION')
    path_to_mex_files = [dynareroot '../mex/octave/'] ;
else
    if matlab_ver_less_than('7.5')
        path_to_mex_files = [dynareroot '../mex/2007a/'] ;
    else
        path_to_mex_files = [dynareroot '../mex/2007b/'] ;
    end
end
addpath(path_to_mex_files);

%% Set mex routine names
mex_status = cell(1,3);
mex_status(1,1) = {'mjdgges'};
mex_status(1,2) = {'qz'};
mex_status(1,3) = {'Generalized QZ'};
mex_status(2,1) = {'gensylv'};
mex_status(2,2) = {'gensylv'};
mex_status(2,3) = {'Sylvester equation solution'};
mex_status(3,1) = {'A_times_B_kronecker_C'};
mex_status(3,2) = {'kronecker'};
mex_status(3,3) = {'Kronecker products'};
mex_status(4,1) = {'sparse_hessian_times_B_kronecker_C'};
mex_status(4,2) = {'kronecker'};
mex_status(4,3) = {'Sparse kronecker products'};
number_of_mex_files = size(mex_status,1);
%% Remove some directories from matlab's path. This is necessary if the user has
%% added dynare_v4/matlab with the subfolders. Matlab has to ignore these
%% subfolders if valid mex files exist.
matlab_path = path;
test = strfind(matlab_path,[dynareroot 'threads/single']);
if length(test)
    rmpath([dynareroot 'threads/single']);
    matlab_path = path;
end
test = strfind(matlab_path,[dynareroot 'threads/multi']);
if length(test)
    rmpath([dynareroot 'threads/multi']);
    matlab_path = path;
end
for i=1:number_of_mex_files
    test = strfind(matlab_path,[dynareroot mex_status{i,2}]);
    action = length(test);
    if action
        rmpath([dynareroot mex_status{i,2}]);
        matlab_path = path;
    end
end
%% Test if multithread mex files are available.
if exist('isopenmp')==3
    addpath([dynareroot '/threads/multi/'])
    number_of_threads = set_dynare_threads();
    multithread_flag  = number_of_threads-1;
else
    addpath([dynareroot '/threads/single/'])
    multithread_flag = 0;
end
%% Test if valid mex files are available, if a mex file is not available
%% a matlab version of the routine is included in the path.
disp(' ')
disp('Configuring Dynare ...')

remove_path_to_mex = 1;

for i=1:number_of_mex_files
    test = (exist(mex_status{i,1},'file') == 3);
    if ~test
        addpath([dynareroot mex_status{i,2}]);
        message = '[m]   ';
    else
        if multithread_flag && ( strcmpi(mex_status(i,1),'sparse_hessian_times_B_kronecker_C') || ...
                                 strcmpi(mex_status(i,1),'A_times_B_kronecker_C') )
            message = [ '[mex][multithread version, ' int2str(multithread_flag+1) ' threads are used] ' ]; 
        else
            message = '[mex] ';
        end
        remove_path_to_mex = 0;
    end
    disp([ message mex_status{i,3} '.' ])
end

% Test if simulate DLL is present
if exist('simulate') == 3
  remove_path_to_mex = 0;
  if ~multithread_flag
      message = '[mex] ';
  else
      message = [ '[mex][multithread version, ' int2str(multithread_flag+1) ' threads are used] ' ];
  end
else
  message = '[no]  ';
end
disp([ message 'Fast model evaluation.' ])

if remove_path_to_mex
  rmpath(path_to_mex_files);
end

disp(' ')