//
//  Levenshtein.cpp
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 14.04.2023.
//

#include "StringsMatcher.hpp"
#include <iostream>
#include <string>
#include <algorithm>
#include <vector>
#include <cctype>

using namespace std;

long StringsMatcher::LevenshteinDistance(const string& s1, const string& s2) {
    
    if (s1.size() > s2.size()) {
        return LevenshteinDistance(s2, s1);
    }
    
    using TSizeType = typename string::size_type;
    const TSizeType min_size = s1.size(), max_size = s2.size();
    vector<TSizeType> lev_dist(min_size + 1);
    
    for (TSizeType i = 0; i <= min_size; ++i) {
        lev_dist[i] = i;
    }
    
    for (TSizeType j = 1; j <= max_size; ++j) {
        TSizeType previous_diagonal = lev_dist[0], previous_diagonal_save;
        ++lev_dist[0];
        
        for (TSizeType i = 1; i <= min_size; ++i) {
            previous_diagonal_save = lev_dist[i];
            if (s1[i - 1] == s2[j - 1]) {
                lev_dist[i] = previous_diagonal;
            } else {
                lev_dist[i] = min(min(lev_dist[i - 1], lev_dist[i]), previous_diagonal) + 1;
            }
            previous_diagonal = previous_diagonal_save;
        }
    }
    
    return lev_dist[min_size];
}
