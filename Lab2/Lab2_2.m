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

rx_sens_bs = -125 : -80 : 1;

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