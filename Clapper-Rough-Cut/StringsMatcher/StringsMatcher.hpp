//
//  Levenshtein.hpp
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 14.04.2023.
//

#include <stdio.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <vector>

using namespace std;

class StringsMatcher {
public:
    long LevenshteinDistance(const std::string& s1, const std::string& s2);
};
