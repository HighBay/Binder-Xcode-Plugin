//
//  BinderPlugin+RemoveBinder.m
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/19/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

#import "BinderPlugin+RemoveBinder.h"
#import "BinderPlugin+Helpers.h"
#import "XCSourceFile.h"
#import "XCTarget.h"

@implementation BinderPlugin (RemoveBinder)

- (void)removeBinderFilesAndReferences {
    // Get paths and project name
    NSString *projectPath = [[[self currentProjectURL] description]substringFromIndex:7];
    NSArray *urlParts = [projectPath componentsSeparatedByString:@"/"];
    NSString *projectName = [urlParts objectAtIndex:[urlParts count] - 2];
    NSString *projectFolderPath = [projectPath stringByAppendingString:[NSString stringWithFormat:@"%@/", projectName]];
    NSString *binderFolderPath = [projectFolderPath stringByAppendingPathComponent:@"Binder"];
    
    // Remove file references from target
//    NSString *xcodeprojUrl = [NSString stringWithFormat:@"%@%@.xcodeproj", projectPath, projectName];
//    XCProject* project = [[XCProject alloc] initWithFilePath:xcodeprojUrl];
//    NSString *binderGroupPathFromRoot = [NSString stringWithFormat:@"%@/Binder", projectName];
//    XCGroup* binderGroup = [project groupWithPathFromRoot:binderGroupPathFromRoot];
//    [self removeBinderFilesAndReferencesWithBinderPath:binderFolderPath forProject:project andProjectPath:projectPath andGroup:binderGroup];
    
    // Remove File references from project navigator
//    [self removeBinderGroupReferenceWithProjectPath:projectPath];
    
    // Remove actual files in project folder
    [[NSFileManager defaultManager] removeItemAtPath:binderFolderPath error:nil];
    
    // Clean project
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [self cleanProjectWithName:projectName];
//    });
    
    // Save project file with updates
//    [project save];
}

- (void)removeBinderGroupReferenceWithProjectPath:(NSString *)projectPath {
    NSArray *urlParts = [projectPath componentsSeparatedByString:@"/"];
    NSString *projectName = [urlParts objectAtIndex:[urlParts count] - 2];
    NSString *xcodeprojUrl = [NSString stringWithFormat:@"%@%@.xcodeproj", projectPath, projectName];
    
    // Remove all groups within binder
    XCProject* project = [[XCProject alloc] initWithFilePath:xcodeprojUrl];
    NSString *binderGroupPath = [NSString stringWithFormat:@"%@/%@", projectName, @"Binder"];
    NSString *projectFolderPath = [projectPath stringByAppendingString:[NSString stringWithFormat:@"%@/", projectName]];
    NSString *binderFolderPath = [projectFolderPath stringByAppendingPathComponent:@"Binder"];
    [self removeGroupWithPath:binderGroupPath fromProject:project andBinderFolderPath:binderFolderPath];
    
    // Remove binder group
    XCGroup* binderGroup = [project groupWithPathFromRoot:binderGroupPath];
    [binderGroup removeFromParentDeletingChildren:YES];
    [project save];
}

- (void)removeGroupWithPath:(NSString *)groupPath fromProject:(XCProject *)project andBinderFolderPath:(NSString *)binderFolderPath {
//    XCGroup *group = nil;
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:binderFolderPath error:Nil];
    for (NSString *fileOrFolderName in dirs) {
        BOOL isDir = NO;
        NSString *filePath = [binderFolderPath stringByAppendingPathComponent:fileOrFolderName];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && isDir){
            NSLog(@"Is directory");
            XCGroup *currentGroup = [project groupWithPathFromRoot:groupPath];
            NSString *nextGroupPath = [NSString stringWithFormat:@"%@/%@", currentGroup.pathRelativeToProjectRoot, fileOrFolderName];
//            group = [project groupWithPathFromRoot:nextGroupPath];
            
            // Remove all folders within folder before removing parent folder
            NSString *nextBinderFolderPath = [binderFolderPath stringByAppendingPathComponent:fileOrFolderName];
            [self removeGroupWithPath:nextGroupPath fromProject:project andBinderFolderPath:nextBinderFolderPath];
            
            if (currentGroup != nil) {
                [currentGroup removeFromParentDeletingChildren:YES];
                
            }
        }
//        else {
//            NSString *filePath = [NSString stringWithFormat:@"%@/%@", binderFolderPath, fileOrFolderName];
//            XCSourceFile *file = [project fileWithName:filePath];
//            XCGroup *groupForFile = [project groupWithPathFromRoot:groupPath];
//            [groupForFile removeMemberWithKey:file.key];
//        }
    }
}

- (void)removeBinderFilesAndReferencesWithBinderPath:(NSString *)path forProject:(XCProject *)project andProjectPath:(NSString *)projectPath andGroup:(XCGroup *)group {
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:Nil];
    for (NSString *fileOrFolderName in dirs) {
        NSLog(@"Name: %@", fileOrFolderName);
        
        // Check if file or folder is found in directory
        NSRange dotRange = [fileOrFolderName rangeOfString:@"."];
        if (dotRange.location != NSNotFound) {
            // File
            NSString *filePath = [NSString stringWithFormat:@"%@%@/%@", projectPath, group.pathRelativeToProjectRoot, fileOrFolderName];
            XCSourceFile *file = [project fileWithName:filePath];
            
            [group removeMemberWithKey:file.key];
            for (XCTarget *target in [project targets]) {
                [target removeMemberWithKey:file.key];
            }
        } else {
            // Group
            // Get group for current folder and call function recursively
            NSString *groupPath = [NSString stringWithFormat:@"%@/%@", group.pathRelativeToProjectRoot, fileOrFolderName];
            XCGroup* nextGroup = [project groupWithPathFromRoot:groupPath];
            NSString *binderNextFolderPath = [NSString stringWithFormat:@"%@%@", projectPath, nextGroup.pathRelativeToProjectRoot];
            [self removeBinderFilesAndReferencesWithBinderPath:binderNextFolderPath forProject:project andProjectPath:projectPath andGroup:nextGroup];
        }
    }
}

- (void)cleanProjectWithName:(NSString *)projectName {
    NSString *script = [NSString stringWithFormat:@"tell application \"Xcode\"\nactivate\ntell project \"%@\"\ntell application \"System Events\"\nkey code 40 using {command down, shift down, option down}\nend tell\nend tell\nend tell", projectName];
    NSAppleScript *cleanProjectScript = [[NSAppleScript alloc] initWithSource:script];
    
    [cleanProjectScript executeAndReturnError:Nil];
}

@end
