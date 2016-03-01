//
//  HKHealthStore+AAPLExtensions.h
//  wechatplus
//
//  Created by xuqidong on 16/3/1.
//  Copyright © 2016年 baozoumanhua. All rights reserved.
//

#import <HealthKit/HealthKit.h>

@import HealthKit;

@interface HKHealthStore (AAPLExtensions)

// Fetches the single most recent quantity of the specified type.
- (void)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(NSArray *results, NSError *error))completion;

@end

