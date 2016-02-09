//
//  ViewController.m
//  CachingTestProject
//
//  Created by Prabodh Prakash on 27/08/15.
//  Copyright (c) 2015 Flipkart. All rights reserved.
//

#import "ViewController.h"
#import <malloc/malloc.h>

@interface DBCacheDataSourceImpl : NSObject<DBCacheDataSource, DiskCacheDataSource>

@property (nonatomic) NSInteger pmaximumElementInMemory;
@property (nonatomic) NSInteger pmaximumMemoryAllocated;
@property (nonatomic, copy) NSString* pgetDBName;
@property (nonatomic, copy) NSString* ppathForDiskCaching;

@end

@implementation DBCacheDataSourceImpl


- (NSInteger) maximumElementInMemory;{
    return self.pmaximumElementInMemory;
}
- (NSInteger) maximumMemoryAllocated;{
    return self.pmaximumMemoryAllocated;
}
- (NSString*) getDBName;{
    return self.pgetDBName;
}
- (NSString *)pathForDiskCaching{
    return self.ppathForDiskCaching;
}

@end


@interface InMemoryCacheDataSourceImpl : NSObject<CacheDataSource>

@property (nonatomic) BOOL isForAutomatedTest;
@property (nonatomic) NSInteger pmaximumElementInMemory;
@property (nonatomic) NSInteger pmaximumMemoryAllocated;
@property (nonatomic, copy) NSString* pgetDBName;
@property (nonatomic, copy) NSString* ppathForDiskCaching;

@end

@implementation InMemoryCacheDataSourceImpl


- (NSInteger) maximumElementInMemory
{
    if (_isForAutomatedTest)
    {
        return 100000;
    }
    else
    {
        return _pmaximumElementInMemory;
    }
}
- (NSInteger) maximumMemoryAllocated
{
    if (_isForAutomatedTest)
    {
        return 250;
    }
    else
    {
        return _pmaximumMemoryAllocated;
    }
}

@end

@interface ViewController ()
{
    NSCache* nsCache;
    NSString* letters;
    CachingManager* automatedTestCachingManager;
    float totalTimeForNSCache;
    float totalTimeForStockPile;
    NSInteger countOfElementsToCache;
    
    CachingManager* cachingManager;
    
    dispatch_queue_t serialQueue;
}

- (IBAction)addToCacheClicked:(id)sender;
- (IBAction)getValueClicked:(id)sender;
- (IBAction)initCacheClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *cachedValue;

@property (weak, nonatomic) IBOutlet UILabel *nsCacheCachingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nsCacheAccessTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPileCachingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockPileAccessTimeLabel;

@property (weak, nonatomic) IBOutlet UITextField *countOfElements;
@property (weak, nonatomic) IBOutlet UITextField *memoryAllocated;
@property (weak, nonatomic) IBOutlet UITextField *valueToAdd;
@property (weak, nonatomic) IBOutlet UITextField *valueToGet;

@property (weak, nonatomic) IBOutlet UITextField *countOfElementsToRunTest;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setup];
}

