% Function for fitting IVIM data; be wary of units here; depending on what
% you read units for D/D* could be in m^2/s, mm^2/s OR 10^-3 mm^2/s, which
% will need to match whatever units for b that are used (typically given in
% s/mm^2 (0-500) ).

% To input here give b in s/mm^2

% Normally D/D* are quoted in 10^-3 mm^2/s because then the units are around
% 0-1000. During the script and in the output D/D* will be in mm^2/s, but
% typically when quoting the values you x1000 to get into 10^-3 mm^2/s.

%Tyically in the placenta I fit D from 0-25, and D* from 25-1000 10^-3
%mm^2/s

%Note as well this code is only for the b-values used in the placental
%experiments
%b= 0 1 3 9 18 32 54 88 110 147 180 200 230 270 300 350 400 450 500 s/mm^2


function f_fit = f_ivim_fit(S,b)

    b_110_index = find(b==110);

    %Fit works in three stages; two mono exponential decays and one final
    %bi-exponential fit
    mono_exp = @(x,x_data) x(1).*exp(-x(2).*x_data);
    %bi_exp is the IVIM model
    bi_exp = @(x,x_data) x(1).*( (1-x(2)).*exp(-x(3).*x_data) + x(2).*exp(-x(4).*x_data));
    %Fit options
    options = optimset('MaxFunEvals',1e5,'TolFun',1e-6,'MaxIter',1e5, 'Display', 'off');

    %First fit low b-values to a mono-exponential decay to estimate D*
    %             S0            D*
    DS_fit_lb = [0          25*1e-3];%lower bound
    DS_fit_ub = [40000    1000*1e-3];%upper bound
    DS_fit_x0 = [22000     100*1e-3];%initial guess

    DS_fit = lsqcurvefit(mono_exp,DS_fit_x0,b(1:b_110_index),double(S(1:b_110_index)),DS_fit_lb,DS_fit_ub,options);


    %Second fit high b-values to a mono-exponential decay to estimate D
    %             S0          D
    D_fit_lb = [0          0*1e-3];%lower bound
    D_fit_ub = [40000     25*1e-3];%upper bound
    D_fit_x0 = [22000      2*1e-3];%intial guess

    D_fit = lsqcurvefit(mono_exp,D_fit_x0,b((b_110_index+1):end),double(S((b_110_index+1):end)),D_fit_lb,D_fit_ub,options);

    %Finally fit full data to IVIM model, using mono-exp fit as initial
    %guesses

   %             S0     f_ivim       D          D*
    f_fit_lb = [  0        0        0         25*1e-3  ];%lower bound
    f_fit_ub = [40000      1      25*1e-3    1000*1e-3 ];%Upper bound
    f_fit_x0 = [22000     0.5     D_fit(2)    DS_fit(2)];%initial guess

    f_fit = lsqcurvefit(bi_exp,f_fit_x0,b,double(S),f_fit_lb,f_fit_ub,options);
    %Where f_fit is a 1x4 array containing S0 f_ivim D and D*

%     figure
%     plot(b,log(S./f_fit(1)),'x','markersize',14,'linewidth',5)
%     hold on
%     plot(b,log(bi_exp(f_fit,b)./f_fit(1)),'linewidth',5);
%     axis square
%     xlabel('b (s/mm^2)')
%     ylabel('log(S/S_0)')
%     set(gca,'Fontsize',32)

end

