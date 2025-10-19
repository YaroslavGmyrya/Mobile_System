num_in_journal = 6;

%define freqs

f1 = num_in_journal;
f2 = num_in_journal + 4;
f3 = num_in_journal *2 + 1;

%define signal components

s1 = @(t) cos(2 * pi * f1 * t);
s2 = @(t) cos(2 * pi * f2 * t);
s3 = @(t) cos(2 * pi * f3 * t);

%define signal

a = @(t) 4 * s1(t) + 4 * s2(t) + s3(t);
b = @(t) s1(t) + 1;

%define time

time = 0:0.001:10;

%compute functions values

a_y = a(time);
b_y = b(time);

fprintf("Unnormolized corr: \t %f\n", unnorm_corr(a_y, b_y));
fprintf("Normolized corr: \t %f\n", norm_corr(a_y, b_y));

fprintf("-----------------------------------------------\n");

f1 = [0.3, 0.2, -0.1, 4.2, -2, 1.5, 0];
f2 = [0.3, 4, -2.2, 1.6, 0.1, 0.1, 0.2];

t = 0 : 1 : 7 - 1;

figure;
subplot(2, 1, 1);
plot(t, f1);
xlabel("t, s");
ylabel("A, v");
title("Seq1");
subplot(2, 1, 2);
plot(t, f2);
xlabel("t, s");
ylabel("A, v");
title("Seq2");

fprintf("Unnormolized corr: \t %f\n", unnorm_corr(f1, f2));
fprintf("Normolized corr: \t %f\n", norm_corr(f1, f2));

N = length(f1);

corr_vals = zeros(N, 1);

for k = 1:N
    f2_shift = circshift(f2, k);
    corr_vals(k) = norm_corr(f1, f2_shift);
end
 
figure;
plot(1:N, corr_vals);
xlabel('Сдвиг');
ylabel('Корреляция');
title('Взаимная корреляция a и b при циклическом сдвиге');
grid on;


% %define cor function
function corr = norm_corr(a, b)

    if length(a) ~= length(b)
        disp("Vectors must be same size");
    end

    norm_coef = sqrt(sum(a.^2)) .* sqrt(sum(b.^2));
    corr_vals = unnorm_corr(a, b);

    corr = corr_vals / norm_coef;

end

function corr = unnorm_corr(a, b)

    if length(a) ~= length(b)
        disp("Vectors must be same size");
    end

    corr = sum(a .* b);

end