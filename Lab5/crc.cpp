#include <iostream>
#include <vector>
#include <numeric>

template <typename T>
std::vector<T> rm_front(const std::vector<T>& vec){
    std::vector<T> result;

    for(int i = 1; i < vec.size(); ++i){
        result.push_back(vec[i]);
    }

    return result;
}

template <typename T>
std::vector<T> push_front(const std::vector<T>& vec, T value){
    std::vector<T> result(vec.size() + 1);

    for(int i = 1; i < vec.size()+1; ++i){
        result[i] = vec[i-1];
    }

    result[0] = value;

    return result;
}


template <typename T>
void print_vec(const std::vector<T>& vec){

    //iterate on vector and printf elements
    for(T el : vec){
        printf("%d", el);
    }

    printf("\n");
}

template <typename T>
std::vector<T> crc(std::vector<T> data, std::vector<T> poly) {
    int j = 0;
    // add to data poly.size()-1 zeros
    for (int i = 0; i < poly.size() - 1; ++i)
        data.push_back(0);

    std::vector<T> result = data;

    // main cycle
    while (result.size() >= poly.size()) {
        //xor bw current result and polynome 
        for (int i = 0; i < poly.size(); ++i)
            result[i] ^= poly[i];

        //delete leading zeros in current result
        while (!result.empty() && result[0] == 0){
            result = rm_front(result);
        }
    }

    //add zeros    
    while (result.size() < poly.size() - 1){
        result = push_front(result, static_cast<T>(0));
    }

    return result;
}

std::vector<int8_t> generate_data(int N){

    std::vector<int8_t> result(N);

    for(int i = 0; i <= N; ++i){
        result[i] = rand() % 2;
    }

    return result;
}

template <typename T>
void crc_test(const std::vector<T>& data, const std::vector<T>& polynome){

    //print input values
    printf("data:     ");
    print_vec(data);

    printf("polynome: ");
    print_vec(polynome);

    //compute and print crc on TX
    std::vector<int8_t> tx_crc = crc(data, polynome);
    printf("TX CRC: ");
    print_vec(tx_crc);

    //add crc to data
    std::vector<T> data_with_crc;
    data_with_crc.reserve(data.size() + tx_crc.size());
    data_with_crc.insert(data_with_crc.begin(), data.begin(), data.end());
    data_with_crc.insert(data_with_crc.end(), tx_crc.begin(), tx_crc.end());    

    printf("data + CRC: ");
    print_vec(data_with_crc);

    //compute crc on RX
    std::vector<T> rx_crc = crc(data_with_crc, polynome);

    printf("RX CRC: ");
    print_vec(rx_crc);
}

int main(){
    int N = 20;
    int num_in_journal = 6;

    printf("\n\n########################### TEST 1 #######################################\n\n");

    std::vector<int8_t> data = generate_data(N + num_in_journal);

    std::vector<int8_t> polynome = {1,1,1,1,1,1,0,1};

    crc_test(data, polynome);

    printf("\n\n########################## TEST 2 #######################################\n\n");

    data = generate_data(250);
    polynome = {1,1,1,1,1,1,0,1};

    crc_test(data, polynome);

    printf("\n\n########################## TEST 3 #######################################\n\n");

    int errors_count = 0;

    //compute and print crc on TX
    std::vector<int8_t> tx_crc = crc(data, polynome);

    //add crc to data
    std::vector<int8_t> data_with_crc = data;

    for(int i = 0; i < tx_crc.size(); ++i){
        data_with_crc.push_back(tx_crc[i]);
    }
  
    for(int i = 0; i < data_with_crc.size(); ++i){

        //distort packet
        data_with_crc[i] ^= 1;

        //compute crc on RX
        std::vector<int8_t> rx_crc = crc(data_with_crc, polynome);

        if(std::accumulate(data_with_crc.begin(), data_with_crc.end(), 0)){
            ++errors_count;
        }

        //recovery packet
        data_with_crc[i] ^= 1;

    }

    printf("Errors_count: %d\n", errors_count);


    return 0;
}