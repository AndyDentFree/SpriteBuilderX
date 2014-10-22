/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "AboutWindow.h"
#import "AppDelegate.h"

@interface AboutWindow ()

@end

@implementation AboutWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //@"CFBundleShortVersionString"
    //kCFBundleVersionKey
    
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)@"CFBundleShortVersionString"];
    NSString* buildCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    if (version)
    {
        [txtVersion setStringValue:[NSString stringWithFormat:@"%@(%@)", version, buildCode]];
    }
    else
    {
        [btnVersion setEnabled:NO];
    }
    
    NSArray *array = [version componentsSeparatedByString:@"."];
    
    if(array.count >= 2)
        self.version = [NSString stringWithFormat:@"v%@.%@",array[0],array[1]];
    else
        self.version = [NSString stringWithFormat:@"v%@",version];
    
    // Add close button
    NSButton* closeButton = [NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:NSTitledWindowMask];
    [closeButton setFrameOrigin:NSMakePoint(21, 317)];
    NSView* contentView = self.window.contentView;
    [contentView addSubview:closeButton];
}

- (IBAction)btnViewOnGithub:(id)sender
{
    if (self.version)
    {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/newnon/SpriteBuilder/tree/%@",self.version]]];
    }
    [self.window orderOut:sender];
}

- (IBAction)btnSupportForum:(id)sender
{
    [[AppDelegate appDelegate] visitCommunity:sender];
    [self.window orderOut:sender];
}

- (IBAction)btnReportBug:(id)sender
{
    [[AppDelegate appDelegate] reportBug:sender];
    [self.window orderOut:sender];
}

- (IBAction)btnGetSource:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/apportable/SpriteBuilder"]];
    [self.window orderOut:sender];
}

- (IBAction)btnUserGuide:(id)sender
{
    [[AppDelegate appDelegate] showHelp:sender];
    [self.window orderOut:sender];
}


@end
