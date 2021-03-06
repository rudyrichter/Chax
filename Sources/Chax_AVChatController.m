/*
 * Chax_AVChatController.m
 *
 * Copyright (c) 2007-2011 Kent Sutherland
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "Chax_AVChatController.h"
#import "iChat5.h"

static BOOL allowClose = NO;

@implementation Chax_AVChatController

- (void)chax_confirmAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		allowClose = YES;
        
		[self endConference:nil];
	}
}

- (BOOL)chax_swizzle_windowShouldClose:(NSWindow *)window
{
	//Confirm closing an active AV chat. Only do so if the notifier window isn't visible and the chat is still active.
	if ([Chax boolForKey:@"ConfirmCloseAV"] && ![[self notifier] isRealWindowHidden] && [[self avChat] isActive] && !allowClose) {
		NSString *close = ChaxLocalizedString(@"Close");
		NSString *dont_close = ChaxLocalizedString(@"Don't Close");
		NSString *title = ChaxLocalizedString(@"End AV Chat?");
		NSString *msg = ChaxLocalizedString(@"Are you sure you want to end this AV chat?");
		
		NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:close alternateButton:dont_close otherButton:nil informativeTextWithFormat:msg];
		[[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
		
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(chax_confirmAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	} else {
        allowClose = YES;
    }
    
	return allowClose && [self chax_swizzle_windowShouldClose:window];
}

- (void)chax_swizzle_windowDidLoad
{
	[self chax_swizzle_windowDidLoad];
	
    IMHandle *otherHandle = [[self avChat] otherIMHandle];
    NSUInteger ardRole = [[self avChat] ardRole];
    
	//This will only accept requests to share your screen
	//ardRole - 1 means sharing your screen, 2 means sharing their screen (2 is also from an instance of ARDFullScreenClientController)
	if (ardRole == 1) {
		//Accept the screen sharing invitation if auto-accept is enabled
		if ([Chax boolForKey:@"AutoAcceptScreenSharing"]) {
			NSArray *autoAcceptContacts = [[Chax objectForKey:@"AutoAccept.ScreenSharing"] objectForKey:[(Account *)[otherHandle account] uniqueID]];
			
			if ([Chax integerForKey:@"AutoAcceptSelect.ScreenSharing"] == 0 || [autoAcceptContacts containsObject:@"Chax_AcceptAnyone"] || [autoAcceptContacts containsObject:[[otherHandle ID] lowercaseString]]) {
				[self performSelector:@selector(acceptVC:) withObject:nil afterDelay:0.5];
			}
		}
	} else if (ardRole == 0 && [Chax boolForKey:@"AutoAcceptAVChats"]) {
        //Accept the AV chat if auto-accept is enabled
        NSArray *autoAcceptContacts = [[Chax objectForKey:@"AutoAccept.AVChats"] objectForKey:[(Account *)[otherHandle account] uniqueID]];
        
        if ([Chax integerForKey:@"AutoAcceptSelect.AVChats"] == 0 || [autoAcceptContacts containsObject:@"Chax_AcceptAnyone"] || [autoAcceptContacts containsObject:[[otherHandle ID] lowercaseString]]) {
            [self performSelector:@selector(acceptVC:) withObject:nil afterDelay:0.5];
        }
	}
    
    allowClose = NO;
}

@end
