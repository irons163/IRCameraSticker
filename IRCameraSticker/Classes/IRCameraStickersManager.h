//
//  IRCameraStickersManager.h
//  IRCameraSticker
//
//  Created by irons on 2021/3/2.
//

#import <Foundation/Foundation.h>

@class IRCameraSticker;

NS_ASSUME_NONNULL_BEGIN

@interface IRCameraStickersManager : NSObject

+ (void)loadStickersWithCompletion:(void(^)(NSArray<IRCameraSticker *> *stickers))completion;

@end

NS_ASSUME_NONNULL_END
