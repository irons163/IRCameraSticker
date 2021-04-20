//
//  IRCameraSticker+OpenGL.h
//  IRCameraSticker
//
//  Created by irons on 2021/4/20.
//

#import "IRCameraSticker.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRCameraSticker (OpenGL)

- (void)drawItemsWithFacePoints:(NSArray *)points
                framebufferSize:(CGSize)size
                   timeInterval:(NSTimeInterval)interval
                     usingBlock:(void (^)(GLfloat *vertices, GLuint texture))block;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
