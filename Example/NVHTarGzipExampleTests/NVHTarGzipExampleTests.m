//
//  NVHTarGzipExampleTests.m
//  NVHTarGzipExampleTests
//
//  Created by Alexander Kormanovsky on 24.01.2025.
//  Copyright © 2025 Niels van Hoorn. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NVHTarGzip.h"

@interface NVHTarGzipExampleTests : XCTestCase

@end

@implementation NVHTarGzipExampleTests

/**
 Untar files which names contain non-ASCII characters (Russian)
 */
- (void)testUntarFileNamesEncoding {
    NSString *sourcePath = [self demoSourceTarFilePath];
    NSString *destinationPath = [self demoDestinationFolderPath];
    NSLog(@"Extracting from '%@' to '%@'", sourcePath, destinationPath);
    NSError *error;
    
    [[NVHTarGzip sharedInstance] unTarFileAtPath:[self demoSourceTarFilePath]
                                          toPath:destinationPath
                                           error:&error];
    
    if (error) {
        XCTFail(@"%@", error);
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:destinationPath];
    NSString *file;
    
    // find this files skipping possible name metadata files coming from other archivers
    // https://www.gnu.org/software/tar/manual/html_section/Formats.html
    
    NSArray *referenceFileNames = @[
        @"тест test 1.txt",
        @"тест test 2.txt",
        @"тест test 3.txt"
    ];
    
    NSInteger referenceFilesCount = referenceFileNames.count;
    NSInteger foundFilesCount = 0;
    NSInteger fileIndex = 0;
    
    NSLog(@"Extracted files:");
    
    while ((file = [dirEnum nextObject])) {
        NSString *fileName = file.lastPathComponent;
        NSLog(@"File #%ld: '%@'", ++fileIndex, fileName);
        
        for (NSString *referenceFileName in referenceFileNames) {
            if ([fileName isEqualToString:referenceFileName]) {
                ++foundFilesCount;
            }
        }
        
    }
    
    XCTAssert(referenceFilesCount == foundFilesCount,
              @"Files with proper names not found (reference %ld vs found %ld)",
              referenceFilesCount, foundFilesCount);
}

- (NSString *)demoSourceTarFilePath {
    return [[NSBundle mainBundle] pathForResource:@"nonascii_file_names" ofType:@"tar"];
}

- (NSString *)demoDestinationFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = paths[0];
    NSString* destinationPath = [documentPath stringByAppendingPathComponent:@"20news-19997"];
    return destinationPath;
}

@end
