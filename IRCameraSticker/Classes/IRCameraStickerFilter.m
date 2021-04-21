//
//  IRCameraStickerFilter.m
//  IRCameraSticker
//
//  Created by irons on 2021/4/20.
//

#import "IRCameraStickerFilter.h"
#import "IRCameraSticker+OpenGL.h"

@implementation IRCameraStickerFilter {
    GLuint framebufferHandle;
    
    CMTime lastTime;
    CMTime currentTime;
}

- (void)dealloc {
    if (framebufferHandle) {
        glDeleteFramebuffers(1, &framebufferHandle);
        framebufferHandle = 0;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        lastTime = kCMTimeInvalid;
        currentTime = kCMTimeInvalid;
        
        runSynchronouslyOnVideoProcessingQueue(^{
            glGenFramebuffers(1, &self->framebufferHandle);
            glBindFramebuffer(GL_FRAMEBUFFER, self->framebufferHandle);
        });
    }
    
    return self;
}

- (void)setSticker:(IRCameraSticker *)sticker {
    runAsynchronouslyOnVideoProcessingQueue(^{
        if (self->_sticker == sticker) {
            return;
        }
        
        [GPUImageContext useImageProcessingContext];
        
        [self->_sticker reset];
        self->_sticker = sticker;
    });
}

- (void)setFaces:(NSArray<NSArray *> *)faces {
    runAsynchronouslyOnVideoProcessingQueue(^{
        self->_faces = faces;
    });
}

#pragma mark - Override
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    currentTime = frameTime;
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if (self.preventRendering) {
        [firstInputFramebuffer unlock];
        return;
    }
    
    if (usingNextFrameForImageCapture) {
        [firstInputFramebuffer lock];
    }
    
    NSTimeInterval interval = 0;
    if (CMTIME_IS_VALID(lastTime)) {
        interval = CMTimeGetSeconds(CMTimeSubtract(currentTime, lastTime));
    }
    lastTime = currentTime;
    
    if (self.faces.count) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        glBindFramebuffer(GL_FRAMEBUFFER, framebufferHandle);
        glViewport(0, 0, inputTextureSize.width, inputTextureSize.height);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, firstInputFramebuffer.texture);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, firstInputFramebuffer.texture, 0);
        
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        for (NSArray *points in _faces) {
            [_sticker drawItemsWithFacePoints:points
                              framebufferSize:inputTextureSize
                                 timeInterval:interval
                                   usingBlock:^(GLfloat *vertices, GLuint texture) {
                glActiveTexture(GL_TEXTURE2);
                glBindTexture(GL_TEXTURE_2D, texture);
                
                glUniform1i(self->filterInputTextureUniform, 2);
                
                glVertexAttribPointer(self->filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
                glVertexAttribPointer(self->filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
                
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                glBindTexture(GL_TEXTURE_2D, 0);
            }];
        }
        
        glDisable(GL_BLEND);
    }
    
    outputFramebuffer = firstInputFramebuffer;
    
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end

