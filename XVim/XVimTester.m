//
//  XVimTest.m
//  XVim
//
//  Created by Suzuki Shuichiro on 8/18/12.
//
//

#import "XVimTester.h"
#import "XVimTestCase.h"
#import <objc/runtime.h>
#import "Logger.h"
#import "IDEKit.h"
#import "XVimKeyStroke.h"
#import "XVimUtil.h"


@implementation XVimTester

- (void)createTestCases{
    // Text Definitions
    static NSString* text0 = @"aaa bbb ccc\n";
    
    static NSString* text1 = @"aaa\n"   // 0  (index of each WORD)
                             @"bbb\n"   // 4
                             @"ccc";    // 8
    
    static NSString* text2 = @"a;a bbb ccc\n"  // 0  4  8
                             @"ddd e-e fff\n"  // 12 16 20
                             @"ggg hhh i_i\n"  // 24 28 32
                             @"    jjj kkk";   // 36 40 44
    
    static NSString* a_result = @"aaa bbXXXb ccc\n";
    static NSString* A_result = @"aaa bbb cccXXX\n";
   
    static NSString* cw_result1 = @"aaa baaa ccc\n";
    static NSString* cw_result2 = @"aaa bbb caaa\n";
    // Test Cases
    /*
     You can use "\x1B" to ESC
                 "\r"   to Enter
    */
    self.testCases      = [NSArray arrayWithObjects:
                          // Motions
                          // b, B
                          XVimMakeTestCase(text2,  6, 0,  @"b", text2,  4, 0),
                          XVimMakeTestCase(text2, 14, 0, @"3b", text2,  4, 0),
                          XVimMakeTestCase(text2,  4, 0,  @"B", text2,  0, 0),
                          XVimMakeTestCase(text2, 27, 0, @"3B", text2, 16, 0),
                          
                          // e, E
                          XVimMakeTestCase(text2, 16, 0,  @"e", text2, 17, 0),
                          XVimMakeTestCase(text2, 17, 0, @"3e", text2, 26, 0),
                          XVimMakeTestCase(text2, 16, 0,  @"E", text2, 18, 0),
                          XVimMakeTestCase(text2, 16, 0, @"3E", text2, 26, 0),
                          
                          // f, F
                          XVimMakeTestCase(text2,  0, 0,  @"fc", text2,  8, 0),
                          XVimMakeTestCase(text2,  0, 0, @"2fc", text2,  9, 0),
                          XVimMakeTestCase(text2, 18, 0,  @"Fd", text2, 14, 0),
                          XVimMakeTestCase(text2, 18, 0, @"2Fd", text2, 13, 0),
                          XVimMakeTestCase(text2, 24, 0, @"4fi", text2, 24, 0), // error case
                          
                          // g, G
                          XVimMakeTestCase(text2, 44, 0,  @"gg", text2,  8, 0),
                          XVimMakeTestCase(text2, 44, 0, @"3gg", text2, 32, 0),
                          XVimMakeTestCase(text2,  8, 0, @"9gg", text2, 44, 0),
                          XVimMakeTestCase(text2,  4, 0,   @"G", text2, 40, 0),
                          XVimMakeTestCase(text2, 44, 0,  @"3G", text2, 32, 0),
                          XVimMakeTestCase(text2,  8, 0,  @"9G", text2, 44, 0),
                           
                          
                          // h,j,k,l, <space>
                          XVimMakeTestCase(text1, 0, 0,   @"l", text1, 1, 0),
                          XVimMakeTestCase(text1, 0, 0, @"10l", text1, 2, 0),
                          XVimMakeTestCase(text1, 0, 0,   @"j", text1, 4, 0),
                          XVimMakeTestCase(text1, 0, 0, @"10j", text1, 8, 0),
                          XVimMakeTestCase(text1, 4, 0,   @"k", text1, 0, 0),
                          XVimMakeTestCase(text1, 1, 0,   @"h", text1, 0, 0),
                          XVimMakeTestCase(text1, 0, 0,   @" ", text1, 1, 0),
                          XVimMakeTestCase(text1, 0, 0, @"10 ", text1, 2, 0),
                          
                          // t, T
                          XVimMakeTestCase(text2,  0, 0,  @"tc", text2,  7, 0),
                          XVimMakeTestCase(text2,  0, 0, @"2tc", text2,  8, 0),
                          XVimMakeTestCase(text2, 18, 0,  @"Td", text2, 15, 0),
                          XVimMakeTestCase(text2, 18, 0, @"2Td", text2, 14, 0),
                          XVimMakeTestCase(text2, 24, 0, @"4ti", text2, 24, 0), // error case
                          
                          // w, W
                          XVimMakeTestCase(text2, 0, 0,  @"w", text2,  1, 0),
                          XVimMakeTestCase(text2, 0, 0, @"4w", text2,  8, 0),
                          XVimMakeTestCase(text2, 0, 0,  @"W", text2,  4, 0),
                          XVimMakeTestCase(text2, 0, 0, @"4W", text2, 16, 0),
                          
                          // 0, $, ^
                          XVimMakeTestCase(text2, 10, 0,   @"0", text2,  0, 0),
                          XVimMakeTestCase(text2,  0, 0,   @"$", text2, 10, 0),
                          XVimMakeTestCase(text2, 44, 0,   @"^", text2, 40, 0),
                          XVimMakeTestCase(text2, 44, 0, @"10^", text2, 40, 0), // Number does not affect caret
                          XVimMakeTestCase(text2, 36, 0,   @"^", text2, 40, 0),
                          XVimMakeTestCase(text2, 36, 0,   @"_", text2, 40, 0),
                          XVimMakeTestCase(text2, 32, 0,  @"2_", text2, 40, 0),
                          
                          // +, -, <CR>
                          XVimMakeTestCase(text2, 28, 0,  @"+", text2, 40, 0),
                          XVimMakeTestCase(text2, 16, 0, @"2+", text2, 40, 0),
                          XVimMakeTestCase(text2, 40, 0,  @"-", text2, 24, 0),
                          XVimMakeTestCase(text2, 40, 0, @"2-", text2, 12, 0),
                          XVimMakeTestCase(text2, 28, 0, @"\r", text2, 40, 0),
                          XVimMakeTestCase(text2, 16, 0,@"2\r", text2, 40, 0),
                          
                          // H,M,L
                          //TODO: Implement test for H,M,L. These needs some special test check method since we have to calc the height of the view.
                        
                          // Arrows( left,right,up,down )
                          
                          // Home, End, DEL
                          
                          // Motion type enforcing(v,V, Ctrl-v)
                          
                          // Searches (/,?,n,N,*,#)
                          
                          // , ; (comma semicolon) for f F
                          XVimMakeTestCase(text2, 0, 0,  @"2fb;", text2, 6, 0),
                          XVimMakeTestCase(text2, 0, 0,  @"fb2;", text2, 6, 0),
                          XVimMakeTestCase(text2, 0, 0,  @"2fb,", text2, 4, 0),
                          XVimMakeTestCase(text2, 0, 0, @"3fb2,", text2, 4, 0),
                           
                          XVimMakeTestCase(text2, 8, 0, @"2Fb;", text2, 4, 0),
                          XVimMakeTestCase(text2, 8, 0, @"Fb2;", text2, 4, 0),
                          XVimMakeTestCase(text2, 8, 0, @"2Fb,", text2, 6, 0),
                          XVimMakeTestCase(text2, 8, 0, @"3Fb2,", text2, 6, 0),
                           
                          // , ; (comma semicolon) for t T
                           
                          // Marks
                          XVimMakeTestCase(text2, 5,  0, @"majj3l`a", text2, 5, 0),
                          XVimMakeTestCase(text2, 5,  0, @"majj3l'a", text2, 0, 0),
                          
                          // Registers
                          
                          // Edits
                          // a, A
                          XVimMakeTestCase(text0, 5,  0, @"aXXX\x1B", a_result, 8, 0), // aXXX<ESC>
                          XVimMakeTestCase(text0, 5,  0, @"AXXX\x1B", A_result, 13, 0), // AXXX<ESC>
                          
                          // c, C
                          XVimMakeTestCase(text0, 5,  0, @"cwaaa\x1B", cw_result1, 7, 0), // aXXX<ESC>
                          XVimMakeTestCase(text0, 9,  0, @"cwaaa\x1B", cw_result2, 13, 0), // AXXX<ESC>
                           
                          
                          // Scrolls
                         
                          // Recordings
                           
                          // Key remaping
                          
                          // Visual mode
                           
                          // End of Test Cases
                          nil
                          ];
}

