//
//  BinderPlugin+UpdateBinder.m
//  BinderPlugin
//
//  Created by Niklas Fahl on 2/18/16.
//  Copyright © 2016 Niklas Fahl. All rights reserved.
//

#import "BinderPlugin+UpdateBinder.h"
#import "BinderPlugin+RemoveBinder.h"
#import "BinderPlugin+AddBinder.h"

@implementation BinderPlugin (UpdateBinder)

// Menu item actions
- (void)updateBinderReference {
    NSString *projectPath = [[[self currentProjectURL] description]substringFromIndex:7];
    NSArray *urlParts = [projectPath componentsSeparatedByString:@"/"];
    NSString *projectName = [urlParts objectAtIndex:[urlParts count] - 2];
    projectPath = [projectPath stringByAppendingString:[NSString stringWithFormat:@"%@/", projectName]];
    
    [self presentUpdateBinderAlertWithProjectPath:projectPath];
}

- (void)presentUpdateBinderAlertWithProjectPath:(NSString *)projectPath {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 21)];
    [textField setPlaceholderString:@"Binder Base URL (https://sample.com/ProjectName)"];
    NSString *binderEndpointURL = binderEndpointURLs[projectPath];
    if (binderEndpointURL != nil) {
        [textField setStringValue:binderEndpointURL];
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAccessoryView:textField];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setIcon:NULL];
    [alert setMessageText:@"Update Binder Reference"];
    [alert addButtonWithTitle:@"Update Binder"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [binderEndpointURLs setObject:[textField stringValue] forKey:projectPath];
            // Remove Binder
            [self removeBinderFilesAndReferences];
            
            // Redownload and add Binder
            [self addBinderReferenceWithExistingPath:[textField stringValue]];
        } else {
            // Cancel
            NSLog(@"Cancel Update Binder Reference");
        }
    }];
}

@end
