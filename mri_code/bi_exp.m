function f = bi_exp(fit, b)
  f = fit(1).*( (1-fit(2)).*exp(-fit(3).*b) + fit(2).*exp(-fit(4).*b));
end