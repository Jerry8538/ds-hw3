#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <map>
using namespace std;

int main(int argc, char* argv[]) {
    // read all out files from mappers and create complete C matrix
    if (argc < 2) {
        cerr << "Usage: ./reducer <map_out_1> <map_out_2> ...\n";
        return 1;
    }

    // since out files from mappers need not be read in order of rows
    map<int, vector<int>> C;

    for (int i = 1; i < argc; ++i) {
        ifstream map_out(argv[i]);
        string line;
        
        while (getline(map_out, line)) {
            stringstream ss(line);
            int row_id;
            if (!(ss >> row_id)) continue;

            vector<int> c_row;
            int val;
            while (ss >> val) {
                c_row.push_back(val);
            }
            C[row_id] = c_row;
        }
    }

    for (const auto& pair : C) {
        cout << pair.first; 
        for (int val : pair.second) {
            cout << " " << val;
        }
        cout << "\n";
    }
    return 0;
}
