//
//  BinderPlugin+AddBinder.m
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/18/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

#import "BinderPlugin+AddBinder.h"
#import "XCFrameworkDefinition.h"

@implementation BinderPlugin (AddBinder)

// Menu item actions
- (void)addBinderReference {
    // Get Project path
    NSString *projectPath = [[[self currentProjectURL] description]substringFromIndex:7];
    NSArray *urlParts = [projectPath componentsSeparatedByString:@"/"];
    NSString *projectName = [urlParts objectAtIndex:[urlParts count] - 2];
    projectPath = [projectPath stringByAppendingString:[NSString stringWithFormat:@"%@/", projectName]];
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 600, 21)];
    [textField setPlaceholderString:@"Binder Base URL (https://sample.com/ProjectName/Binder/Binder/IOS)"];
    
    NSString *binderEndpointURL = binderEndpointURLs[projectPath];
    if (binderEndpointURL != nil) {
        [textField setStringValue:binderEndpointURL];
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAccessoryView:textField];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setIcon:NULL];
    [alert setMessageText:@"Add Binder Reference"];
    [alert addButtonWithTitle:@"Add Binder"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSString *binderEndpointURL = [textField stringValue];
            binderEndpointURL = [binderEndpointURL stringByReplacingOccurrencesOfString:@"/Binder/Binder/IOS" withString:@""];
            if ([binderEndpointURL hasSuffix:@"/"]) {
                binderEndpointURL = [binderEndpointURL substringToIndex:[binderEndpointURL length] - 1];
            }
            [binderEndpointURLs setObject:binderEndpointURL forKey:projectPath];
            [self addBinderToProject:projectPath];
        } else {
            // Cancel
            NSLog(@"Cancel Add Binder Reference");
        }
    }];
}

- (void)addBinderReferenceWithExistingPath:(NSString *)path {
    // Get Project path
    NSString *projectPath = [[[self currentProjectURL] description]substringFromIndex:7];
    NSArray *urlParts = [projectPath componentsSeparatedByString:@"/"];
    NSString *projectName = [urlParts objectAtIndex:[urlParts count] - 2];
    projectPath = [projectPath stringByAppendingString:[NSString stringWithFormat:@"%@/", projectName]];
    
    [self addBinderToProject:projectPath];
}

