//
//  Parser.m
//  Milestone2
//
//  Created by Marty Ulrich on 2/12/14.
//  Copyright (c) 2014 Marty Ulrich/David Merrick. All rights reserved.
//

#import "Parser.h"
#import "Environment.h"
#import "Stmt.h"

@interface Parser ()

@property (strong, nonatomic) LexicalAnalyzer *lex;
@property (strong, nonatomic) Token *lookAhead;
@property (nonatomic) int used;
@property (strong, nonatomic) Environment *top;

@end

@implementation Parser

- (instancetype)initWithLexicalAnalyzer:(LexicalAnalyzer*)theLex
{
    self = [super init];
    if (self) {
        _lex = theLex;
		_used = 0;
		[self move];
    }
    return self;
}

- (void)move
{
	self.lookAhead = [self.lex scan];
}

- (void)error:(NSString*)errorType
{
	[NSException raise:errorType format:@"Error near line %i", [[self.lex class] line]];
}

- (void)match:(int)aTag
{
	if (self.lookAhead.tag == aTag)
		[self move];
	else
		[self error:@"syntax error"];
}

/** expr -> oper | stmts */
- (void)expr
{
	[self oper];
	[self stmts];
}

/** oper -> [:= name oper] | [binops oper oper] | [unops oper] | constants | name */
- (void) oper
{
	if ([self match:'['])
	{
		[self match:':']
	}
}




- (Stmt*)block
{
	[self match:'{'];
	Environment *savedEnv = self.top;
	self.top = [[Environment alloc] initWithParentEnvironment:self.top];
	[self decls];
	Stmt *s = [[Stmt alloc] init];
	[self match:'}'];
	self.top = savedEnv;
	return s;
}

- (void)program
{
	Stmt *s = [self block];
	int begin = [s newLabel];
	int after = [s newLabel];
	[s emitLabel:begin];
	// this is what it looks like to send anonymous arguments.  check gen's signature.
	[s gen:begin:after];
	[s emitLabel:after];
}

@end
