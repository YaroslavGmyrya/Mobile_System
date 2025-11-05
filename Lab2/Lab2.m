% signal propogation model for macrocell: COST 231 HATA
%signal propogation model for microcell: UMiNLOS
%duplex type for UL and DL: FDD
%BS have feeder

%define model params
BS_POWER = 46; %dbm
SECTORS_BS = 3;
UE_POWER = 24; %dbm
BS_ANTENNA_GAIN = 21; %dbi
PENETRATION = 15; %db
IM = 1; %db
FREQ_RANGE = 1.8; %GHz
UL_BW = 10; %MHz
DL_BW = 20; %MHz
BS_FIGURE_NOISE = 2.4; %db
UE_FIGURE_NOISE = 6; %db
DL_SINR = 2; %db
UL_SINR = 4; %db
BS_MIMO = 2;
MIMO_GAIN = 3; %db
S = 100; %km^2
S_BLOCKAGE = 4; %km^2
FEEDER_LOSS =  2 + 0.5 + 0.4; %db

hBS = 100; %meters
hMS = 1;
A = 46.3;
B = 33.9;

rx_sensBS = -125 : 1 : -80;

rad = zeros(length(rx_sensBS), 1);

for i = 1:length(rx_sensBS)

    %compute UL budget and UL_MAPL

thermal_noise = -174 + 10 * log10(UL_BW * 10^6);

%UL budget
rx_bs_sens = BS_FIGURE_NOISE + thermal_noise + UL_SINR;
MAPL_UL = UE_POWER - FEEDER_LOSS + BS_ANTENNA_GAIN + MIMO_GAIN -IM - PENETRATION - rx_sensBS(i);

%fprintf("UL_PARAMS: Thermal noise: %f \t rx_sens = %f \t MAPL = %f\n", thermal_noise, rx_sensBS(i), MAPL_UL);

%DL budget
rx_ue_sens = UE_FIGURE_NOISE + thermal_noise + DL_SINR;
MAPL_DL = BS_POWER - FEEDER_LOSS + BS_ANTENNA_GAIN + MIMO_GAIN -IM - PENETRATION - rx_ue_sens;

%fprintf("DL_PARAMS: Thermal noise: %f \t rx_sens = %f \t MAPL = %f\n", thermal_noise, rx_ue_sens, MAPL_DL);

d = 0 : 1 : 15000;

%FSPM PL
lambda = (3*10^8) / (FREQ_RANGE * 10 ^ 9);
pl_FSPM_func = @(d, lambda) 10*log10((4 * pi .* d ./ lambda) .^ 2);
pl_FSPM = pl_FSPM_func(d, lambda);

%UMiNLOS PL
pl_ULOS_func = @(d) 26 * log10(FREQ_RANGE) + 22.7 + 36.7 * log10(d);
pl_ULOS = pl_ULOS_func(d);

%COST231
a = 3.2 * log10(11.75 * hMS)^2 - 4.97;

Lclutter = 0;

pl_COST_func = @(d, A, B, FREQ_RANGE, hBS, a, s, Lclutter) A + B * log10(FREQ_RANGE * 10^3) - 13.82 * log10(hBS) - a + s .* log10(d/1000) + Lclutter;

pl_COST = zeros(length(d), 1);

for k = 1: length(d)
    S = s(d(k), hBS, FREQ_RANGE);
    pl_COST(k) = pl_COST_func(d(k), A, B, FREQ_RANGE, hBS, a, S, Lclutter);
end

%Walfish-Ikegami
pl_WI = pl_WI_func(FREQ_RANGE, d);

%Radius

    for m = 1: length(pl_COST)
        if(pl_COST(m) >= MAPL_UL)
            fprintf("radius = %d \t MAPL = %f\n", m, MAPL_UL);
            rad(i) = m;
            break;
        end
    end

end

