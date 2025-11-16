#include <iostream>
#include <cmath>

#define NUMBER_IN_JOURNAL 6
#define NUM_FORMAT 5
#define MAX_BIT_SIZE pow(2, NUM_FORMAT) - 1

template <typename T>
void print_bin(T number){

    for(int i = MAX_BIT_SIZE-1; i >= 0; --i){
        printf("%d ", (number >> i) & 1);
    }
}

template <typename T>
T cycle_shift(T number, int shift) {

    for (int i = 0; i < shift; ++i) {
        T last_bit = number & 1;                  
        number >>= 1;                            
        number |= (last_bit << (static_cast<int>(MAX_BIT_SIZE) - 1));   
    }

    return number;
}

template <typename T>
int m_seq_gen(T x_seq, int xor_bit1, int xor_bit2){

    int result = 0;

    //for xor operation
    int x1, x2 = 0;

    for(int i = MAX_BIT_SIZE-1; i >= 0; --i){
        //add to result last bit
        result |= (x_seq & 1) << i;

        //get last bit
        x1 =(x_seq >> 1 * xor_bit1) & 1;

        //get pre-last bit
        x2 = (x_seq >> 1 * xor_bit2) & 1;

        //shift and add xor operation result in first bit of x_seq
        x_seq = ((x_seq >> 1) | ((x1 ^ x2) << NUM_FORMAT-1));
    }

    return result;
}

template <typename T>
void bit_seq_compare(T seq_1, T seq_2, int& coincided, int& non_concided){

    //reset variable
    coincided = 0;
    non_concided = 0;

    //variables for bit values
    int seq_1_bit = 0;
    int seq_2_bit = 0;

    //iterate on bits
    for(int i = 0; i < MAX_BIT_SIZE; ++i){
        //get bit values
        seq_1_bit = (seq_1 >> i) & 1;
        seq_2_bit = (seq_2 >> i) & 1;

        //compare bit
        if(seq_1_bit == seq_2_bit){
            ++coincided;
        } else{
            ++non_concided;
        }

    }
}

int main(){
    int l = 3;
    //define base seq 
    int8_t x_seq1 = NUMBER_IN_JOURNAL;
    int8_t y_seq1 = NUMBER_IN_JOURNAL + 7;

    int8_t x_seq2 = NUMBER_IN_JOURNAL + l;
    int8_t y_seq2 = y_seq1 - 5;

    //output base seq

    printf("x_seq1: ");
    print_bin(x_seq1);

    printf("\n");

    printf("y_seq1: ");
    print_bin(y_seq1);

    printf("\n");

    printf("x_seq1: ");
    print_bin(x_seq2);

    printf("\n");

    printf("y_seq2: ");
    print_bin(y_seq2);

    printf("\n\n");

    //generate m-seq
    int m_seq_1 = m_seq_gen(x_seq1, 0, 1);
    int m_seq_2 = m_seq_gen(y_seq1, 0, 3);

    int m_seq_3 = m_seq_gen(x_seq2, 0, 1);
    int m_seq_4 = m_seq_gen(y_seq2, 0, 3);

    printf("m_seq1: ");
    print_bin(m_seq_1);

    printf("\n");

    printf("m_seq2: ");
    print_bin(m_seq_2);

    printf("\n");

    printf("m_seq3: ");
    print_bin(m_seq_3);

    printf("\n");

    printf("m_seq4: ");
    print_bin(m_seq_4);

    printf("\n\n");

    //generate golden-seq
    int golden_seq1 = m_seq_1 ^ m_seq_2;
    int golden_seq2 = m_seq_3 ^ m_seq_4;

    //output godlen-seq
    printf("golden-seq1: ");
    print_bin(golden_seq1);

    printf("\n");

    printf("golden-seq2: ");
    print_bin(golden_seq2);
    printf("\n\n\n");

    int coincided = 0;
    int non_coincided = 0;

    printf("lag:\t\toriginal golden_seq:\t\t\t\t\t\t\tshift golden_seq:\t\t\t  c:\tnc:\tcorr:\n");

    for(int i = 0; i < MAX_BIT_SIZE+1; ++i){
        printf("%d  ", i);
    
        bit_seq_compare(golden_seq1, cycle_shift(golden_seq1, i), coincided, non_coincided);

        print_bin(golden_seq1);

        printf("  ");

        print_bin(cycle_shift(golden_seq1, i));

        printf("  ");

        printf("%d\t%d", coincided, non_coincided);

        printf("  ");

        printf("%lf\n", (coincided - non_coincided) / static_cast<double>(MAX_BIT_SIZE));
    }

    printf("\n\n\n");

    bit_seq_compare(golden_seq1, golden_seq2, coincided, non_coincided);

    printf("Cross-corr b/w golden_seq1 & golden_seq2: %f\n\n", (coincided - non_coincided) / static_cast<double>(MAX_BIT_SIZE));


    return 0;
}