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
#import "Defines.h"
#import "Word.h"
#import "Tree.h"

@interface Parser ()

@property (strong, nonatomic) LexicalAnalyzer *lex;
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

-(Token *)getNextToken
{
    Token *current_token = [self.lex scan];
    //@todo: Make sure lookAhead always has the next one
    //self.lookAhead = [self.lex scan];
    return current_token;
}

// Use getNextToken instead
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


#pragma mark - Productions


/** T -> [S] //This is where we start. */
- (Tree*) T:(Token*)t
{
	Tree *tempTree = [[Tree alloc] init];
    if (t.tag == '['){
        [tempTree addChild:[[Tree alloc] initWithToken:t]];
		
        //S
        t = [self getNextToken];
        [tempTree addChild:[self S:t]];
        
        t = [self getNextToken];
        if (t.tag == ']'){
            [tempTree addChild:[[Tree alloc] initWithToken:t]];
            return tempTree;
        } else {
            [self error:@"syntax error"];
        }
    } else {
        [self error:@"syntax error"];
    }
    return tempTree;
}

/** S -> [ ] | [S] | SS | expr */
- (Tree*) S:(Token*)t
{
    //@todo: finish this method
    Tree *tempTree = [[Tree alloc] init];
    return tempTree;
}

/** expr -> oper | stmts */
- (void) expr
{
//	[self oper];
	[self stmts];
}

/** oper -> [:= name oper] | [binops oper oper] | [unops oper] | constants | name */
- (Tree*) oper:(Token*)t
{
	Tree *tempTree = [[Tree alloc] init];
	if (t.tokType == TokenTypeConstant)
	{
		[tempTree addChild:[[Tree alloc] initWithToken:t]];
		return tempTree;
	}
    else if (t.tokType == TokenTypeName)
	{
		[tempTree addChild:[[Tree alloc] initWithToken:t]];
		return tempTree;
	}
    else if (t.tag == '[')
	{
        [tempTree addChild:[[Tree alloc] initWithToken:t]];
        
		t = [self getNextToken];
        
        if (t.tokType == TokenTypeBinOp)
        {
            // Production: [binops oper oper]
            [tempTree addChild:[[Tree alloc] initWithToken:t]];
            
            // oper
            t = [self getNextToken];
            [tempTree addChild:[self oper:t]];
            
            // oper
            t = [self getNextToken];
            [tempTree addChild:[self oper:t]];
        }
        else if (t.tokType == TokenTypeUnOp)
        {
            // Production: [unops oper]
            [tempTree addChild:[[Tree alloc] initWithToken:t]];
            
            // oper
            t = [self getNextToken];
            [tempTree addChild:[self oper:t]];
        }
        else if (t.tag == ':' && self.lookAhead.tag == '!')
        {
            // Production: [:= name oper]
            
            //Add the ':' and the '=' to the tree
            [tempTree addChild:[[Tree alloc] initWithToken:t]];
            t = [self getNextToken];
            [tempTree addChild:[[Tree alloc] initWithToken:t]];
            
            t = [self getNextToken];
            if(t.tokType == TokenTypeName)
            {
                    [tempTree addChild:[[Tree alloc] initWithToken:t]];
            }
            else
            {
                [self error:@"syntax error"];
            }
            
            //oper
            t = [self getNextToken];
            [tempTree addChild:[self oper:t]];
        }
        else
        {
            [self error:@"syntax error"];
        }

        // Finish all these productions that opened with '['
        
        t = [self getNextToken];
        if (t.tag == ']')
        {
            [tempTree addChild:[[Tree alloc] initWithToken:t]];
            return tempTree;
        }
        else {
            [self error:@"syntax error"];
        }
	} else {
        [self error:@"syntax error"];
    }
    //@todo delete this
    return tempTree;
}

