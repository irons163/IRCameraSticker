//
//  IRCameraSticker.h
//  IRCameraSticker
//
//  Created by irons on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import "IRCameraStickerItem.h"

//! Project version number for IRCameraSticker.
FOUNDATION_EXPORT double IRCameraStickerVersionNumber;

//! Project version string for IRCameraSticker.
FOUNDATION_EXPORT const unsigned char IRCameraStickerVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface IRCameraSticker : NSObject

@property (nonatomic, readonly) NSArray<IRCameraStickerItem *> *items;

@property (nonatomic, readonly) NSString *dir;

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSString *preview;

@property (nonatomic, readonly) NSString *audio;

- (instancetype)initWithDirectoryURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
