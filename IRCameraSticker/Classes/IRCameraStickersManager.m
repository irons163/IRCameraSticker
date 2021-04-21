//
//  IRCameraStickersManager.m
//  IRCameraSticker
//
//  Created by irons on 2021/3/2.
//

#import "IRCameraStickersManager.h"
#import "IRCameraSticker.h"

@implementation IRCameraStickersManager {
    dispatch_queue_t ioQueue;
    NSFileManager *fileManager;
    
    NSBundle *stickerBundle;
}

+ (instancetype)sharedManager {
    static id stickersManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stickersManager = [IRCameraStickersManager new];
    });
    
    return stickersManager;
}

+ (void)loadStickersWithCompletion:(void (^)(NSArray<IRCameraSticker *> *))completion {
    [[self sharedManager] _loadStickersWithCompletion:completion];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ioQueue = dispatch_queue_create("design.asura.stickers", DISPATCH_QUEUE_SERIAL);
        fileManager = [[NSFileManager alloc] init];
        
        NSString *path = [[IRCameraStickersManager getCurrentBundle] pathForResource:@"IRCameraStickerResources" ofType:@"bundle"];
        stickerBundle = [NSBundle bundleWithPath:path];
    }
    
    return self;
}

+ (NSBundle *)getCurrentBundle {
    return [NSBundle bundleForClass:self];
}

#pragma mark - Private
- (void)_loadStickersWithCompletion:(void(^)(NSArray<IRCameraSticker *> *))completion {
    dispatch_async(ioQueue, ^{
        NSArray *stickers = [self _loadStickers];
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ?: completion(stickers);
        });
    });
}

- (NSArray *)_loadStickers {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:[stickerBundle.bundlePath stringByAppendingPathComponent:@"stickers"]
                                     isDirectory:YES];
    NSArray *resourceKeys = @[ NSURLNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey ];
    
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                              includingPropertiesForKeys:resourceKeys
                                                                 options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        return NO;
    }];
    
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        if (![resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }
    
    NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                    usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[NSURLNameKey] localizedCompare:obj2[NSURLNameKey]];
    }];
    
    NSMutableArray *stickers = [NSMutableArray arrayWithCapacity:sortedFiles.count];
    
    for (NSURL *fileURL in sortedFiles) {
        IRCameraSticker *sticker = [[IRCameraSticker alloc] initWithDirectoryURL:fileURL];
        if (sticker) {
            [stickers addObject:sticker];
        }
    }
    
    return [NSArray arrayWithArray:stickers];
}

@end
