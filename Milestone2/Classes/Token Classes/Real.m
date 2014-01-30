//
//  Real.m
//  Milestone2
//
//  Created by Marty Ulrich on 1/28/14.
//  Copyright (c) 2014 Marty Ulrich/David Merrick. All rights reserved.
//

#import "Real.h"

@implementation Real

- (instancetype)initWithValue:(float)val
{
    self = [super initWithTag:REAL];
    if (self) {
        _value = val;
    }
    return self;
}

+ (instancetype) realWithValue:(float)val
{
	return [[[self class] alloc] initWithValue:val];
}

-(NSString*)description
{
	NSString *str = [NSString stringWithFormat:@"<%@, val:%f>", [self class], self.value];
	return str;
}

@end