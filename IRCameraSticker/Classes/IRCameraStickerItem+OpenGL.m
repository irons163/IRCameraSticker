//
//  IRCameraStickerItem+OpenGL.m
//  IRCameraSticker
//
//  Created by irons on 2021/4/20.
//

#import "IRCameraStickerItem+OpenGL.h"

#import <objc/runtime.h>
#import <OpenGLES/ES2/gl.h>

static void *kTexturesWrapperKey = &kTexturesWrapperKey;

@interface IRCameraStickerTexturesWrapper : NSObject

- (instancetype)initWithSize:(NSUInteger)size;

- (GLuint)textureAtIndex:(NSUInteger)index;
- (void)setTexture:(GLuint)texture atIndex:(NSUInteger)index;

- (void)removeAllTextures;

@end

@implementation IRCameraStickerTexturesWrapper {
    GLuint *textureArr;
    NSUInteger size;
}

- (void)dealloc {
    [self removeAllTextures];
}

- (instancetype)initWithSize:(NSUInteger)_size {
    self = [super init];
    if (self) {
        size = _size;
    }
    
    return self;
}

- (GLuint)textureAtIndex:(NSUInteger)index {
    if (textureArr == NULL) {
        textureArr = (GLuint *)malloc(size * sizeof(GLuint));
        if (textureArr == NULL) {
            return 0;
        }
        
        for (int i = 0; i < size; i++) {
            textureArr[i] = 0;
        }
    }
    
    return textureArr[index];
}

- (void)setTexture:(GLuint)texture atIndex:(NSUInteger)index {
    textureArr[index] = texture;
}

- (void)removeAllTextures {
    if (textureArr) {
        glDeleteTextures((GLsizei)size, textureArr);
        free(textureArr);
        textureArr = NULL;
    }
}

@end


@implementation IRCameraStickerItem (OpenGL)

- (IRCameraStickerTexturesWrapper *)textures {
    IRCameraStickerTexturesWrapper *wrapper = objc_getAssociatedObject(self, kTexturesWrapperKey);
    if (!wrapper) {
        wrapper = [[IRCameraStickerTexturesWrapper alloc] initWithSize:self.count];
        objc_setAssociatedObject(self, kTexturesWrapperKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return wrapper;
}

- (GLuint)_textureWithImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        // Failed to load image
        return 0;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    GLubyte *imageData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(spriteContext);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    free(imageData);
    
    return texture;
}

- (GLuint)_textureAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return 0;
    }
    
    GLuint texture = [[self textures] textureAtIndex:index];
    if (texture == 0) {
        texture = [self _textureWithImage:[self imageAtIndex:index]];
        [[self textures] setTexture:texture atIndex:index];
    }
    
    return texture;
}

- (GLuint)nextTextureForInterval:(NSTimeInterval)interval {
    self.currentFrameIndex = [self nextFrameIndexForInterval:interval];
    
    return [self _textureAtIndex:self.currentFrameIndex];
}

- (void)deleteTextures {
    [[self textures] removeAllTextures];
}

@end

