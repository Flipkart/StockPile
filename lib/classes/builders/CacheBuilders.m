//
//  CacheFactory.m
//  Pods
//
//  Created by Prabodh Prakash on 04/09/15.
//
//

#import "CacheBuilders.h"
#import "NSObject+CacheBuilder.h"
#import "LRUCache.h"
#import "CachingException.h"
#import "CachingManager.h"
#import "CachingDataBaseHandler.h"

#define DEFAULT_MAX_ELEMENT_IN_MEMORY 100
#define DEFAULT_MAX_MEMORY 10


#pragma mark in-memory cache

@implementation CacheManagerBuilder

@synthesize cacheDataSource = _cacheDataSource;

- (instancetype)initWithCacheDataSource:(id<CacheDataSource>) cacheDataSource
{
    if (self)
    {
        self.cacheDataSource = cacheDataSource;
    }
    
    return self;
}

- (BuilderBlock) getBuilderBlock:(id<CacheDataSource>) cacheDataSource
{
    @throw [[CachingException alloc] initWithReason:@"Inherit and implement this function"];
}

- (id<CacheProtocol>)build
{
    CachingManager* cachingManager = [[CachingManager alloc] initUsingBlock:[self getBuilderBlock:self.cacheDataSource]];
    return cachingManager;
}

@end

#pragma mark Builder implementations

@implementation InMemoryCacheBuilder

- (BuilderBlock) getBuilderBlock:(id<CacheDataSource>) cacheDataSource
{
    if (![cacheDataSource conformsToProtocol:@protocol(CacheDataSource)])
    {
        @throw [[CachingException alloc] initWithReason:@"Datasource must implement CacheDataSource for memory based caching"];
    }
    
    return ^(CachingManager* cachingManager)
    {
        LRUCache* inMemoryCache = [[LRUCache alloc] initUsingBlock:^(LRUCache* cache)
                                   {
                                       cache.maxElementsInMemory = [cacheDataSource maximumElementInMemory];
                                       cache.maxMemoryAllocated = [cacheDataSource maximumMemoryAllocated];
                                   }];
        cachingManager.firstResponderCacheAlgo = inMemoryCache;
    };
}

@end

@implementation InMemoryDiskCopyCacheBuilder

- (BuilderBlock) getBuilderBlock:(id<CacheDataSource>) cacheDataSource
{
    
    if (![cacheDataSource conformsToProtocol:@protocol(DiskCacheDataSource)])
    {
        @throw [[CachingException alloc] initWithReason:@"Datasource must implement DiskCacheDataSource for disk based caching"];
    }
    
    id<DiskCacheDataSource> cacheDataSourceBlock = (id<DiskCacheDataSource>)cacheDataSource;
    return ^(CachingManager* cachingManager)
    {
        
        // 1. create LRU memory cache
        // 2. create disk based lru cache
        // 3. set disk cache as the copy of memory cache
        // 4. set the memory cache as the first responder
        
        LRUCache* inMemoryCache = [[LRUCache alloc] initUsingBlock:^(LRUCache* cache)
                                   {
                                       cache.maxElementsInMemory = [cacheDataSourceBlock maximumElementInMemory];
                                       cache.maxMemoryAllocated = [cacheDataSourceBlock maximumMemoryAllocated];
                                   }];
        
        
        CachingDiskHandler* diskCache = [[CachingDiskHandler alloc] initUsingBlock:^(CachingDiskHandler* cache)
                                         {
                                             cache.filePath = [cacheDataSourceBlock pathForDiskCaching];
                                             cache.maxElementsInMemory = [cacheDataSourceBlock maximumElementInMemory];
                                             cache.maxMemoryAllocated = [cacheDataSourceBlock maximumMemoryAllocated];

                                         }];
        
        inMemoryCache.mirroredCache = diskCache;
        cachingManager.firstResponderCacheAlgo = inMemoryCache;
    };
}

@end

@implementation InMemoryDbCopyCacheBuilder

- (BuilderBlock) getBuilderBlock:(id<CacheDataSource>) cacheDataSource
{
    
    if (![cacheDataSource conformsToProtocol:@protocol(DBCacheDataSource)])
    {
        @throw [[CachingException alloc] initWithReason:@"Datasource must implement DBCacheDataSource for db based caching"];
    }
    
    id<DBCacheDataSource> cacheDataSourceBlock = (id<DBCacheDataSource>)cacheDataSource;
    return ^(CachingManager* cachingManager)
    {
        
        // 1. create LRU memory cache
        // 2. create disk based lru cache
        // 3. set db cache as the copy of memory cache
        // 4. set the memory cache as the first responder
        
        LRUCache* inMemoryCache = [[LRUCache alloc] initUsingBlock:^(LRUCache* cache)
                                   {
                                       cache.maxElementsInMemory = [cacheDataSourceBlock maximumElementInMemory];
                                       cache.maxMemoryAllocated = [cacheDataSourceBlock maximumMemoryAllocated];
                                   }];
        
        
        CachingDatabaseHandler* dbCache = [[CachingDatabaseHandler alloc] initUsingBlock:^(CachingDatabaseHandler* cache)
                                         {
                                             cache.dbName = [cacheDataSourceBlock getDBName];
                                             cache.maxElementsInMemory = [cacheDataSourceBlock maximumElementInMemory];
                                             cache.maxMemoryAllocated = [cacheDataSourceBlock maximumMemoryAllocated];
                                         }];
        
        inMemoryCache.mirroredCache = dbCache;
        cachingManager.firstResponderCacheAlgo = inMemoryCache;
    };
}

@end