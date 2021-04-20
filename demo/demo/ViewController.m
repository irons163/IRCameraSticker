//
//  ViewController.m
//  demo
//
//  Created by irons on 2021/2/25.
//

#import "ViewController.h"

#import <GPUImage/GPUImage.h>

#import "IRCameraSticker.h"
#import "IRCameraStickerFilter.h"
#import "IRCameraStickersManager.h"

@import Vision;

@interface ViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@property (nonatomic, strong) IRCameraStickerFilter *stickerFilter;

@property (nonatomic, copy) NSArray<IRCameraSticker *> *stickers;

@property (nonatomic, strong) NSArray<CAShapeLayer *> *drawings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.delegate = self;
    
    self.stickerFilter = [IRCameraStickerFilter new];
    [self.videoCamera addTarget:self.stickerFilter];
    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.center = self.view.center;
    
    [self.view addSubview:self.filterView];
    
    self.filterView.layer.frame = self.view.frame;
    
    [self.stickerFilter addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    [IRCameraStickersManager loadStickersWithCompletion:^(NSArray<IRCameraSticker *> *stickers) {
        self.stickers = stickers;
        self.stickerFilter.sticker = [stickers firstObject];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef frame = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self detectFace:frame];
}

- (void)detectFace:(CVPixelBufferRef)image {
    size_t width = CVPixelBufferGetWidth(image);
    size_t height = CVPixelBufferGetHeight(image);
    
    VNDetectFaceLandmarksRequest *faceDetectionRequest = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([request.results isKindOfClass:[NSArray<VNFaceObservation *> class]]) {
                [self handleFaceDetectionResults:request.results size:CGSizeMake(width, height)];
            } else {
                [self clearDrawings];
            }
        });
    }];
    
    VNImageRequestHandler *imageRequestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:image orientation:kCGImagePropertyOrientationLeftMirrored options:0];
    [imageRequestHandler performRequests:@[faceDetectionRequest] error:nil];
}

- (void)handleFaceDetectionResults:(NSArray<VNFaceObservation *> *)observedFaces size:(CGSize)size {
    [self clearDrawings];
    
    NSMutableArray<CAShapeLayer *> *facesBoundingBoxes = [NSMutableArray array];
    
    for (VNFaceObservation *observedFace in observedFaces) {
        CGFloat scaleX = self.filterView.layer.frame.size.width / size.width;
        CGFloat scaleY = self.filterView.layer.frame.size.height / size.height;
        
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleX, -scaleY), 0, -1);
        CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(CGRectApplyAffineTransform(observedFace.boundingBox, transform), size.width, size.height);
        
        CGPathRef faceBoundingBoxPath = CGPathCreateWithRect(faceBoundingBoxOnScreen, nil);
        CAShapeLayer *faceBoundingBoxShape = [CAShapeLayer layer];
        faceBoundingBoxShape.path = faceBoundingBoxPath;
        faceBoundingBoxShape.fillColor = [UIColor clearColor].CGColor;
        faceBoundingBoxShape.strokeColor = [UIColor greenColor].CGColor;
        NSMutableArray<CAShapeLayer *> *newDrawings = [NSMutableArray array];
        [newDrawings addObject:faceBoundingBoxShape];
        if (observedFace.landmarks) {
            [newDrawings addObjectsFromArray:[self drawFaceFeatures:observedFace.landmarks WithBoundingBox:observedFace.boundingBox size:size]];
        }
        [facesBoundingBoxes addObjectsFromArray:newDrawings];
        
        for (CAShapeLayer *faceBoundingBox in facesBoundingBoxes) {
            [self.filterView.layer addSublayer:faceBoundingBox];
        }
        
        self.drawings = facesBoundingBoxes;
    }
}
    
- (void)clearDrawings {
    for (CAShapeLayer *drawing in self.drawings) {
        [drawing removeFromSuperlayer];
    }
}

