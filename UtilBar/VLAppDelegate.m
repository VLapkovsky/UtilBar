//
//  VLAppDelegate.m
//  UtilBar
//
//  Created by Vitaly on 4/16/16.
//  Copyright © 2016 Vitaly. All rights reserved.
//

#import "VLAppDelegate.h"

@interface VLAppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusMenuBar;

@end

@implementation VLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.statusMenuBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSImage *icon = [NSImage imageNamed:@"menu-icon"];
    NSImage *highlightIcon =[NSImage imageNamed:@"menu-icon"]; // Using the exact same image asset.
    [highlightIcon setTemplate:YES]; // Allows the correct highlighting of the icon when the menu is clicked.
    
    [[self statusMenuBar] setImage:icon];
    [[self statusMenuBar] setAlternateImage:highlightIcon];
    [[self statusMenuBar] setHighlightMode:YES];
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem *actionShowAllFile = [[NSMenuItem alloc] initWithTitle: @"Show All Files"
                                                               action: @selector(showHideAllFiles:)
                                                        keyEquivalent: @""];
    [actionShowAllFile setEnabled: YES];
    [actionShowAllFile setState: [self checkShowHideAllFiles]];
    [menu addItem:actionShowAllFile];
    
    [menu addItem: [NSMenuItem separatorItem]];

    [menu addItemWithTitle: @"Quit" action:@selector(terminate:) keyEquivalent:@""];
    self.statusMenuBar.menu = menu;
}

- (BOOL) checkShowHideAllFiles {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/defaults";
    task.arguments = @[@"read", @"com.apple.finder", @"AppleShowAllFiles"];
    
    NSPipe *output = [NSPipe pipe];
    [task setStandardOutput:output];
    
    [task launch];
    [task waitUntilExit];
    
    NSFileHandle * read = [output fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    return [stringRead boolValue];
}

- (void) showHideAllFiles:(id)sender {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/defaults";
    
    NSMenuItem* menuItem = (NSMenuItem*)sender;
    
    if (menuItem.state == NSOffState) {
        menuItem.state = NSOnState;
        task.arguments = @[@"write", @"com.apple.finder", @"AppleShowAllFiles", @"YES"];
    }
    else {
        menuItem.state = NSOffState;
        task.arguments = @[@"write", @"com.apple.finder", @"AppleShowAllFiles", @"NO"];
    }
    
    [task launch];
    [task waitUntilExit];
    
    NSTask *killFinder = [[NSTask alloc] init];
    killFinder.launchPath = @"/usr/bin/killall";
    killFinder.arguments = @[@"Finder"];
    [killFinder launch];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
