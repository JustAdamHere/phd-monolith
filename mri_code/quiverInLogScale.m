function quiverInLogScale(x, y, u_interp, v_interp, s, color)
  %quiverInLogScale Plots matlab quiver with log scaling while maintaining
  %   proper arrows directions.
  %   Plots velocity vectors as arrows with the log of components (u,v)
  %   at the points (x,y).  The matrices X,Y,U,V must all be the same size
  %   and contain corresponding position and velocity components (X and Y
  %   can also be vectors to specify a uniform grid). Automatically scales
  %   the arrows to fit within the grid and then stretches them by S (default
  %   1). Use S=0 to plot the arrows without the automatic scaling.

  if nargin<5 % Check if s is given, and if not, defaults it to 1.
      s=1;
  end

  % Copies data to new variable.
  u = u_interp;
  v = v_interp;

  R = hypot(u,v); % Calculates the velocity magnitude at every point.

  % Sets anything less than 1e-5 to 0.
  u(R < 1e-5) = 0;
  v(R < 1e-5) = 0;
  R(R < 1e-5) = 0;

  minR = 1e-5;

  %minR = min(min(R(R~=0))); % Find the minimum magnitude, important in the case that it is below 1, so the log will not switch sign.

  % Calculates the normalized versions of u and v, this will keep the
  % original angles.
  uNorm = u./R;
  vNorm = v./R;

  % Calculates the log versions of u and v.
  uLog = log(R/minR).*uNorm;
  vLog = log(R/minR).*vNorm;
  if ~isequal(size(x),size(u))
      [x, y] = meshgrid(x,y);
  end

  quiver(x, y, uLog, vLog, s, 'color', color)

  end