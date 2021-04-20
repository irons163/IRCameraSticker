//
//  IRCameraSticker+OpenGL.m
//  IRCameraSticker
//
//  Created by irons on 2021/4/20.
//

#import "IRCameraSticker+OpenGL.h"
#import "IRCameraStickerItem+OpenGL.h"


@implementation IRCameraSticker (OpenGL)

- (void)drawItemsWithFacePoints:(NSArray *)points
                framebufferSize:(CGSize)size
                   timeInterval:(NSTimeInterval)interval
                     usingBlock:(void (^)(GLfloat *, GLuint))block
{
    // 顶点坐标
    static GLfloat vertices[8] = {0};

    // 计算眼间距，以此作为调整item大小的参考
    CGPoint eye_left = [points[13] CGPointValue];
    CGPoint eye_right = [points[6] CGPointValue];
    
//    eye_left.y = 1 - eye_left.y;
//    eye_right.y = 1 - eye_right.y;
    
//    eye_left.x *= size.width / 2;
//    eye_left.y *= size.height / 2;
//    eye_right.x *= size.width / 2;
//    eye_right.y *= size.height / 2;
    
//    eye_left.x *= size.width;
//    eye_left.y *= size.height;
//    eye_right.x *= size.width;
//    eye_right.y *= size.height;
    
    CGFloat eye_dist = distance(eye_left, eye_right);
    
    float signx = 1.0 * (eye_right.y - eye_left.y) / eye_dist;
    float cosignx = 1.0 * (eye_right.x - eye_left.x) / eye_dist;
    
    for (IRCameraStickerItem *item in self.items) {
        switch (item.type) {
            case IRCameraStickerItemTypeFace:
            {
                CGPoint left_point = [points[[item.alignIndexes[0] intValue]] CGPointValue];
                CGPoint center_point = [points[[item.alignIndexes[1] intValue]] CGPointValue];
                CGPoint right_point = [points[[item.alignIndexes[2] intValue]] CGPointValue];
                
//                left_point.y = 1 - left_point.y;
//                center_point.y = 1 - center_point.y;
//                right_point.y = 1 - right_point.y;
                
//                left_point.x *= size.width / 2;
//                left_point.y *= size.height / 2;
//                center_point.x *= size.width / 2;
//                center_point.y *= size.height / 2;
//                right_point.x *= size.width / 2;
//                right_point.y *= size.height / 2;
                
//                left_point.x *= size.width;
//                left_point.y *= size.height;
//                center_point.x *= size.width;
//                center_point.y *= size.height;
//                right_point.x *= size.width;
//                right_point.y *= size.height;
                
                CGFloat dist = distance(left_point, right_point);
                
                // 计算item的宽高及顶点坐标
                float itemWidth = dist + eye_dist * item.scaleWidth;
                float itemHeight = itemWidth * item.height / item.width;
                
//                CGFloat left = center_point.x - itemWidth / 2. + eye_dist * item.offsetX;
//                CGFloat right = center_point.x + itemWidth / 2. + eye_dist * item.offsetX;
//                CGFloat top = center_point.y + itemHeight / 2. + eye_dist * item.offsetY;
//                CGFloat bottom = center_point.y - itemHeight / 2. + eye_dist * item.offsetY;
                
                CGFloat left = center_point.x - itemWidth / 2. + eye_dist * item.offsetX;
                CGFloat right = center_point.x + itemWidth / 2. + eye_dist * item.offsetX;
                CGFloat top = center_point.y - itemHeight / 2. + eye_dist * item.offsetY;
                CGFloat bottom = center_point.y + itemHeight / 2. + eye_dist * item.offsetY;
                
                // 旋转
                vertices[0] = ((left - center_point.x) * cosignx - (bottom - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[1] = ((left - center_point.x) * signx + (bottom - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
                vertices[2] = ((right - center_point.x) * cosignx - (bottom - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[3] = ((right - center_point.x) * signx + (bottom - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
                vertices[4] = ((left - center_point.x) * cosignx - (top - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[5] = ((left - center_point.x) * signx + (top - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
                vertices[6] = ((right - center_point.x) * cosignx - (top - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[7] = ((right - center_point.x) * signx + (top - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
                
//                vertices[0] = ((left - center_point.x) * cosignx - (top - center_point.y) * signx + center_point.x) / size.width * 2. -1;
//                vertices[1] = ((left - center_point.x) * signx + (top - center_point.y) * cosignx + center_point.y) / size.height * 2. -1;
//                vertices[2] = ((right - center_point.x) * cosignx - (top - center_point.y) * signx + center_point.x) / size.width * 2. -1;
//                vertices[3] = ((right - center_point.x) * signx + (top - center_point.y) * cosignx + center_point.y) / size.height * 2.;
//                vertices[4] = ((left - center_point.x) * cosignx - (bottom - center_point.y) * signx + center_point.x) / size.width * 2.;
//                vertices[5] = ((left - center_point.x) * signx + (bottom - center_point.y) * cosignx + center_point.y) / size.height * 2.;
//                vertices[6] = ((right - center_point.x) * cosignx - (bottom - center_point.y) * signx + center_point.x) / size.width * 2.;
//                vertices[7] = ((right - center_point.x) * signx + (bottom - center_point.y) * cosignx + center_point.y) / size.height * 2. -1;
                
//                vertices[0] = left / size.width * 2 -1;
//                vertices[1] = bottom / size.height * 2 -1;
//                vertices[2] = right / size.width * 2 -1;
//                vertices[3] = vertices[1];
//                vertices[4] = vertices[0];
//                vertices[5] = top / size.height * 2 -1;
//                vertices[6] = vertices[2];
//                vertices[7] = vertices[5];
                
//                vertices[0] = -1.0f;  // x0
//                vertices[1] = -1.0f;  // y0
//                vertices[2] =  1.0f;  // ..
//                vertices[3] = -1.0f;
//                vertices[4] = -1.0f;
//                vertices[5] =  1.0f;
//                vertices[6] =  1.0f;  // x3
//                vertices[7] =  1.0f;  // y3
                
//                vertices[0] = -1.0f;  // x0
//                vertices[1] = -1.0f;  // y0
//                vertices[2] = 1.0f;  // ..
//                vertices[3] = -1.0f;
//                vertices[4] = -1.0f;
//                vertices[5] =  0.05f;
//                vertices[6] =  1.0f;  // x3
//                vertices[7] =  0.05f;  // y3
                
//                vertices[0] = left / size.width * 2 -1;
//                vertices[1] = bottom / size.height * 2 -1;
//                vertices[2] = right / size.width * 2 -1;
//                vertices[3] = vertices[1];
//                vertices[4] = vertices[0];
//                vertices[5] = top / size.height * 2 -1;
//                vertices[6] = vertices[2];
//                vertices[7] = vertices[5];
            }
                break;
                
            case IRCameraStickerItemTypeScreen:
            {
                // TODO: 多张人脸只画一次
                
                CGFloat left, right, top, bottom;
                CGFloat itemWidth, itemHeight;
                
                switch (item.alignPosition) {
                    case IRCameraStickerItemAlignPositionTop:
                    {
                        itemWidth = size.width * item.scaleWidth;
                        itemHeight = ceil(itemWidth * (item.height / item.width));
                        
                        left = (size.width - itemWidth) / 2 + size.width * item.offsetX;
                        right = left + itemWidth;
                        
                        bottom = size.width * item.offsetY;
                        top = bottom + itemHeight;
                    }
                        break;
                        
                    case IRCameraStickerItemAlignPositionLeft:
                    case IRCameraStickerItemAlignPositionBottom:
                    case IRCameraStickerItemAlignPositionRight:
                    case IRCameraStickerItemAlignPositionCenter:
                    {
                        // TODO: 其它位置的适配
                    }
                        break;
                        
                    default:
                        break;
                }
                
                vertices[0] = left / size.width * 2 -1;
                vertices[1] = bottom / size.height * 2 -1;
                vertices[2] = right / size.width * 2 -1;
                vertices[3] = vertices[1];
                vertices[4] = vertices[0];
                vertices[5] = top / size.height * 2 -1;
                vertices[6] = vertices[2];
                vertices[7] = vertices[5];
                
//                vertices[0] = left / size.width * 2 -1;
//                vertices[1] = top / size.height * 2 -1;
//                vertices[2] = right / size.width * 2 -1;
//                vertices[3] = vertices[1];
//                vertices[4] = vertices[0];
//                vertices[5] = bottom / size.height * 2 -1;
//                vertices[6] = vertices[2];
//                vertices[7] = vertices[5];
            }
                break;
                
            default:
                break;
        }
        
        GLuint texture = [item nextTextureForInterval:interval];
        !block ?: block(vertices, texture);
    }
}

- (void)reset
{
    for (IRCameraStickerItem *item in self.items) {
        [item deleteTextures];
    }
}

static CGFloat distance(CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

@end