- (void)addBinderToProject:(NSString *)projectPath {
    NSString *binderEndpointURL = binderEndpointURLs[projectPath];
    if (binderEndpointURL != nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(0,0);
        dispatch_async(queue, ^{
            
            NSLog(@"Beginning downloading Binder");
            NSString *stringURL = [NSString stringWithFormat:@"%@%@", binderEndpointURL, @"/api/Binder/distribution?platform=swift"];
            NSURL  *url = [NSURL URLWithString:stringURL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            
            //Find a cache directory. You could consider using documenets dir instead (depends on the data you are fetching)
            NSLog(@"Got Binder data");
            
            //Save the data
            NSLog(@"Saving Binder data");
            NSString *dataPath = [projectPath stringByAppendingPathComponent:@"Binder.zip"];
            dataPath = [dataPath stringByStandardizingPath];
            [urlData writeToFile:dataPath atomically:YES];
            
            //Unzip binder
            NSLog(@"Unzipping Binder");
            NSString *binderZipPath = dataPath;
            NSString *destinationPath = [projectPath stringByAppendingPathComponent:@"Binder"];
            [SSZipArchive unzipFileAtPath:binderZipPath toDestination: destinationPath];
            
            //Handle adding of all files to project
            [self addAllFileReferencesAndTargets:projectPath];
            
            //Delete Binder zip
            NSLog(@"Deleting Binder zip");
            [[NSFileManager defaultManager] removeItemAtPath:binderZipPath error:NULL];
            
            NSLog(@"Successfully added Binder");
        });
    } else {
        NSLog(@"Could not add binder; no project path.");
    }
}

- (void)addAllFileReferencesAndTargets:(NSString *)projectPath {
    // All needed paths
    NSArray *urlParts = [projectPath componentsSeparatedByString:@"/"];
    NSString *projectName = [urlParts objectAtIndex:[urlParts count] - 2];
    NSString *xcodeProjPath = [[[self currentProjectURL] description]substringFromIndex:7];
    NSString *xcodeprojUrl = [NSString stringWithFormat:@"%@%@.xcodeproj", xcodeProjPath, projectName];
    NSString *binderFolderPath = [NSString stringWithFormat:@"%@%@", projectPath, @"Binder"];
    
    // Add group for binder files to project
    XCProject* project = [[XCProject alloc] initWithFilePath:xcodeprojUrl];
    XCGroup* group = [project groupWithPathFromRoot:projectName];
    [group addGroupWithPath:@"Binder"];
    
    // Get binder group
    NSString *binderGroupPathFromRoot = [NSString stringWithFormat:@"%@/Binder", projectName];
    XCGroup* binderGroup = [project groupWithPathFromRoot:binderGroupPathFromRoot];
    
    // Add all files to binder group and add them to project target
    NSString *projectBasePath = [[[self currentProjectURL] description]substringFromIndex:7];
    [self addFileReferenceAndTargetForFolderAtPath:binderFolderPath forProject:project andProjectPath:projectBasePath andGroup:binderGroup];
}

// Recursive function to add binder files and references to the project
- (void)addFileReferenceAndTargetForFolderAtPath:(NSString *)path forProject:(XCProject *)project andProjectPath:(NSString *)projectPath andGroup:(XCGroup *)group {
    NSLog(@"Path: %@", path);
    
    NSArray *urlParts = [projectPath componentsSeparatedByString:@"/"];
    NSString *projectName = [urlParts objectAtIndex:[urlParts count] - 2];
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:Nil];
    for (NSString *fileOrFolderName in dirs) {
        NSLog(@"Name: %@", fileOrFolderName);
        
        // Check if file or folder is found in directory
        NSRange dotRange = [fileOrFolderName rangeOfString:@"."];
        if (dotRange.location != NSNotFound) {
            // Check what file it is
            NSRange dsStoreRange = [fileOrFolderName rangeOfString:@".DS_Store"];
            if (dsStoreRange.location != NSNotFound) {
                // Ignore .DS_Store file
                continue;
            } else {
                // Check what type of file it is
                NSRange swiftRange = [fileOrFolderName rangeOfString:@".swift"];
                NSRange hRange = [fileOrFolderName rangeOfString:@".h"];
                NSRange mRange = [fileOrFolderName rangeOfString:@".m"];
                XcodeSourceFileType fileType = FileTypeNil;
                BOOL needsToBeAddedToTarget = false;
                
                if (swiftRange.location != NSNotFound) {
                    // Swift file found
                    fileType = SourceCodeSwift;
                    needsToBeAddedToTarget = true;
                } else if (hRange.location != NSNotFound) {
                    // .h file found
                    fileType = SourceCodeObjC;
                } else if (mRange.location != NSNotFound) {
                    // .m file found
                    fileType = SourceCodeObjC;
                    needsToBeAddedToTarget = true;
                }
                
                if (fileType != FileTypeNil) {
                    // File found, add file reference to group
                    [self addFileReferenceToGroup:group withProject:project projectPath:projectPath projectName:projectName fileName:fileOrFolderName fileType:fileType andNeedsToBeAddedToTarget:needsToBeAddedToTarget];
                }
            }
        } else {
            if ([fileOrFolderName isEqualToString:@"Alamofire"]) {
                // Add Alamofire.xcodeproj
                NSString *alamofireXcodeProjPathEndComponent = [NSString stringWithFormat:@"%@/Binder/Alamofire/Alamofire.xcodeproj", projectName];
                NSString *alamofireXcodeProjPath = [projectPath stringByAppendingPathComponent:alamofireXcodeProjPathEndComponent];
                [group addFileReference:alamofireXcodeProjPath withType:XcodeProject];
            } else {
                // Continue adding files in subfolder
                // Folder found, recurse on folder path
                [group addGroupWithPath:fileOrFolderName];
                [project save];
                
                // Get group for current folder and call function recursively
                NSString *groupPath = [NSString stringWithFormat:@"%@/%@", group.pathRelativeToProjectRoot, fileOrFolderName];
                XCGroup* nextGroup = [project groupWithPathFromRoot:groupPath];
                NSString *binderNextFolderPath = [NSString stringWithFormat:@"%@%@", projectPath, nextGroup.pathRelativeToProjectRoot];
                [self addFileReferenceAndTargetForFolderAtPath:binderNextFolderPath forProject:project andProjectPath:projectPath andGroup:nextGroup];
            }
        }
    }
}

- (void)addFileReferenceToGroup:(XCGroup *)group withProject:(XCProject *)project projectPath:(NSString *)projectPath projectName:(NSString *)projectName fileName:(NSString *)fileName fileType:(XcodeSourceFileType)fileType andNeedsToBeAddedToTarget:(BOOL)needsToBeAddedToTarget {
    NSString *filePath = [NSString stringWithFormat:@"%@%@/%@", projectPath, group.pathRelativeToProjectRoot, fileName];
    [group addFileReference:filePath withType:fileType];
    
    if (needsToBeAddedToTarget) {
        // Add target for file to project
        [self addTargetForFileWithProject:project projectName:projectName filePath:filePath];
    }
}

- (void)addTargetForFileWithProject:(XCProject *)project projectName:(NSString *)projectName filePath:(NSString *)filePath {
    XCSourceFile* sourceFile = [project fileWithName:filePath];
    XCTarget* projectTarget = [project targetWithName:projectName];
    [projectTarget addMember:sourceFile];
    [project save];
}


@end
