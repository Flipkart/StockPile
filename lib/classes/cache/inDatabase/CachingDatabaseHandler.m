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
#import "CacheSize.h"

#define DELETE_BLOCK 5

@interface CachingDatabaseHandler()

@property (nonatomic, strong) CoreDatabaseInterface* coreDatabaseInterface;

@end

@implementation CachingDatabaseHandler

@synthesize dbName = _dbName;

- (CoreDatabaseInterface*) coreDatabaseInterface
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL* documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL* storeURL = [documentsURL URLByAppendingPathComponent:self.dbName];
        [[CoreDataManager sharedManager] setupCoreDataWithKey:self.dbName storeURL:storeURL  objectModelIdentifier:@"CachingDatabase"];
        
        _coreDatabaseInterface = [[CoreDataManager sharedManager] getCoreDataInterfaceForKey:self.dbName];
    });
    
    return _coreDatabaseInterface;
}

- (BOOL) cacheNode: (Node*) node
{
    __block BOOL isCachingSuccessful = true;
    
    float memoryNeeded = node.sizeOfData;

    while (([self getCacheSize].floatValue + memoryNeeded ) > _maxMemoryAllocated) {
        [self removeEndNode];
    }
    
    dispatch_sync([[self coreDatabaseInterface] getSerialQueue], ^{
        
        NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
        CacheTable* cacheTableEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CacheTable" inManagedObjectContext:_managedObjectContext];
        
        cacheTableEntity.key = node.key;
        //cacheTableEntity.ttlInterval = node.data.ttlInterval;
        cacheTableEntity.ttlDate = node.data.ttlDate;
        cacheTableEntity.value = [NSKeyedArchiver archivedDataWithRootObject:node.data.value];
        
        NSError* error;
        
        if (![_managedObjectContext save:&error])
        {
            isCachingSuccessful = false;
        }
        else
        {
            [self increaseCacheSizeBy:[NSNumber numberWithFloat:node.sizeOfData]];
        }
    });
    
    return isCachingSuccessful;
}

- (Node*) getNodeForKey:(NSString*) key
{
    __block Node* node = nil;
    dispatch_sync([[self coreDatabaseInterface] getSerialQueue], ^{
        
        NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
        
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
    });
    
    return node;
}

-(BOOL) removeEndNode
{
    BOOL isDeleteSuccessful = true;
    
    NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheTable"
                                              inManagedObjectContext:_managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    id sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ttlDate" ascending:YES];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [fetchRequest setFetchLimit:DELETE_BLOCK];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSNumber *reducedSize = 0;
    
    if (error == nil)
    {
        for(CacheTable* fetchObject in fetchedObjects)
        {
            Value* value = [[Value alloc] init];
            
            value.key = fetchObject.key;
            value.value = [NSKeyedUnarchiver unarchiveObjectWithData:fetchObject.value];
            value.ttlDate = fetchObject.ttlDate;
            
            Node * node = [[Node alloc] initWithKey:fetchObject.key value:value];

            reducedSize = [NSNumber numberWithFloat:([reducedSize floatValue] + node.sizeOfData)];
            [_managedObjectContext deleteObject:fetchObject];
        }
        if ([_managedObjectContext save:&error])
        {
            [self decreaseCacheSizeBy:reducedSize];
        }
        else
        {
            isDeleteSuccessful = false;
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    else
    {
        isDeleteSuccessful = false;
    }
    
    return isDeleteSuccessful;
}

- (void) clearCache
{
    
}

-(NSNumber *)getCacheSize
{
    NSNumber * cacheSize = 0;
    
    NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheSize"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && fetchedObjects != nil && fetchedObjects.count == 1)
    {
        CacheSize * cacheObject = [fetchedObjects objectAtIndex:0];
        cacheSize = cacheObject.totalDBSize;
    }
    
    return cacheSize;
}

- (BOOL) increaseCacheSizeBy:(NSNumber *) size
{
     BOOL isCacheSizeSuccessful = true;
    
    NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheSize"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && fetchedObjects != nil && fetchedObjects.count == 1)
    {
        CacheSize * cacheObject = [fetchedObjects objectAtIndex:0];
        cacheObject.totalDBSize = [NSNumber numberWithFloat:([size floatValue] + [cacheObject.totalDBSize floatValue])];
    }
    else if (!error && fetchedObjects == nil)
    {
        CacheSize* cacheSizeEntity = [NSEntityDescription insertNewObjectForEntityForName:@"CacheSize"
                                                                   inManagedObjectContext:_managedObjectContext];
        
        cacheSizeEntity.totalDBSize = size;
    }
    if (![_managedObjectContext save:&error])
    {
        isCacheSizeSuccessful = false;
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return isCacheSizeSuccessful;
}

- (BOOL) decreaseCacheSizeBy:(NSNumber *) size
{
    BOOL isCacheSizeSuccessful = true;
    
    NSManagedObjectContext* _managedObjectContext = [[self coreDatabaseInterface] getPrivateQueueManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheSize"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && fetchedObjects != nil && fetchedObjects.count == 1)
    {
        CacheSize * cacheObject = [fetchedObjects objectAtIndex:0];
        
        cacheObject.totalDBSize = [NSNumber numberWithFloat:( [cacheObject.totalDBSize floatValue] - [size floatValue])];
        if (cacheObject.totalDBSize.intValue < 0) {
            cacheObject.totalDBSize = [NSNumber numberWithInt:0];
        }
    }
    
    if (![_managedObjectContext save:&error])
    {
        isCacheSizeSuccessful = false;
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return isCacheSizeSuccessful;
}

@end
