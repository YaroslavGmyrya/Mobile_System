diary('output.txt');
%% define model params 
NUM_IN_JOURNAL = 6;
BIT_SIZE = 5;

%% define base seq
seq1 = dec2bin(NUM_IN_JOURNAL, BIT_SIZE) - '0';
seq2 = dec2bin(NUM_IN_JOURNAL + 7, BIT_SIZE) - '0';

seq3 = dec2bin(NUM_IN_JOURNAL + 1, BIT_SIZE) - '0';
seq4 = dec2bin(NUM_IN_JOURNAL + 2, BIT_SIZE) - '0';

%% output result
fprintf("seq1: ");
disp(seq1);

fprintf("seq2: ");
disp(seq2);

fprintf("seq3: ");
disp(seq3);

fprintf("seq4: ");
disp(seq4);

timeline = 0:1:BIT_SIZE-1;

figure;
subplot(4,1,1);
plot(timeline, seq1);
xlabel("t,s");
ylabel("A,v");
title("base seq");
subplot(4,1,2);
plot(timeline, seq2);
xlabel("t,s");
ylabel("A,v");
title("base seq");
subplot(4,1,3);
plot(timeline, seq3);
xlabel("t,s");
ylabel("A,v");
title("base seq");
subplot(4,1,4);
plot(timeline, seq4);
xlabel("t,s");
ylabel("A,v");
title("base seq");
grid on;


%% generate m-seq
poly1 = [5 3];     
poly2 = [5 3 2 1];

m_seq1 = m_seq_gen(seq1, poly1);
m_seq2 = m_seq_gen(seq2, poly2);
m_seq3 = m_seq_gen(seq3, poly1);
m_seq4 = m_seq_gen(seq4, poly2);

%% output result

fprintf("m-seq1: ");
disp(m_seq1');

fprintf("m-seq2: ");
disp(m_seq2');

fprintf("m-seq3: ");
disp(m_seq3');

fprintf("m-seq4: ");
disp(m_seq4');

timeline = 0:1:2^BIT_SIZE-2;

figure;

subplot(4, 1, 1);
plot(timeline, m_seq1);
xlabel("t,s");
ylabel("A,v");
title("m-seq1");

subplot(4, 1, 2);
plot(timeline, m_seq2);
xlabel("t,s");
ylabel("A,v");
title("m-seq2")

subplot(4, 1, 3);
plot(timeline, m_seq3);
xlabel("t,s");
ylabel("A,v");
title("m-seq3")

subplot(4, 1, 4);
plot(timeline, m_seq4);
xlabel("t,s");
ylabel("A,v");
title("m-seq4")
grid on;


%% generate golden-seq
golden_seq1 = xor(m_seq1, circshift(m_seq2, 14));
golden_seq2 = xor(m_seq3, circshift(m_seq4, 14));

%% output result
fprintf("golden_seq1: ")
disp(golden_seq1');

fprintf("golden_seq2: ")
disp(golden_seq2');

figure;

subplot(2, 1, 1);
plot(timeline, golden_seq1);
xlabel("t,s");
ylabel("A,v");
title("golden-seq1");

subplot(2, 1, 2);
plot(timeline, golden_seq2);
xlabel("t,s");
ylabel("A,v");
title("golden-seq2");


%% CrossCorr
[c,lags] = xcorr(golden_seq1, golden_seq2, 'coeff');
figure;
subplot(2, 1, 1);
plot(lags,c);
xlabel("lags");
ylabel("Corr");
title("Corr bw golden-seq1&golden-seq2");
grid on;
    
%%AutoCorr
[c,lags] = xcorr(golden_seq1, golden_seq1, 'coeff');
subplot(2, 1, 2);
plot(lags,c);
xlabel("lags");
ylabel("Corr");
title("golden-seq1 autocorr");
grid on;

diary off;   


%% function for generate m-seq
function m_seq = m_seq_gen(seq, poly)
    
    m_seq_len = 2^length(seq) - 1;
    m_seq = zeros(m_seq_len, 1);
  
    for i=1:m_seq_len
        x = 0;

        %get bits for feedback
        for k=1:length(poly)
            x = xor(x, seq(poly(k)));
        end

        %write last bit default seq to result seq
        m_seq(i) = seq(end);

        %shift seq
        seq = circshift(seq, 1);

        %write in head bit from feedback
        seq(1) = x;
    end

end
