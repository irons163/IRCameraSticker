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

/**
 需要绘制的贴纸
 */
@property (nonatomic, strong) IRCameraSticker *sticker;


/**
 关键点，元素需为CGPoint数组
 */
@property (nonatomic, copy) NSArray<NSArray *> *faces;

@end

NS_ASSUME_NONNULL_END
