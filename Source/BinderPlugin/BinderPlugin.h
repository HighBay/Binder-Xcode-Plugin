//
//  BinderPlugin.h
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/17/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "XCProject.h"
#import "XCGroup.h"
#import "ZipArchive.h"
#import "XCTarget.h"

@class BinderPlugin;

static BinderPlugin *sharedPlugin;

@interface BinderPlugin : NSObject
{
    NSMutableDictionary *binderEndpointURLs;
    NSMenuItem *addBinderMenuItem;
    NSMenuItem *updateBinderMenuItem;
    NSMenuItem *removeBinderMenuItem;
}

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end