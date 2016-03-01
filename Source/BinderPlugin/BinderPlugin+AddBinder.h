//
//  BinderPlugin+AddBinder.h
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/18/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

#import "BinderPlugin.h"
#import "BinderPlugin+Helpers.h"

@interface BinderPlugin (AddBinder)

- (void)addBinderReference;
- (void)addBinderReferenceWithExistingPath:(NSString *)path;
- (void)addBinderToProject:(NSString *)projectPath;
- (void)addAllFileReferencesAndTargets:(NSString *)projectPath;
- (void)addFileReferenceAndTargetForFolderAtPath:(NSString *)path forProject:(XCProject *)project andProjectPath:(NSString *)projectPath andGroup:(XCGroup *)group;
- (void)addFileReferenceToGroup:(XCGroup *)group withProject:(XCProject *)project projectPath:(NSString *)projectPath projectName:(NSString *)projectName fileName:(NSString *)fileName fileType:(XcodeSourceFileType)fileType andNeedsToBeAddedToTarget:(BOOL)needsToBeAddedToTarget;
- (void)addTargetForFileWithProject:(XCProject *)project projectName:(NSString *)projectName filePath:(NSString *)filePath;

@end
