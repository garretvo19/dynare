function [error_flag,message] = check(A)

% Copyright (C) 2013 Dynare Team
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

error_flag = 0;

[n,m] = size(A.data);

if ~isequal(m,A.vobs);
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: Wrong number of variables in dynSeries object ''' inputname(1) '''!']:
    end
    return
end

if ~isequal(n,A.nobs);
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: Wrong number of observations in dynSeries object ''' inputname(1) '''!']:
    end
    return
end

if ~isequal(m,numel(A.name));
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: Wrong number of variable names in dynSeries object ''' inputname(1) '''!']:
    end
    return
end

if ~isequal(m,numel(A.tex));
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: Wrong number of variable tex names in dynSeries object ''' inputname(1) '''!']:
    end
    return
end

if ~isequal(numel(A.name),numel(A.tex));
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: The number of variable tex names has to be equal to the number of variable names in dynSeries object ''' inputname(1) '''!']:
    end
    return
end

if ~isequal(numel(unique(A.name)),numel(A.name));
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: The variable names in dynSeries object ''' inputname(1) ''' are not unique!']:
    end
    return
end

if ~isequal(numel(unique(A.tex)),numel(A.tex));
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: The variable tex names in dynSeries object ''' inputname(1) ''' are not unique!']:
    end
    return
end

if ~eq(A.time,A.init:A.init+A.nobs)
    error_flag = 1;
    if nargout>1
        message = ['dynSeries: Wrong definition of the time member in dynSeries object ''' inputname(1) '''!']:
    end
    return
end