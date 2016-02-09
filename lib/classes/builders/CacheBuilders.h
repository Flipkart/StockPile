//
//  CacheFactory.h
//  Pods
//
//  Created by Prabodh Prakash on 04/09/15.
//
//

#import <Foundation/Foundation.h>
#import "BaseCache.h"
#import "CachingDatabaseHandler.h"
#import "CachingDiskHandler.h"
#import "CachingManager.h"

#pragma mark BuilderDataSources
@protocol CacheDataSource <NSObject>

/*!
 @return the maximum number of elements allowed in memory.
 */
- (NSInteger) maximumElementInMemory;

/*!
 @return the maximum memory usage allowed.
 */
- (NSInteger) maximumMemoryAllocated;
@end

@protocol DiskCacheDataSource <CacheDataSource>

/*!
 @return the path for disk caching.
 */
- (NSString*) pathForDiskCaching;
@end

@protocol DBCacheDataSource <CacheDataSource>
/*!
 @return the database name.
 */
- (NSString*) getDBName;
@end

#pragma mark Builders

@interface CacheManagerBuilder: NSObject

typedef void (^BuilderBlock)(CachingManager *);

@property (nonatomic, strong) id <CacheDataSource> cacheDataSource;

/*!
 This method creates a new instance of CacheManagerBuilder using the cache data source.
 <b>This method should ideally not be overridden unless you know what you are doing</b>
 
 @param cacheDataSource instance of CacheDataSource
 
 @return New instance of CacheManagerBuilder
 */
- (instancetype)initWithCacheDataSource:(id<CacheDataSource>) cacheDataSource;

/*!
 This method creates and returns a new instance of class implementing CacheProtocol.
 
 <b>This method should ideally not be overridden unless you know what you are doing </b>
 
 @return new instance of class implementing CacheProtocol
 */
- (id<CacheProtocol>)build;

/**
 This function is responsible for creating BuilderBlock. 
 <b>It must be overriden by subclasses of CacheManagerBuilder. A CachingException is thrown is this method is called on CacheManagerBuilder</b>
 @param cacheDataSource instance of class implementing CacheDataSource
 
 @return BuilderBlock
 */
- (BuilderBlock) getBuilderBlock:(id<CacheDataSource>) cacheDataSource;

@end

@interface InMemoryCacheBuilder : CacheManagerBuilder
@end

@interface InMemoryDiskCopyCacheBuilder : InMemoryCacheBuilder
@end

@interface InMemoryDbCopyCacheBuilder : InMemoryCacheBuilder
@end

@interface InMemoryDbOverflowCacheBuilder : InMemoryCacheBuilder
@end


