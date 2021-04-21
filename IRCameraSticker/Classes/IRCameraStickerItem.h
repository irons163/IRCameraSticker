//
//  IRCameraStickerItem.h
//  IRCameraSticker
//
//  Created by irons on 2021/3/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    IRCameraStickerItemTypeFace,
    IRCameraStickerItemTypeScreen,
} IRCameraStickerItemType;

typedef enum {
    IRCameraStickerItemAlignPositionTop,
    IRCameraStickerItemAlignPositionLeft,
    IRCameraStickerItemAlignPositionBottom,
    IRCameraStickerItemAlignPositionRight,
    IRCameraStickerItemAlignPositionCenter
} IRCameraStickerItemAlignPosition;

typedef enum {
    IRCameraStickerItemTriggerTypeNormal,
    IRCameraStickerItemTriggerTypeFace,
    IRCameraStickerItemTriggerTypeMouthOpen,
    IRCameraStickerItemTriggerTypeBlink,
    IRCameraStickerItemTriggerTypeFrown
} IRCameraStickerItemTriggerType;

@interface IRCameraStickerItem : NSObject

@property (nonatomic) IRCameraStickerItemType type;

@property (nonatomic) IRCameraStickerItemTriggerType triggerType;

@property (nonatomic, copy) NSString *dir;

@property (nonatomic) NSUInteger count;

@property (nonatomic) NSTimeInterval frameDuration;

@property (nonatomic) float width;

@property (nonatomic) float height;

@property (nonatomic, copy) NSArray *alignIndexes;

@property (nonatomic) IRCameraStickerItemAlignPosition alignPosition;

@property (nonatomic) float scaleWidth;

@property (nonatomic) float scaleHeight;

@property (nonatomic) float offsetX;

@property (nonatomic) float offsetY;

@property (nonatomic) BOOL triggered;

@property (nonatomic) NSUInteger currentFrameIndex;

@property (nonatomic) NSUInteger loopCountdown;

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;

- (NSUInteger)nextFrameIndexForInterval:(NSTimeInterval)interval;

- (UIImage *)imageAtIndex:(NSUInteger)index;

@end


NS_ASSUME_NONNULL_END
