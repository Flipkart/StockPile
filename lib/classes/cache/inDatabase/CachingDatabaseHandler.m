//
//  CachingDatabaseHandler.m
//  Pods
//
//  Created by Prabodh Prakash on 02/09/15.
//
//

#import "CachingDatabaseHandler.h"
#import "CoreDataLite.h"
#import "CacheTable.h"

@interface CachingDatabaseHandler()

@property (nonatomic, strong) CoreDatabaseInterface* coreDatabaseInterface;

@end

@implementation CachingDatabaseHandler

@synthesize dbName = _dbName;

- (CoreDatabaseInterface*) coreDatabaseInterface
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL* documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL* storeURL = [documentsURL URLByAppendingPathComponent:self.dbName];
        [[CoreDataManager sharedManager] setupCoreDataWithKey:self.dbName storeURL:storeURL objectModelIdentifier:@"CachingDatabase"];
        
        _coreDatabaseInterface = [[CoreDataManager sharedManager] getCoreDataInterfaceForKey:self.dbName];
    });
    
    return _coreDatabaseInterface;
}

- (NSArray*) cacheNode: (Node*) node error:(NSError **)outError
{
    NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
    
    [_managedObjectContext performBlockAndWait:^{
        CacheTable* cacheTableEntity = [self getDBRowForKey:node.key inContext:_managedObjectContext];
        
        if (cacheTableEntity == nil)
        {
            cacheTableEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CacheTable" inManagedObjectContext:_managedObjectContext];
        }
        
        cacheTableEntity.key = node.key;
        
        //cacheTableEntity.ttlInterval = node.data.ttlInterval;
        cacheTableEntity.ttlDate = node.data.ttlDate;
        cacheTableEntity.value = [NSKeyedArchiver archivedDataWithRootObject:node.data.value];
        
        [_managedObjectContext save:outError];
    }];
    
    return nil;
}

- (Node*) getNodeForKey:(NSString*) key
{
    __block Node* node = nil;
    
    NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
    
    [_managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheTable"
                                                  inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
        [fetchRequest setPredicate:predicate];
        
        NSError* error;
        
        NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (!error && fetchedObjects != nil && fetchedObjects.count == 1)
        {
            CacheTable* cachedValue = (CacheTable*)[fetchedObjects objectAtIndex:0];
            Value* value = [[Value alloc] init];
            
            value.key = key;
            value.value = [NSKeyedUnarchiver unarchiveObjectWithData:cachedValue.value];
            value.ttlDate = cachedValue.ttlDate;
            
            node = [[Node alloc] initWithKey:key value:value];
        }
    }];
    
    return node;
}

- (CacheTable*) getDBRowForKey:(NSString*) key inContext: (NSManagedObjectContext*) _managedObjectContext
{
    CacheTable* cachedValue = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheTable"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (!error && fetchedObjects != nil && fetchedObjects.count == 1)
    {
        cachedValue = (CacheTable*)[fetchedObjects objectAtIndex:0];
    }
    
    return cachedValue;
}

- (void) clearCache
{
    
}

@end