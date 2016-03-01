//
//  BinderPlugin.m
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/17/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

#import "BinderPlugin.h"
#import "BinderPlugin+Helpers.h"
#import "BinderPlugin+AddBinder.h"
#import "BinderPlugin+UpdateBinder.h"
#import "BinderPlugin+RemoveBinder.h"
#import <sys/stat.h>

@interface BinderPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation BinderPlugin

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)notification
{
    //Initialize binder endpoint URL dictionary
    binderEndpointURLs = [[NSMutableDictionary alloc] init];
    
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        addBinderMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add Binder Reference"
                                                       action:@selector(addBinderReference) keyEquivalent:@""];
        [addBinderMenuItem setTarget:self];
        [addBinderMenuItem setKeyEquivalent:@"B"];
        [addBinderMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSControlKeyMask];
        [[menuItem submenu] addItem:addBinderMenuItem];
        
//        updateBinderMenuItem = [[NSMenuItem alloc] initWithTitle:@"Update Binder Reference"
//                                                                      action:@selector(updateBinderReference) keyEquivalent:@""];
//        [updateBinderMenuItem setTarget:self];
//        [updateBinderMenuItem setKeyEquivalent:@"B"];
//        [updateBinderMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask | NSShiftKeyMask];
//        [[menuItem submenu] addItem:updateBinderMenuItem];
        
        removeBinderMenuItem = [[NSMenuItem alloc] initWithTitle:@"Remove Binder Reference"
                                                          action:@selector(removeBinderFilesAndReferences) keyEquivalent:@""];
        [removeBinderMenuItem setTarget:self];
        [[menuItem submenu] addItem:removeBinderMenuItem];
    }
}

#pragma mark - Dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
