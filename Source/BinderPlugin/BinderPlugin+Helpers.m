//
//  BinderPlugin+Helpers.m
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/18/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

#import "BinderPlugin+Helpers.h"

@implementation BinderPlugin (Helpers)

- (NSURL *)currentProjectURL
{
    for (NSDocument *document in [NSApp orderedDocuments]) {
        @try {
            //_workspace(IDEWorkspace) -> representingFilePath(DVTFilePath) -> relativePathOnVolume(NSString)
            NSURL *workspaceDirectoryURL = [[[document valueForKeyPath:@"_workspace.representingFilePath.fileURL"] URLByDeletingLastPathComponent] filePathURL];
            
            if(workspaceDirectoryURL) {
                return workspaceDirectoryURL;
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"OROpenInAppCode Xcode plugin: Raised an exception while asking for the documents '_workspace.representingFilePath.relativePathOnVolume' key path: %@", exception);
        }
    }
    
    return nil;
}

@end
