function G = add_lobe_ns(G, dt, t1, t2, g_max)
  % Start point and end point of this lobe.
  t1_n = round(t1/dt);
  t2_n = round(t2/dt);

  % IF there is no overlap between gradients
  %  (by overlap i mean this https://gyazo.com/8b9bc7bdf173a14f0a69de296fdce0a4),
  %  then it's straight forward; just add it into the array.
  if G(t1_n) == 0
    % Add constant G imbetween.
    G(t1_n:t2_n) = g_max;

  % ELSE there IS an overlap; Add a new variable G_tmp which will just track
  %  what the second lobe should look like; then compare G_tmp and G, and
  %  just take the larger value.
  else
    G_tmp = 0;
    for n = 1:n_steps
      G_tmp = G_tmp + dg;
      G(t1_n + n) = max(abs([G(t1_n+n-1) G_tmp]))*sign(G(t1_n+n-1));
      G(t2_n - n) = G(t2_n-n+1) + dg;
    end

    % Add constant G imbetween.
    G(t1_n+n_steps:t2_n-n_steps) = g_max;

  end
end