/*
 * Chax_DaemonListenerStub.m
 *
 * Copyright (c) 2007-2010 Kent Sutherland
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

#import "Chax_DaemonListenerStub.h"
#import "IMCore.h"

@implementation Chax_DaemonListenerStub

- (void)chax_loadChaxAgentLib
{
    if (ChaxAgentInjectorNeedsPermissionRepair()) {
        if (NSRunAlertPanel(ChaxLocalizedString(@"Administrator password required"),
                            ChaxLocalizedString(@"Sending plain text to ICQ users requires your admin password to function properly. Please enter your admin password to enable this feature."),
                            ChaxLocalizedString(@"OK"),
                            ChaxLocalizedString(@"Cancel"), nil) == NSAlertDefaultReturn) {
            ChaxAgentInjectorRepairPermissions();
        }
    }
    
    ChaxAgentInjectorPerformInjection();
}

- (oneway void)chax_swizzle_setupComplete
{
    if ([Chax boolForKey:@"ICQPlainTextEnabled"]) {
        [self performSelector:@selector(chax_loadChaxAgentLib) withObject:nil afterDelay:1.0];
    }
    
    [self chax_swizzle_setupComplete];
}

@end
