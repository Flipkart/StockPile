//
//  ViewController.m
//  CachingTestProject
//
//  Created by Prabodh Prakash on 27/08/15.
//  Copyright (c) 2015 Flipkart. All rights reserved.
//

#import "ViewController.h"


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

@interface ViewController ()
- (IBAction)addToCacheClicked:(id)sender;
- (IBAction)getValueClicked:(id)sender;
- (IBAction)initCacheClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *cachedValue;
@property (weak, nonatomic) IBOutlet UITextField *countOfElements;
@property (weak, nonatomic) IBOutlet UITextField *memoryAllocated;
@property (weak, nonatomic) IBOutlet UITextField *valueToAdd;
@property (weak, nonatomic) IBOutlet UITextField *valueToGet;

//@property (nonatomic,strong) CacheFactoryDataSource* dataSource;
@property (nonatomic, strong) id <CacheProtocol> cachingManager;

@end



@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    
    [self.cachingManager cacheValue:value forKey:key];
}

- (IBAction)getValueClicked:(id)sender
{
    Value* data = [_cachingManager getValueForKey:_valueToGet.text];
    
    _cachedValue.text = (NSString*)data.value;
}

- (IBAction)initCacheClicked:(id)sender
{
//    StockPile getInMemoryDBCopyCacheUsingData:(id<DBCacheDataSource>);
    
    DBCacheDataSourceImpl *dataSource = [[DBCacheDataSourceImpl alloc] init];
    dataSource.pmaximumElementInMemory = [_countOfElements.text integerValue];
    dataSource.pmaximumMemoryAllocated = [_memoryAllocated.text integerValue];
    dataSource.ppathForDiskCaching = [self applicationDocumentsDirectory];
    dataSource.pgetDBName = @"testProjectDatabase.sqlite";

    self.cachingManager = [StockPile getInMemoryDBCopyCacheUsingData:dataSource];
//    _cachingManager = [CacheFactory getCacheWithPolicy:DISK_PERSISTENCE cacheFactoryDataSource:_dataSource];
}



@end