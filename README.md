# StockPile

## Requirements

 - You need cocoapods installed on you mac.
  

### CocoaPods

Install pods
[http://cocoapods.org/](http://cocoapods.org/)

## Adding the pod to your project pod file

	pod 'StockPile', '~> 0.0'
	
## Library Usage	

This library provides LRU based caching. The library follows three types of caching strategies

1. In Memory - All data are kept in memory and will be lost when application closes or crashes.
2. Mirrored Cached - Data will be primarily kept in memory and can also be copied into database or disk.
3. Fallback - Data will be primarily kept in memory, however all evicted nodes (i.e. least recently used nodes) will be 
stored in the next caching strategy in list (i.e. can be disk or database).

In memory cache strategy should be used when it is not important to save data during crashes or when application is closed etc.

Mirrored cache strategy should be used when it is of absolute importance that cached data must not be lost

Fallback cache strategy should be used when it is okay to lose data on crashes etc. The idea here is to keep the data
at a place where it can be retrieved fastest. Retrieval from memory is O(1) followed by database and disk retrieval, 
in that order.

The libray can be extended in two ways

1. Algorithm extension

To create a new algorithm extend BaseCache and implement the following functions
      
      - (BOOL) cacheNode: (Node*) node;
      - (Node*) getNodeForKey:(id<NSCopying, NSMutableCopying, NSSecureCoding>) key;
      - (void) clearCache;
      
Do not extend any other method unless you are pretty sure of what you are doing.

2. Strategy extension

To have your own strategy, you need to have your own builder class. For details, look into the code of ```InMemoryDiskCacheBuilder``` 


The code below demonstrate of the use of StockPile (using inMemory and diskCopy strategy)

      //interface for DataSource
      @interface DBCacheDataSourceImpl : NSObject<DiskCacheDataSource>

        @property (nonatomic) NSInteger pmaximumElementInMemory;
        @property (nonatomic) NSInteger pmaximumMemoryAllocated;
        @property (nonatomic, copy) NSString* ppathForDiskCaching;

      @end

      @implementation DBCacheDataSourceImpl


        - (NSInteger) maximumElementInMemory;{
            return self.pmaximumElementInMemory;
        }
        
        - (NSInteger) maximumMemoryAllocated;{
            return self.pmaximumMemoryAllocated;
        }
        
        
        - (NSString *)pathForDiskCaching{
            return self.ppathForDiskCaching;
        }
      @end

      //setting correct values in data source
      DBCacheDataSourceImpl *dataSource = [[DBCacheDataSourceImpl alloc] init];
      dataSource.pmaximumElementInMemory = 20;
      dataSource.pmaximumMemoryAllocated = 2;
      dataSource.ppathForDiskCaching = [self applicationDocumentsDirectory];
      
      //initialising CachingManager
      id <CacheProtocol> cachingManager = [StockPile getInMemoryDiskCopyCacheUsingData:dataSource];
      
      //using cachingManager to cache a string value
      [cachingManager cacheValue:@"value" forKey:@"key"];
      
      //using cachingManager to get a cached value
      Value* data = [_cachingManager getValueForKey:@"key"];

## Contributing

We'll love contributions, please report bugs in the issue tracker, create pull request (on branch `develop`) and suggest new great features (also in the issue tracker).

## License & Credits

StockPile available under the [MIT license](LICENSE), so feel free to use it in commercial and non-commercial projects.

## Author

Mudit Krishna Mathur muditkmathur@gmail.com

Prabodh Prakash prabodh.prakash@gmail.com

