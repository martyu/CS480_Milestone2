//
//  Token.m
//  Milestone2
//
//  Created by Marty Ulrich on 1/25/14.
//  Copyright (c) 2014 Marty Ulrich/David Merrick. All rights reserved.
//

#import "Token.h"

@implementation Token

- (instancetype) initWithAttribute:(id)theAttribute location:(struct TokenLocation)theLocation type:(TokenType*)theType
{
    self = [super init];
    if (self) {
		_attribute = theAttribute;
		_type = theType;
    }
    return self;
}

struct TokenLocation tokenLocationMake(int theLine, int theRow)
{
	struct TokenLocation loc;
	loc.line = theLine;
	loc.row = theRow;

	return loc;
}

@end
