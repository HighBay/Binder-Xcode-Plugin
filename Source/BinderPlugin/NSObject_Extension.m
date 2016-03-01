//
//  NSObject_Extension.m
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/17/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//


#import "NSObject_Extension.h"
#import "BinderPlugin.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[BinderPlugin alloc] initWithBundle:plugin];
        });
    }
}
@end
