//
//  IRCameraStickerItem+OpenGL.h
//  IRCameraSticker
//
//  Created by irons on 2021/4/20.
//

#import "IRCameraStickerItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRCameraStickerItem (OpenGL)

- (GLuint)nextTextureForInterval:(NSTimeInterval)interval;

- (void)deleteTextures;

@end

NS_ASSUME_NONNULL_END
