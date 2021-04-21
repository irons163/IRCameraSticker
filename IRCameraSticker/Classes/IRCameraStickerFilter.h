//
//  IRCameraStickerFilter.h
//  IRCameraSticker
//
//  Created by irons on 2021/4/20.
//

#import <GPUImage/GPUImage.h>

@class IRCameraSticker;

NS_ASSUME_NONNULL_BEGIN

@interface IRCameraStickerFilter : GPUImageFilter

@property (nonatomic, strong) IRCameraSticker *sticker;

@property (nonatomic, copy) NSArray<NSArray *> *faces;

@end

NS_ASSUME_NONNULL_END
