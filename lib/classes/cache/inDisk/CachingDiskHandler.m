//
//  CachingDiskHandler.m
//  Pods
//
//  Created by Prabodh Prakash on 04/09/15.
//
//

#import "CachingDiskHandler.h"
#import "CachingException.h"
#import "NSFileManager+AttributesExtension.h"

@implementation CachingDiskHandler

@synthesize filePath = _filePath;

- (NSArray*) cacheNode: (Node*) node error:(NSError **)outError
{
    NSString *filePath = [self.filePath stringByAppendingPathComponent:node.key];
    
    NSData* fileData = [NSKeyedArchiver archivedDataWithRootObject:node.data];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filePath])
    {
        [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
        
        NSData* ttlDate = [NSKeyedArchiver archivedDataWithRootObject:node.data.ttlDate];
        
        [fileManager setData:ttlDate forExtendedAttribute:@"ttlDate" ofItemAtPath:filePath error:outError];
    }
    else
    {
        
        [fileManager removeItemAtPath:filePath error:outError];
        
        if (!*outError)
        {
            [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
        }
    }
    
    return nil;
}

- (Node*) getNodeForKey:(NSString*) key
{
    NSString *filePath = [self.filePath stringByAppendingPathComponent:key];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSError* error;
    NSData* ttlDateArchivedData = [fileManager dataForExtendedAttribute:@"ttlDate" ofItemAtPath:filePath error:&error];
    
    NSDate* ttlDate = (NSDate*)[NSKeyedUnarchiver unarchiveObjectWithData:ttlDateArchivedData];
    
    Value* value = nil;
    if ([ttlDate compare:[NSDate date]] != NSOrderedDescending)
    {
        NSData* fileData = [fileManager contentsAtPath:filePath];
        value = (Value*)[NSKeyedUnarchiver unarchiveObjectWithData:fileData];
    }
    
    Node* node = [[Node alloc] initWithKey:key value:value];
    return node;
}

- (void) clearCache
{
    #warning complete the code
}

@end
