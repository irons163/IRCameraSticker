//
//  IRCameraSticker.m
//  IRCameraSticker
//
//  Created by irons on 2021/3/2.
//

#import <Foundation/Foundation.h>
#import "IRCameraSticker.h"

@implementation IRCameraSticker

- (instancetype)initWithDirectoryURL:(NSURL *)url {
    NSString *dir = url.path;
    NSString *configFile = [dir stringByAppendingPathComponent:@"meta.json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configFile isDirectory:NULL]) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:configFile];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error || !dict) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _dir = dir;
        
        _name = [dict objectForKey:@"name"];
        _preview = [dict objectForKey:@"preview"];
        _audio = [dict objectForKey:@"audio"];
        
        NSArray *itemsDict = [dict objectForKey:@"items"];
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemsDict.count];
        for (NSDictionary *itemDict in itemsDict) {
            IRCameraStickerItem *item = [[IRCameraStickerItem alloc] initWithJSONDictionary:itemDict];
            item.dir = [_dir stringByAppendingPathComponent:item.dir];
            
            [items addObject:item];
        }
        
        _items = items;
    }
    
    return self;
}

@end
