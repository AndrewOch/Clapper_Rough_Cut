//
//  WaveFunction_Wrapper.h
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 14.04.2023.
//

#import <Foundation/Foundation.h>

@interface WaveFunction_Wrapper : NSObject

- (NSArray<NSArray<NSNumber *> *> *)getMFCCsWithFilePath:(NSString *)filePath;
- (float) computeDTW: (NSArray<NSArray<NSNumber *> *> *)mfcc1 :(NSArray<NSArray<NSNumber *> *> *)mfcc2;

@end
