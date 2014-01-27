//
//  LexicalAnalyzer.m
//  Milestone2
//
//  Created by Marty Ulrich on 1/25/14.
//  Copyright (c) 2014 Marty Ulrich/David Merrick. All rights reserved.
//

#import "LexicalAnalyzer.h"
#import "Token.h"
#import "FiniteAutomatas.h"
#import "NSString+Utils.h"

@interface LexicalAnalyzer ()

@property (strong, nonatomic) NSArray *sourceCodeArr;
@property (strong, nonatomic) NSMutableArray *tokens;
/** The current token being retrieved. */
@property (nonatomic) NSUInteger index;
@property (strong, nonatomic) NSMutableDictionary *symbolTable;

@end


@implementation LexicalAnalyzer

- (instancetype)initWithSource:(NSString*)theSourceCode
{
    self = [super init];
    if (self) {
		_sourceCodeArr = [[theSourceCode stringByRemovingExcessWhitespace] componentsSeparatedByString:@" "];
		_index = 0;

    }
    return self;
}

/** Initializes and adds keyword tokens to symbol table. */
- (void)setupSymbolTable
{
	self.symbolTable = [NSMutableDictionary dictionary];
	NSString *keywordsPath = [[NSBundle mainBundle] pathForResource:@"ReservedKeywords" ofType:@"plist"];
	NSDictionary *keywordsDict = [NSDictionary dictionaryWithContentsOfFile:keywordsPath];

	Token *keywordToken;

	for (NSString *category in [keywordsDict allKeys])
	{
		for (NSString *lexeme in keywordsDict[category])
		{
			keywordToken = [[Token alloc] initWithAttribute:lexeme location:<#(struct TokenLocation)#> type:<#(NSString *)#>]
		}
	}
}

- (Token*)getNextToken
{
	Token *token;
	Lexeme *lexeme = self.sourceCodeArr[self.index];

	for (FiniteAutomata *dfa in [self DFAs])
	{
		if ([dfa acceptsWord:lexeme])
		{
			token = [[Token alloc] initWithAttribute:nil location:tokenLocationMake(0, 0) type:dfa.type];
		}
	}

	self.index++;

	return token;
}

// The list of all DFAs.
- (NSArray*)DFAs
{
	NSArray *dfaFileNames = @[@"RelOpDFA"];
	NSMutableArray *dfaArr = [NSMutableArray array];
	FiniteAutomata *dfa;

	for (NSString *fileName in dfaFileNames)
	{
		dfa = [[FiniteAutomata alloc] initWithDFAPlist:fileName];
		[dfaArr addObject:dfa];
	}

	return [NSArray arrayWithArray:dfaArr];
}

@end