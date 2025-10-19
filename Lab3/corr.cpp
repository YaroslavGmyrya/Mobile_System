#include <iostream>
#include <vector>
#include <cmath>

double corr(std::vector<int>& a, std::vector<int>& b){

    if(a.size() != b.size()){
        printf("Vector must be the same size\n");
        return 0;
    }

    double result = 0;

    for(int i = 0; i < a.size(); ++i){
        result += a[i] * b[i];
    }

    return result;
}

double norm_corr(std::vector<int>& a, std::vector<int>& b){

    double unnormal_cor = corr(a, b);

    double norm_coeff_a = 0;
    double norm_coeff_b = 0;

    for(int i = 0; i < a.size(); ++i){
        norm_coeff_a += std::pow(a[i], 2);
        norm_coeff_b += std::pow(b[i], 2);
    }

    return unnormal_cor / std::sqrt(norm_coeff_a * norm_coeff_b);
}

int main(){

        std::vector<char> letters = {'a', 'b', 'c'};

        std::vector<int> a = { 1, 2, 5, -2, -4, -2, 1, 4 };
        std::vector<int> b = { 3, 6, 7, 0, -5, -4, 2, 5 };
        std::vector<int> c = { -1, 0, -3, -9, 2, -2, 5, 1 };

        std::vector<std::vector<int>> all_vec = {a, b, c};

        printf("===== Unnormalized correlation =====\n");

        printf("\t a \t b \t c\n");

        for(int i = 0; i < all_vec.size(); ++i){

            std::vector<int> cur_vec = all_vec[i];
            printf("%c \t", letters[i]);

            for(int j = 0; j < all_vec.size(); ++j){
                printf("%.0lf \t", corr(all_vec[i], all_vec[j]));
            }

            printf("\n");
        }

        printf("\n\n");

        printf("===== Normalized correlation =====\n");

        printf("\t a \t b \t c\n");

        for(int i = 0; i < all_vec.size(); ++i){

            std::vector<int> cur_vec = all_vec[i];
            printf("%c \t", letters[i]);

            for(int j = 0; j < all_vec.size(); ++j){
                printf("%.2lf \t", norm_corr(all_vec[i], all_vec[j]));
            }

            printf("\n");
        }


        return 0;
}