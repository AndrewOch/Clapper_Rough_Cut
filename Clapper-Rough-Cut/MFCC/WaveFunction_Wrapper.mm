//
//  WaveFunction_Wrapper.m
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 14.04.2023.
//

#import "WaveFunction_Wrapper.h"
#import "WaveFunction.hpp"

@implementation WaveFunction_Wrapper

- (NSArray<NSArray<NSNumber *> *> *)getMFCCsWithFilePath:(NSString *)filePath {
    WaveFunction* a = new WaveFunction(320, 7);
    vector<vector<float>> mfccs1 = a->getMFCCs([filePath UTF8String]);
    mfccs1 = a->addOrderDifference(mfccs1);
    
    NSMutableArray<NSMutableArray<NSNumber *> *> *mfccsArray = [NSMutableArray new];
    for (auto &row : mfccs1) {
        NSMutableArray<NSNumber *> *rowArray = [NSMutableArray new];
        for (auto &element : row) {
            [rowArray addObject:[NSNumber numberWithFloat:element]];
        }
        [mfccsArray addObject:rowArray];
    }
    delete a;
    return mfccsArray;
}

- (float)computeDTW:(NSArray<NSArray<NSNumber *> *> *)mfcc1 :(NSArray<NSArray<NSNumber *> *> *)mfcc2 {
    WaveFunction* a = new WaveFunction(320, 7);

    std::vector<std::vector<float>> mfcc1Vector;
    for (NSArray<NSNumber *> *row in mfcc1) {
        std::vector<float> rowVector;
        
        for (NSNumber *number in row) {
            float floatValue = [number floatValue];
            rowVector.push_back(floatValue);
        }
        
        mfcc1Vector.push_back(rowVector);
    }
    
    std::vector<std::vector<float>> mfcc2Vector;
    for (NSArray<NSNumber *> *row in mfcc2) {
        std::vector<float> rowVector;
        
        for (NSNumber *number in row) {
            float floatValue = [number floatValue];
            rowVector.push_back(floatValue);
        }
        
        mfcc2Vector.push_back(rowVector);
    }
    float dist = a->ComputeDTW(mfcc1Vector, mfcc2Vector);
    delete a;
    return dist;
}

@end
