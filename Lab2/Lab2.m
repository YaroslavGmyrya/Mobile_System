% signal propogation model for macrocell: COST 231 HATA
%signal propogation model for microcell: UMiNLOS
%duplex type for UL and DL: FDD
%BS have feeder

%define model params
BS_POWER = 46; %dbm
SECTORS_BS = 3;
UE_POWER = 24; %dbm
GAIN_BS = 21; %dbi
PENETRATION = 15; %db
IM = 1; %db
FREQ_RANGE = 1.8; %GHz
UL_BW = 10; %MHz
DL_BW = 20; %MHz
BS_NOISE_COEFF = 2.4; %db
UE_NOISE_COEFF = 6; %db
DL_SINR = 2; %db
UL_SINR = 4; %db
BS_MIMO = 2;
MIMO_GAIN = 3; %db
S = 100; %km^2
S_BLOCKAGE = 4; %km^2
FEEDER_LOSS =  2 + 0.5 + 0.4; %db

hBS = 100; %metrs
hMS = 5;
A = 46.3 ;
B = 33.9;

%compute UL budget and UL_MAPL

%UL budget
thermal_noise_ul = -174 + 10 * log10(UL_BW * 10^6);
rx_bs_sens = BS_NOISE_COEFF + thermal_noise_ul + UL_SINR;
MAPL_UL = UE_POWER - FEEDER_LOSS + GAIN_BS + MIMO_GAIN -IM - PENETRATION - rx_bs_sens;

fprintf("UL_PARAMS: Thermal noise: %f \t rx_sens = %f \t MAPL = %f\n", thermal_noise_ul, rx_bs_sens, MAPL_UL);

%DL budget
thermal_noise_dl = -174 + 10 * log10(DL_BW * 10^6);
rx_ue_sens = UE_NOISE_COEFF + thermal_noise_ul + DL_SINR;
MAPL_DL = BS_POWER - FEEDER_LOSS + GAIN_BS + MIMO_GAIN -IM - PENETRATION - rx_ue_sens;

fprintf("DL_PARAMS: Thermal noise: %f \t rx_sens = %f \t MAPL = %f\n", thermal_noise_dl, rx_ue_sens, MAPL_DL);

%UMiNLOS PL

pl_ULOS_func = @(d) 26 * log10(FREQ_RANGE) + 22.7 + 36.7 * log10(d);
d = 0 : 1 : 10000;
pl_ULOS = pl_ULOS_func(d);

figure;
plot(d, pl_ULOS);
title("UMiNLOS PL");
xlabel("d[m]");
ylabel("PL(d)");

%COST231

a = floor(1.1 * log10(FREQ_RANGE)) * hMS - floor(1.56 * log10(FREQ_RANGE) - 0.8);
Lclutter = 0;

pl_COST_func = @(d, A, B, FREQ_RANGE, hBS, a, s, Lclutter) A + B * log10(FREQ_RANGE) - 13.82 * log10(hBS) - a + s .* log10(d) + Lclutter;

pl_COST = zeros(length(d), 1);

for k = 1: length(d)
    S = s(d(k), hBS, FREQ_RANGE);
    pl_COST(k) = pl_COST_func(d(k), A, B, FREQ_RANGE, hBS, a, S, Lclutter);
end

figure;
plot(d, pl_COST);
title("COST231 PL");
xlabel("d[m]");
ylabel("PL(d)");

%Walfish-Ikegami

pl_WI_func = @(FREQ_RANGE, d) 42.6 + 20 * log10(FREQ_RANGE) + 26 .* log10(d);
pl_WI = pl_WI_func(FREQ_RANGE, d);

figure;
plot(d, pl_WI);
title("Walfish-Ikegami PL");
xlabel("d[m]");
ylabel("PL(d)");


% BS radius 

figure;
plot(d, pl_ULOS);
yline(MAPL_DL, 'r', "MAPL_DL");
yline(MAPL_UL, 'g', "MAPL_UL");
title("UMiNLOS Radius");
xlabel("d[m]");
ylabel("PL(d)");

figure;
plot(d, pl_COST);
yline(MAPL_DL, 'r', "MAPL_DL");
yline(MAPL_UL, 'g', "MAPL_UL");
title("COST231 Radius");
xlabel("d[m]");
ylabel("PL(d)");

figure;
plot(d, pl_WI);
yline(MAPL_DL, 'r', "MAPL_DL");
yline(MAPL_UL, 'g', "MAPL_UL");
title("Walfish-Ikegami Radius");
xlabel("d[m]");
ylabel("PL(d)");

%Radius
R_ULOS = 450;
R_COST = 1000;
R_WI = 1092;

%Area
S_ULOS = 1.95 * R_ULOS^2;
S_COST = 1.95 * R_COST^2;
S_WI = 1.95 * R_WI^2;



function s = s(d, hBS, FREQ_RANGE)
    if(d >= 1000)
        s = 44.9 - 6.55 * log10(FREQ_RANGE);
    else
        s = (47.88 + 13.9 * log10(FREQ_RANGE) - 13.9 * log10(hBS)) * 1 / (log10(50));
    end
end

