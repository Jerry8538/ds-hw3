#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
using namespace std;

int main(int argc, char* argv[]) {
    if (argc != 3) {
        cerr << "Usage: ./mapper <matrix_B_file> <matrix_A_split_file>\n";
        return 1;
    }

    std::vector<std::vector<int>> B;
    std::ifstream b_file(argv[1]);
    std::string line;

    while (std::getline(b_file, line)) {
        std::stringstream ss(line);

        int row_id; ss >> row_id;

        int val;
        std::vector<int> row;
        while (ss >> val) {
            row.push_back(val);
        }
        if (!row.empty()) B.push_back(row);
    }

    ifstream a_file(argv[2]);
    while (getline(a_file, line)) {
        stringstream ss(line);

        int row_id;
        if (!(ss >> row_id)) continue;
        
        vector<int> a_row;
        int val;
        while (ss >> val) {
            a_row.push_back(val);
        }

        int num_cols_B = B.empty() ? 0 : B[0].size();
        vector<int> c_row(num_cols_B, 0);
        
        for (size_t k = 0; k < a_row.size() && k < B.size(); ++k) {
            for (int j = 0; j < num_cols_B; ++j) {
                c_row[j] += a_row[k] * B[k][j];
            }
        }

        cout << row_id;
        for (int v : c_row) {
            cout << " " << v;
        }
        cout << "\n";
    }
}
