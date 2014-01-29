//
//  AppDelegate.m
//  Milestone2
//
//  Created by Marty Ulrich on 1/25/14.
//  Copyright (c) 2014 Marty Ulrich/David Merrick. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "LexicalAnalyzer.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSString *source = @"int num = 5; if(num == 5)float x = num - 5";

	LexicalAnalyzer *lex = [[LexicalAnalyzer alloc] initWithSource:source];
	Token *token = [lex scan];

	while (token) {
		NSLog(@"token: %@\n", token);
		token = [lex scan];
	}
}

@end
