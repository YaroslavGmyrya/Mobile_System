#include <iostream>
#include <cmath>

#define NUMBER_IN_JOURNAL 6
#define NUM_FORMAT 5
#define MAX_BIT_SIZE pow(2, NUM_FORMAT) - 1

#define ENDL printf("\n")
#define TAB printf("\t")


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
int m_seq_gen(T x_seq, int* poly, int poly_size){

    int result = 0;

    //for xor operation
    int x;

    for(int i = MAX_BIT_SIZE-1; i >= 0; --i){
        x = 0;
        //add to result last bit
        result |= (x_seq & 1) << i;

        //compute feedback value
        for(int j = 0; j < poly_size; ++j){
            x ^= (x_seq >>  poly[j]) & 1;
        }

        //shift and add xor operation result in first bit of x_seq
        x_seq = ((x_seq >> 1) | (x << (NUM_FORMAT-1)));
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

void check_balance(int pn_seq, int size){
    
    int count1 = 0;

    for(int i = 0; i < size; ++i){
        if((pn_seq>>i) & 1){
            ++count1;
        } 
    }

    int count0 = size - count1;

    printf("count0 = %d \t count1 = %d", count0, count1);
}

void check_autocorr(int pn_seq){

    int coincided, non_coincided;
    double c1 = -1.0/static_cast<double>(MAX_BIT_SIZE);
    double c2 = (pow(2, (NUM_FORMAT+1)/2) - 1)/static_cast<double>(MAX_BIT_SIZE);
    double c3 = (-pow(2, (NUM_FORMAT+1)/2) - 1)/static_cast<double>(MAX_BIT_SIZE);

    double normal_value[3] = {c1, c2, c3};
    double autocorr = 0;

    int k;

    for(int i = 1; i < MAX_BIT_SIZE; ++i){
        k = 0;

        bit_seq_compare(pn_seq, cycle_shift(pn_seq, i), coincided, non_coincided);

        autocorr = (coincided - non_coincided) / static_cast<double>(MAX_BIT_SIZE);

        for(int j = 0; j < 3; ++j){
            if(autocorr == normal_value[j]){
                ++k;
            }
        }

        if(k!=1){
            printf("\nInvalid autocorr value\n");
            return;
        }
    }

    printf("Autocorr: OK");
}


void check_cycle(int pn_seq){
    int cycles_count[10] = {0};
    int prev_bit = (pn_seq  >> 0) & 1;
    int tmp = 1;

    for(int i = 1; i < MAX_BIT_SIZE; ++i){
        int cur_bit = (pn_seq  >> i) & 1;

        if(cur_bit == prev_bit){
            ++tmp;
        } else{
            ++cycles_count[tmp];
            tmp = 1;
        }

        prev_bit = cur_bit;
    }

    for(int i = 0; i < 10; ++i){
        printf("%d ", cycles_count[i]);
    }

    double sum = 0;

    TAB;

    for(int i = 0; i < 10; ++i){
        sum += cycles_count[i];
    }

    for(int i = 1; i < 10; ++i){
        if(!(cycles_count[i] == static_cast<int>(sum / (pow(2, i))) + 1 || 
            cycles_count[i] == static_cast<int>(sum / (pow(2, i))) - 1 || 
            cycles_count[i] == static_cast<int>(sum / (pow(2, i))))){
                printf("Not OK");
                return;
            }
    }

    printf("OK");
}

// void recovery_balance(int& pn_seq, int size, int count0, int count1){
//     if(count0 > count1){
//         int i = 0;
//         while(abs(count0 - count1) != 1){
//             double r = 1/(rand() % 10);
//             if(!((pn_seq>>i) & 1) && r > 0.8){
//                 pn_seq ^= (1 << i);
//                 --count0;
//                 ++count1;
//             }

//             ++i;
//             if(i == size)
//                 i = 0;

//         }
//     } else{
//         int i = 0;
//         while(abs(count0 - count1) != 1){
//             double r = 1/(rand() % 10);
//             if(((pn_seq>>i) & 1) && r > 0.8){
//                 pn_seq ^= (1 << i);
//                 ++count0;
//                 --count1;
//             }
//             ++i;
//             if(i == size)
//                 i = 0;
//         }
//     }
// }

// int gcd(int a, int b) {
//     while (b != 0) {
//         int temp = b;
//         b = a % b;
//         a = temp;
//     }
//     return a;
// }

// int find_decimation_coeff(int m){
//     int k = 0;
//     for(k = 1; k < (m-1)/2; ++k){
//         if(gcd(k, m) == 1){
//            break;
//         }
//     }

//     return static_cast<int>(pow(2,k)+1);
// }

// int decimation(int m_seq, int seq_size, int d) {
//     int result = 0;

//     for (int n = 0; n < seq_size; ++n) {
//         int i = (n * d) % seq_size;

//         int bit_index_in = seq_size - 1 - i;

//         int bit = (m_seq >> bit_index_in) & 1;

//         int bit_index_out = seq_size - 1 - n;

//         if (bit)
//             result |= (1 << bit_index_out);
//     }

//     return result;
// }


int find_shift(int m_seq1, int m_seq2){
    int shift = -1;
    int coincided, non_coincided;

    for(int i = 0; i < MAX_BIT_SIZE; ++i){
        bit_seq_compare(m_seq1, cycle_shift(m_seq2, i), coincided, non_coincided);

        if(abs(coincided - non_coincided) == 1 || abs(coincided - non_coincided) == 0){
            shift = i;
            break;
        }
    }

    return shift;
}

int main(){
    srand(time(0));

    //define base seq 
    int n1 = 4;
    int n2 = 6 + 3;

    int n3 = 6;
    int n4 = 7;

    int poly1[] = {0, 2}; 
    int poly2[] = {0, 2, 3, 4};

    int m_seq1 = m_seq_gen(n1, poly1, 2);
    int m_seq2 = m_seq_gen(n2, poly2, 4);

    int m_seq3 = m_seq_gen(n3, poly1, 2);
    int m_seq4 = m_seq_gen(n4, poly2, 4);

    printf("m_seq1: \t");
    print_bin(m_seq1);
    TAB;
    check_balance(m_seq1, MAX_BIT_SIZE);

    ENDL;

    printf("m_seq2: \t");
    print_bin(m_seq2);
    TAB;
    check_balance(m_seq2, MAX_BIT_SIZE);

    ENDL;
    int shift = find_shift(m_seq1, m_seq2);
    // printf("shift: %d", shift);
    int golden_seq1 = m_seq1 ^ cycle_shift(m_seq2, shift);
    printf("golden_seq1: \t");
    print_bin(golden_seq1);
    TAB;
    check_balance(golden_seq1, MAX_BIT_SIZE);
    TAB;
    check_autocorr(golden_seq1);
    TAB;
    check_cycle(golden_seq1);


    ENDL;


    printf("m_seq3: \t");
    print_bin(m_seq3);
    TAB;
    check_balance(m_seq3, MAX_BIT_SIZE);

    ENDL;

    printf("m_seq4: \t");
    print_bin(m_seq4);
    TAB;
    check_balance(m_seq4, MAX_BIT_SIZE);

    ENDL;

    shift = find_shift(m_seq3, m_seq4);

    // printf("shift: %d", shift);
    int golden_seq2 = m_seq3 ^ cycle_shift(m_seq4,shift);
    printf("golden_seq2: \t");
    print_bin(golden_seq2);
    TAB;
    check_balance(golden_seq2, MAX_BIT_SIZE);
    TAB;
    check_autocorr(golden_seq2);
    TAB;
    check_cycle(golden_seq2);


    ENDL;

    int coincided = 0;
    int non_coincided = 0;

    printf("\nlag:\t\toriginal golden_seq:\t\t\t\t\t\t\tshift golden_seq:\t\t\t  c:\tnc:\tcorr:\n");

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

        printf("\nlag:\t\toriginal golden_seq:\t\t\t\t\t\t\tshift golden_seq:\t\t\t  c:\tnc:\tcorr:\n");

    for(int i = 0; i < MAX_BIT_SIZE+1; ++i){
        printf("%d  ", i);
    
        bit_seq_compare(golden_seq2, cycle_shift(golden_seq2, i), coincided, non_coincided);

        print_bin(golden_seq2);

        printf("  ");

        print_bin(cycle_shift(golden_seq2, i));

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