num_in_journal = 6;

%define freq

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

time = [0:500-1]./100;

%compute functions values

a_y = a(time);
b_y = b(time);

disp(a_y(1:7));
disp(b_y(1:7));

N = length(a_y);
corr_vals = zeros(1, N);

for k = 0:N-1
    b_shift = circshift(b_y, k);
    
    corr_vals(k+1) = corelation(a_y, b_shift);
end

figure;
plot(0:N-1, corr_vals);
xlabel('Сдвиг');
ylabel('Корреляция');
title('Взаимная корреляция a и b при циклическом сдвиге');
grid on;

[max_corr, best_shift] = max(corr_vals);

fprintf('Максимальная корреляция = %.3f при сдвиге %d\n', max_corr, best_shift-1);[max_corr, best_shift] = max(corr_vals);

figure;
plot(0:N-1, a_y);
hold on;
plot(0:N-1, circshift(b_y, best_shift));
hold off;
xlabel('Сдвиг');
ylabel('Корреляция');
title('Взаимная корреляция a и b при циклическом сдвиге');
grid on;
%define cor function
function cor = corelation(a, b)
    
    if length(a) ~= length(b)
        disp("Vectors must be same size");
    end
    
    result = 0;
    norm_a = 0;
    norm_b = 0;

    for i = 1:length(a)
        result = result + a(i) * b(i);
        norm_a = norm_a + a(i) ^ 2;
        norm_b = norm_b + b(i) ^ 2;
    end

    cor = result / sqrt(norm_a * norm_b);

end