/** binops -> + | - | * | / | % | ^ | = | > | >= | < | <= | != | or | and */
- (void) binOps
{
	switch (self.lookAhead.tag) {
		case '+':
			[self match:'+'];
			break;
            
		case '-':
			[self match:'-'];
			break;
            
		case '*':
			[self match:'*'];
			break;
            
		case '/':
			[self match:'/'];
			break;
            
		case '%':
			[self match:'%'];
			break;
            
		case '^':
			[self match:'^'];
			break;
            
		case '=':
			[self match:'='];
			break;
            
		case '>':
			[self match:'>'];
			break;
            
		case GE:
			[self match:GE];
			break;
            
		case '<':
			[self match:'<'];
			break;
            
		case LE:
			[self match:LE];
			break;
            
		case NEQ:
			[self match:NEQ];
			break;
            
		case OR:
			[self match:OR];
			break;
            
		case AND:
			[self match:AND];
			break;
            
		default:
			break;
	}
}

- (void) unOps
{
	switch (self.lookAhead.tag) {
		case '-':
			[self match:'-'];
			break;
            
		case NOT:
			[self match:NOT];
			break;
            
		case SIN:
			[self match:SIN];
			break;
            
		case COS:
			[self match:COS];
			break;
            
		case TAN:
			[self match:TAN];
			break;
            
		default:
			break;
	}
}

- (void) constants
{
	if ([self.lookAhead isMemberOfClass:[Word class]])
		[self strings];
	else if (self.lookAhead.tag == INT)
		[self ints];
	else if (self.lookAhead.tag == FLOAT)
		[self floats];
	else
		[self error:@"syntax error"];
}

- (void) strings
{
	if (self.lookAhead.tag == TRUE_)
		[self match:TRUE_];
	else if (self.lookAhead.tag == FALSE_)
		[self match:TRUE_];
	else if (self.lookAhead.tag == STRING)
		[self match:STRING];
	else
		[self error:@"syntax error"];
}

- (void) name
{
	[self match:ID];
}

- (void) ints
{
	[self match:INT];
}

- (void) floats
{
	[self match:FLOAT];
}

/** stmts -> ifstmts | whilestmts | letstmts | printsmts */
- (void) stmts
{
	[self match:'['];
	switch (self.lookAhead.tag)
	{
		case IF:
			[self ifstmts];
			break;
            
		case WHILE:
			[self whilestmts];
			break;
            
		case LET:
			[self letstmts];
			break;
            
		case STDOUT:
			[self printsmts];
			break;
            
		default:
			break;
	}
}

/** ifstmts -> [if expr expr expr] | [if expr expr] */
-(void) ifstmts
{
    
}

/** whilestmts -> [while expr exprlist] */
-(void) whilestmts
{
    
}

/** letstmts -> [let [varlist]] */
-(void) letstmts
{
    
}

/** varlist -> [name type] | [name type] varlist */
-(void) varlist
{
    if (self.lookAhead.tag == '[')
	{
		[self match:'['];
        [self name];
        if(self.lookAhead.tokType == TokenTypeType){
            [self match:']'];
        } else {
            //@todo: error? Another varlist?
        }
        
    }
}

/** printstmts -> [stdout oper] */
-(void) printsmts
{
    if (self.lookAhead.tag == '[')
	{
		[self match:'['];
        [self match:STDOUT];
//        [self oper];
        [self match:']'];
    } else {
        //@todo: Error?
    }
}

/** exprlist -> expr | expr exprlist */
-(void) exprlist
{
    //How to do this one?!
    /*
     if([self expr]){
     return TRUE;
     } else if([self expr] || [self exprlist]){
     return true;
     } else {
     return false;
     }
     */
}

//- (void)program
//{
//	Stmt *s = [self block];
//	int begin = [s newLabel];
//	int after = [s newLabel];
//	[s emitLabel:begin];
//	// this is what it looks like to send anonymous arguments.  check gen's signature.
//	[s gen:begin:after];
//	[s emitLabel:after];
//}

@end