- (void) setup
{
    NSMutableString* str = [NSMutableString new];
    
    for (int i = 0 ; i < 50; i++)
    {
        [str appendString:@"a"];
    }
    
    letters = [NSString stringWithString:str];
    
    nsCache = [NSCache new];
    nsCache.totalCostLimit = 250;
    
    InMemoryCacheDataSourceImpl *dataSource = [[InMemoryCacheDataSourceImpl alloc] init];
    dataSource.isForAutomatedTest = YES;
    automatedTestCachingManager = [StockPile getInMemoryCacheUsingData:dataSource];
    
    serialQueue = dispatch_queue_create("com.flipkart.caching", DISPATCH_QUEUE_SERIAL);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

- (IBAction)addToCacheClicked:(id)sender
{
    NSString* key = _valueToAdd.text;
    
    Value* value = [[Value alloc] init];
    value.value = key;
    
    [cachingManager cacheValue:value forKey:key];
}

- (IBAction)getValueClicked:(id)sender
{
    Value* data = [cachingManager getValueForKey:_valueToGet.text];
    
    _cachedValue.text = (NSString*)data.value;
}

- (IBAction)initCacheClicked:(id)sender
{
    DBCacheDataSourceImpl *dataSource = [[DBCacheDataSourceImpl alloc] init];
    dataSource.pmaximumElementInMemory = [_countOfElements.text integerValue];
    dataSource.pmaximumMemoryAllocated = [_memoryAllocated.text integerValue];
    dataSource.ppathForDiskCaching = [self applicationDocumentsDirectory];
    dataSource.pgetDBName = @"testProjectDatabase.sqlite";
    
    //cachingManager = [StockPile getInMemoryDiskCopyCacheUsingData:dataSource];
    
    cachingManager = [StockPile getInMemoryDBOverflowCacheUsingData:dataSource];
    
    InMemoryCacheDataSourceImpl *inMemoryDataSource = [[InMemoryCacheDataSourceImpl alloc] init];
    inMemoryDataSource.isForAutomatedTest = NO;
    inMemoryDataSource.pmaximumElementInMemory = [_countOfElements.text integerValue];
    inMemoryDataSource.pmaximumMemoryAllocated = [_memoryAllocated.text integerValue];
    
    //cachingManager = [StockPile getInMemoryCacheUsingData:inMemoryDataSource];
}

- (IBAction)runTestClicked:(id)sender
{
    [self performSelectorInBackground:@selector(runTestCases) withObject:nil];
}

- (void) runTestCases
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _nsCacheAccessTimeLabel.text = @"";
        _nsCacheCachingTimeLabel.text = @"";
        _stockPileCachingTimeLabel.text = @"";
        _stockPileAccessTimeLabel.text = @"";
    });
    
    countOfElementsToCache = [_countOfElementsToRunTest.text integerValue];
    [self nsCacheCaching];
    [self nsCacheAccess];
    [self stockPileCaching];
    [self stockPileAccess];
}

- (void)nsCacheAccess
{
    NSTimeInterval timeInterval = [self measureBlock:^{
        for (int i = 0 ; i < countOfElementsToCache ; i++)
        {
            NSString* str = [NSString stringWithFormat:@"%@%d", letters, i];
            [nsCache objectForKey:str];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _nsCacheAccessTimeLabel.text = [NSString stringWithFormat:@"%f", timeInterval];
    });
}

- (void) nsCacheCaching
{
    NSTimeInterval timeInterval = [self measureBlock:^{
        for (int i = 0 ; i < countOfElementsToCache ; i++)
        {
            NSString* str = [NSString stringWithFormat:@"%@%d", letters, i];
            float sizeOfData = (float)malloc_size((__bridge const void *)(str))/1024.0f/1024.0f;
            [nsCache setObject:str forKey:str cost:sizeOfData];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _nsCacheCachingTimeLabel.text = [NSString stringWithFormat:@"%f", timeInterval];
    });
}

- (void)stockPileCaching
{
   NSTimeInterval timeInterval = [self measureBlock:^{
        for (int i = 0 ; i < countOfElementsToCache ; i++)
        {
            NSString* str = [NSString stringWithFormat:@"%@%d", letters, i];
            
            Value* value = [[Value alloc] init];
            value.value = str;
            [automatedTestCachingManager cacheValue:value forKey:str];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _stockPileCachingTimeLabel.text = [NSString stringWithFormat:@"%f", timeInterval];
    });
}

- (void)stockPileAccess
{
    NSTimeInterval timeInterval = [self measureBlock:^{
        for (int i = 0 ; i < countOfElementsToCache ; i++)
        {
            NSString* str = [NSString stringWithFormat:@"%@%d", letters, i];
            
            [automatedTestCachingManager getValueForKey:str];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _stockPileAccessTimeLabel.text = [NSString stringWithFormat:@"%f", timeInterval];
    });
}

- (NSTimeInterval) measureBlock: (void(^)())block
{
    NSDate* startTime = [NSDate date];
    
    block();
    
    NSDate* endTime = [NSDate date];
    
    return [endTime timeIntervalSinceDate:startTime];
}

@end