- (void)runTest{
    // Create Test Cases
    [self createTestCases];
    NSArray* testArray = self.testCases;
    
    // Alert Dialog to confirm current text will be deleted.
    NSAlert* alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Make it sure that a source test view has a focus now.\r Running test deletes text in current source text view. Proceed?"];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    NSInteger b = [alert runModal];
    
    // Run test for all the cases
    if( b == NSAlertFirstButtonReturn ){
        // test each
        for( NSUInteger i = 0; i < testArray.count; i++ ){
            [(XVimTestCase*)[testArray objectAtIndex:i] run];
        }
    }
    
    // Setup Talbe view to show result
    NSTableView* tableView= [[[NSTableView alloc] init] autorelease];
    [tableView setDataSource:self];
    NSTableColumn* column1 = [[NSTableColumn alloc] initWithIdentifier:@"Description" ];
    [column1.headerCell setStringValue:@"Description"];
    NSTableColumn* column2 = [[NSTableColumn alloc] initWithIdentifier:@"Pass/Fail" ];
    [column2.headerCell setStringValue:@"Pass/Fail"];
    
    [tableView addTableColumn:column1];
    [tableView addTableColumn:column2];
    [tableView setAllowsMultipleSelection:YES];
    [tableView reloadData];
    
    // Setup the table view into scroll view
    NSScrollView* scroll = [[[NSScrollView alloc] initWithFrame:NSMakeRect(0,0,300,300)] autorelease];
    [scroll setDocumentView:tableView];
    [scroll setHasVerticalScroller:YES];
    [scroll setHasHorizontalScroller:YES];
    
    // Show it as a modal
    alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Result"];
    [alert setAccessoryView:scroll];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    return (NSInteger)[self.testCases count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    if( [aTableColumn.identifier isEqualToString:@"Description"] ){
        return [(XVimTestCase*)[self.testCases objectAtIndex:(NSUInteger)rowIndex] description];
    }else if( [aTableColumn.identifier isEqualToString:@"Pass/Fail"] ){
        return ((XVimTestCase*)[self.testCases objectAtIndex:(NSUInteger)rowIndex]).success ? @"Pass" : @"Fail";
    }
    return nil;
}

@end
