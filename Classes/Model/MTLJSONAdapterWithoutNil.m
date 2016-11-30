//
//  MTLJSONAdapterWithoutNil.m
//  BugReporter
//
//  Created by 朱安智 on 2016/11/30.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "MTLJSONAdapterWithoutNil.h"

@implementation MTLJSONAdapterWithoutNil

- (NSSet *)serializablePropertyKeys:(NSSet *)propertyKeys forModel:(id<MTLJSONSerializing>)model {
    NSMutableSet *ms = propertyKeys.mutableCopy;
    NSDictionary *modelDictValue = [model dictionaryValue];
    for (NSString *key in propertyKeys) {
        id val = [modelDictValue valueForKey:key];
        if ([[NSNull null] isEqual:val]) { // MTLModel -dictionaryValue nil value is represented by NSNull
            [ms removeObject:key];
        }
    }
    return [NSSet setWithSet:ms];
}

@end
