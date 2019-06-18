%TIMINGTEST    Works out the average cputime required to run
%    nearestneighbour
%    This is a support function for nndemo.m
%    T = TIMINGTEST(P, X, MODE)
%        Runs NEARESTNEIGHBOUR(P, X, 'DelaunayMode', MODE) for at least one
%        second, and returns the average cputime for a single execution
%
%    Example
%        % A set of points
%        X = rand(2, 1000)
%        % A set of points to find the neighbours of
%        P = rand(2, 100)
%        % Compute the time to run with DelaunayMode 'on'
%        timingtest(P, X, 'on')

%Richard Brown
function tAv = timingtest(P, X, mode)
% Run Time
tRun = 1; %sec

t = 0;
n = 0;
while t < tRun
  t0 = cputime;
  nearestneighbour(P, X, 'DelaunayMode', mode);
  t = t + cputime - t0;
  n = n + 1;
end

tAv = t / n;