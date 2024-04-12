#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <cstdio>
using namespace std;

int main()
{
    // Create a large file for writing
    string file_base_name = "huge_io_file";
    int iter = 0;
    while (true)
    {
        std::ostringstream filename;
        filename << file_base_name << '_' << iter++;
        const int numLines = 1000000; // Number of lines to write
        // Write data to the file
        std::ofstream outputFile(filename.str());
        if (!outputFile)
        {
            std::cerr << "Error opening file for writing." << std::endl;
            return 1;
        }
        for (int i = 0; i < numLines; ++i)
        {
            outputFile << "Line " << i << ": This is some sample data for our huge file." << std::endl;
        }
        outputFile.close();
        // Read data from the file
        std::ifstream inputFile(filename.str());
        if (!inputFile)
        {
            std::cerr << "Error opening file for reading." << std::endl;
            return 1;
        }
        string line;
        while (std::getline(inputFile, line))
        {
            // Process each line (you can do something more meaningful here)
            // For now, let's just print the line to the console
            std::cout << line << std::endl;
        }
        inputFile.close();
        remove(filename.str().c_str());
    }
    return 0;
}