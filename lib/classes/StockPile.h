
//
//  StockPile.h
//  Pods
//
//  Created by Mudit Krishna Mathur on 11/09/15.
//
//

#import <Foundation/Foundation.h>
#import "CacheBuilders.h"

/*!
    @brief This class is used to get specific implementations of caching algorithms.
 
    @discussion It has all class level methods that are used to return specific implementations of caching algorithms. It supports in memory based cache, in memory + disk based cache, im memory + db based cache.
 */
@interface StockPile : NSObject

/*!
    It returns new instance of a class implemeting CacheProtocol.
 
    This method is used to return instance of class just with <b>in
    memory caching</b>.
 
    @code
    [StockPile getInMemoryCacheUsingData:id<CacheDataSource> dataSource];
    @endcode
 
    @param dataSource Instance of a class implementing CacheDataSource
 
    @return new instance of class implementing CacheProtocol
*/
+ (id<CacheProtocol>) getInMemoryCacheUsingData:(id<CacheDataSource>) dataSource;

/*!
    It returns new instance of a class implemeting CacheProtocol.
 
    This method is used to return instance of class with <b>in
    memory and disk based caching</b>. This means that the elements that are being cached will also be 
    saved in disk. This method ensures that the cached are safe even is case of crash etc. For better performance
    of retrival and saving elements, use database.
 
    @code
    [StockPile getInMemoryCacheUsingData:id<DiskCacheDataSource> dataSource];
    @endcode
 
    @param dataSource Instance of a class implementing DiskCacheDataSource
 
    @return new instance of class implementing CacheProtocol
 */
+ (id<CacheProtocol>) getInMemoryDiskCopyCacheUsingData:(id<DiskCacheDataSource>) dataSource;

/*!
    @brief It returns new instance of a class implemeting CacheProtocol.
 
    @discussion This method is used to return instance of class with <b>in
    memory and disk based caching</b>. This means that the elements that are being cached will also be
    saved in disk. This method ensures that the cached are safe even is case of crash etc. For better performance
    of retrival and saving elements, use database.
 
    @code
    [StockPile getInMemoryCacheUsingData:id<DBCacheDataSource> dataSource];
    @endcode
 
    @param dataSource Instance of a class implementing DBCacheDataSource
 
    @return new instance of class implementing CacheProtocol
 */
+ (id<CacheProtocol>) getInMemoryDBCopyCacheUsingData:(id<DBCacheDataSource>) dataSource;

/*!
 @brief It returns new instance of a class implemeting CacheProtocol.
 
 @discussion This method is used to return instance of class with <b>in
 memory and database overflow based caching</b>. This means that the elements that are being evicted from memory will be
 saved in database.
 
 @code
 [StockPile getInMemoryDBOverFlowCacheUsingData<DBCacheDataSource> dataSource];
 @endcode
 
 @param dataSource Instance of a class implementing DBCacheDataSource
 
 @return new instance of class implementing CacheProtocol
 */
+ (id<CacheProtocol>) getInMemoryDBOverflowCacheUsingData:(id<DBCacheDataSource>) dataSource;

@end
