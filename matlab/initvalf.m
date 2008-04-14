function initvalf(fname)

% function initvalf(fname,varargin)
% reads an initial path from the 'fname' file for exogenous and endogenous variables	
%
% INPUTS
%    fname:         name of the function
%    // period:        period
%    // varargin:      list of arguments following period
%
% OUTPUTS
%    none
%
% SPECIAL REQUIREMENTS
%    none
%  
% part of DYNARE, copyright Dynare Team (2003-2007)
% Gnu Public License.

  global M_ oo_ options_
  global y_start_date ex_start_date 

  series = 1;
  if exist(fname) == 2
      eval(fname);
  elseif exist([fname '.xls']) == 2
      [data,names_v]=xlsread([fname '.xls']);
      series = 0;
  elseif exist([fname '.mat']) == 2
      load(fname);
  end
  
% $$$   if length(period) == 2
% $$$     period = dy_date(period(1),period(2));
% $$$   end
% $$$   
% $$$   if period - max(M_.maximum_lag,M_.maximum_lag) < 0
% $$$     error(['INITVALF_: not enough data points in database for number of' ...
% $$$ 	   ' lags. Start later!'])
% $$$   end
% $$$   
% $$$   if nargin > 2
% $$$     if strcmp(upper(varargin{1}),'SERIES')
% $$$       series = 1 ;
% $$$     elseif strcmp(upper(varargin{1}),'MAT')
% $$$       series = 0 ;
% $$$     else
% $$$       error(['INITVALF: unknown option ' varargin{1}])
% $$$     end
% $$$   else
% $$$     series = 0 ;
% $$$   end
% $$$   
% $$$   y1 = floor((period-M_.maximum_lag)/M_.freq);
% $$$   p1 = period-M_.maximum_lag-M_.freq*y1;
% $$$   y_start_date(2) = M_.start_date(2) + p1-1;
% $$$   if y_start_date(2) > M_.freq
% $$$     y_start_date(2) = y_start_date(2) - M_.freq;
% $$$     y1 = y1 + 1;
% $$$   end
% $$$   y_start_date(1) = M_.start_date(1)+y1;
% $$$   
% $$$   y1 = floor((period-M_.maximum_lag)/M_.freq);
% $$$   p1 = period-M_.maximum_lag-M_.freq*y1;
% $$$   ex_start_date(2) = M_.start_date(2) + p1-1;
% $$$   if y_start_date(2) > M_.freq
% $$$     ex_start_date(2) = ex_start_date(2) - M_.freq;
% $$$     y1 = y1 + 1;
% $$$   end
% $$$   ex_start_date(1) = M_.start_date(1)+y1;
% $$$   
% $$$   clear y1, p1;
  
  options_.initval_file = 1;
  oo_.endo_simul = [];
  oo_.exo_simul = [];
  
  for i=1:size(M_.endo_names,1)
    if series == 1
%      x = eval([M_.endo_names(i,:) '(period-M_.maximum_lag:period+options_.periods+M_.maximum_lead-1);']);
      x = eval(M_.endo_names(i,:));
      oo_.endo_simul = [oo_.endo_simul; x'];
    else
      k = strmatch(upper(M_.endo_names(i,:)),names_v,'exact');
      if isempty(k)
	error(['INITVALF: ' M_.endo_names(i,:) ' not found'])
      end
      x = data(:,k);
%      oo_.endo_simul = [oo_.endo_simul; x(period-M_.maximum_lag:period+options_.periods+M_.maximum_lead-1)']; 
      oo_.endo_simul = [oo_.endo_simul; x']; 
    end
  end
  
  for i=1:size(M_.exo_names,1)
    if series == 1
%      x = eval([M_.exo_names(i,:) '(period-M_.maximum_lag:period+options_.periods+M_.maximum_lead-1);']);
      x = eval(M_.exo_names(i,:) );
      oo_.exo_simul = [oo_.exo_simul x];
    else
      k = strmatch(upper(M_.exo_names(i,:)),names_v,'exact');
      if isempty(k)
	error(['INITVALF: ' M_.exo_names(i,:) ' not found'])
      end
      x = data(:,k);
%      oo_.exo_simul = [oo_.exo_simul x(period-M_.maximum_lag:period+options_.periods+M_.maximum_lead-1)]; 
      oo_.exo_simul = [oo_.exo_simul x]; 
    end
  end
    