- (NSMutableArray<CAShapeLayer *> *)drawFaceFeatures:(VNFaceLandmarks2D *)landmarks WithBoundingBox:(CGRect)screenBoundingBox size:(CGSize)size {
    NSMutableArray<CAShapeLayer *> *faceFeaturesDrawings = [NSMutableArray array];
    if (landmarks.leftEye) {
        CAShapeLayer *eyeDrawing = [self drawEye:landmarks.leftEye WithBoundingBox:screenBoundingBox size:size];
        [faceFeaturesDrawings addObject:eyeDrawing];
    }
    if (landmarks.rightEye) {
        CAShapeLayer *eyeDrawing = [self drawEye:landmarks.rightEye WithBoundingBox:screenBoundingBox size:size];
        [faceFeaturesDrawings addObject:eyeDrawing];
    }
    
    if (landmarks.allPoints) {
        NSMutableArray *newAllPointsArray = [NSMutableArray array];
        const CGPoint *pointsInImage = [landmarks.allPoints pointsInImageOfSize:CGSizeMake(size.width, size.height)];
        for (int i = 0; i < landmarks.allPoints.pointCount; i++) {
            CGPoint eyePoint = pointsInImage[i];

            CGFloat scaleX = (self.filterView.layer.frame.size.width / size.width) * (size.height / self.filterView.layer.frame.size.width);
            CGFloat scaleY = (self.filterView.layer.frame.size.height / size.height) * (size.width / self.filterView.layer.frame.size.height);
            
            CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleX, -scaleY), 0, -size.height);
            
            eyePoint = CGPointApplyAffineTransform(eyePoint, transform);
            
            [newAllPointsArray addObject:[NSValue valueWithCGPoint:eyePoint]];
        }
        
        self.stickerFilter.faces = @[newAllPointsArray];
    }
    
    return faceFeaturesDrawings;
}

- (CAShapeLayer *)drawEye:(VNFaceLandmarkRegion2D *)eye WithBoundingBox:(CGRect)screenBoundingBox size:(CGSize)size {
    CGMutablePathRef eyePath = CGPathCreateMutable();
    
    CGPoint *newEyePoints = malloc(sizeof(CGPoint) * eye.pointCount);
    NSMutableArray *newEyePointsArray = [NSMutableArray array];

    const CGPoint *pointsInImage = [eye pointsInImageOfSize:CGSizeMake(size.width, size.height)];
    for (int i = 0; i < eye.pointCount; i++) {
        CGPoint eyePoint = pointsInImage[i];

        CGFloat scaleX = self.filterView.layer.frame.size.width / size.width;
        CGFloat scaleY = self.filterView.layer.frame.size.height / size.height;
        
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleX, -scaleY), 0, -size.height);

        eyePoint = CGPointApplyAffineTransform(eyePoint, transform);

        newEyePoints[i] = eyePoint;
        [newEyePointsArray addObject:[NSValue valueWithCGPoint:eyePoint]];
    }
    
    /*
    for (int i = 0; i < eye.pointCount; i++) {
        CGPoint eyePoint = eye.normalizedPoints[i];
        CGRect faceBounds = VNImageRectForNormalizedRect(screenBoundingBox, size.width, size.height);

        CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(faceBounds.origin.x, faceBounds.origin.y), faceBounds.size.width, faceBounds.size.height);

        eyePoint = CGPointApplyAffineTransform(eyePoint, transform);

        CGFloat scaleX = self.filterView.layer.frame.size.width / size.width;
        CGFloat scaleY = self.filterView.layer.frame.size.height / size.height;

        transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleX, -scaleY), 0, -size.height);

        eyePoint = CGPointApplyAffineTransform(eyePoint, transform);

        newEyePoints[i] = eyePoint;
        [newEyePointsArray addObject:[NSValue valueWithCGPoint:eyePoint]];
    }
    */
    
    CGPathAddLines(eyePath, nil, newEyePoints, eye.pointCount);
    CGPathCloseSubpath(eyePath);
    CAShapeLayer *eyeDrawing = [CAShapeLayer layer];
    eyeDrawing.anchorPoint = CGPointMake(0.5, 0.5);
    eyeDrawing.position = CGPointMake(size.width / 2, size.height / 2);
    eyeDrawing.bounds = CGRectMake(0, 0, size.width, size.height);
    eyeDrawing.path = eyePath;
    eyeDrawing.fillColor = [UIColor clearColor].CGColor;
    eyeDrawing.strokeColor = [UIColor greenColor].CGColor;
    
    return eyeDrawing;
}

@end