plot(rx_sensBS, rad);
xlabel("BS SENS")
title("YAROSLAV_GMYRYA");
ylabel("Cell Radius");
% 
% %compute UL budget and UL_MAPL
% 
% thermal_noise = -174 + 10 * log10(UL_BW * 10^6);
% 
% %UL budget
% rx_bs_sens = BS_FIGURE_NOISE + thermal_noise + UL_SINR;
% MAPL_UL = UE_POWER - FEEDER_LOSS + BS_ANTENNA_GAIN + MIMO_GAIN -IM - PENETRATION - rx_bs_sens;
% 
% fprintf("UL_PARAMS: Thermal noise: %f \t rx_sens = %f \t MAPL = %f\n", thermal_noise, rx_bs_sens, MAPL_UL);
% 
% %DL budget
% rx_ue_sens = UE_FIGURE_NOISE + thermal_noise + DL_SINR;
% MAPL_DL = BS_POWER - FEEDER_LOSS + BS_ANTENNA_GAIN + MIMO_GAIN -IM - PENETRATION - rx_ue_sens;
% 
% fprintf("DL_PARAMS: Thermal noise: %f \t rx_sens = %f \t MAPL = %f\n", thermal_noise, rx_ue_sens, MAPL_DL);
% 
% d = 0 : 1 : 15000;
% 
% %FSPM PL
% lambda = (3*10^8) / (FREQ_RANGE * 10 ^ 9);
% pl_FSPM_func = @(d, lambda) 10*log10((4 * pi .* d ./ lambda) .^ 2);
% pl_FSPM = pl_FSPM_func(d, lambda);
% 
% %UMiNLOS PL
% pl_ULOS_func = @(d) 26 * log10(FREQ_RANGE) + 22.7 + 36.7 * log10(d);
% pl_ULOS = pl_ULOS_func(d);
% 
% %COST231
% a = 3.2 * log10(11.75 * hMS)^2 - 4.97;
% 
% Lclutter = 0;
% 
% pl_COST_func = @(d, A, B, FREQ_RANGE, hBS, a, s, Lclutter) A + B * log10(FREQ_RANGE * 10^3) - 13.82 * log10(hBS) - a + s .* log10(d/1000) + Lclutter;
% 
% pl_COST = zeros(length(d), 1);
% 
% for k = 1: length(d)
%     S = s(d(k), hBS, FREQ_RANGE);
%     pl_COST(k) = pl_COST_func(d(k), A, B, FREQ_RANGE, hBS, a, S, Lclutter);
% end
% 
% %Walfish-Ikegami
% pl_WI = pl_WI_func(FREQ_RANGE, d);
% 
% figure;
% plot(d, pl_WI);     
% hold on;
% plot(d, pl_ULOS);   
% plot(d, pl_COST);  
% plot(d, pl_FSPM);  
% hold off;
% 
% title("PL models");
% xlabel("d [m]");
% ylabel("PL(d) [dB]");
% legend("Walfish-Ikegami", "UMi NLOS", "COST231", "FSPM");
% grid on;
% 
% % BS radius 
% figure;
% plot(d, pl_WI);     
% hold on;
% plot(d, pl_ULOS);   
% plot(d, pl_COST);  
% plot(d, pl_FSPM); 
% yline(MAPL_DL, 'Color','green');
% yline(MAPL_UL, 'Color','blue');
% hold off;
% 
% title("BS radius");
% xlabel("d [m]");
% ylabel("PL(d) [dB]");
% legend("Walfish-Ikegami", "UMi NLOS", "COST231", "FSPM", "MAPL_DL", "MAPL_UL");
% grid on;
% 
% %Radius
% R_ULOS = 0.45;
% R_COST = 0.8;
% 
% %Area
% S_ULOS = 1.95 * R_ULOS^2;
% S_COST = 1.95 * R_COST^2;
% 
% fprintf("S_ULOS = %f \t S_COST = %f\n", S_ULOS, S_COST);
% 
% S1 = 100;
% S2 = 4;
% 
% fprintf("countBS_ULOS = %f \t countBS_COST = %f\n", S2/S_ULOS, S1/S_COST);
% 

function s = s(d, hBS, FREQ_RANGE)
    if(d >= 1000)
        s = 44.9 - 6.55 * log10(FREQ_RANGE * 10 ^ 3);
    else
        s = (47.88 + 13.9 * log10(FREQ_RANGE * 10 ^ 3) - 13.9 * log10(hBS)) * 1 / (log10(50));
    end
end

function result = pl_WI_func(FREQ_RANGE, d)
w = 24.5; %avg street len
dh = 30; %avg h_bs - h_roof
phi = 45; %grad, angle bw street and signal route
b = 60; %avg distance bw building
d = d / 1000;
L0 = 32.44 + 20 * log10(FREQ_RANGE * 10^3) + 20 * log10(d);
L1 = -16.9 - 10*log10(w) + 10 * log10(FREQ_RANGE * 10^3) + 20 * log10(dh) + 2.5 * 0.075 * phi;
L2 = -18 * log10(1 + dh) + 54 + 18 * log10(d) + (-4 + 0.7 * (FREQ_RANGE * 10^3 / 925 - 1)) * log10(FREQ_RANGE*10^3) - 9 * log10(b);

result = L0 + L1 + L2;
end

