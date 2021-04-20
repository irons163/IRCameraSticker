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
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetLow cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.delegate = self;
    
    self.stickerFilter = [IRCameraStickerFilter new];
    [self.videoCamera addTarget:self.stickerFilter];
    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.center = self.view.center;
    
    [self.view addSubview:self.filterView];
    
//    self.filterView.layer.videoGravity = .resizeAspectFill
//    self.view.layer.addSublayer(self.previewLayer)
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
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // 在这里做人脸的检测
    CVImageBufferRef frame = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self detectFace:frame];
    
//    CGRect frame = CMSampleBufferGetImageBuffer(sampleBuffer)
//    self.detectFace(in: frame)
    
    // 使用假数据
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"fake_points" ofType:@"json"];
//    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
//                                                     options:0
//                                                       error:nil];
//
//    NSMutableArray *faces = [NSMutableArray arrayWithCapacity:arr.count];
//    for (NSArray *ele in arr) {
//        NSMutableArray *points = [NSMutableArray arrayWithCapacity:ele.count];
//        for (NSDictionary *dic in ele) {
//            CGPoint point = CGPointMake([dic[@"x"] floatValue], [dic[@"y"] floatValue]);
//            [points addObject:[NSValue valueWithCGPoint:point]];
//        }
//
//        [faces addObject:points];
//    }
//
//    self.stickerFilter.faces = faces;
}

- (void)detectFace:(CVPixelBufferRef)image {
    size_t width = CVPixelBufferGetWidth(image);
    size_t height = CVPixelBufferGetHeight(image);
//    size_t height = self.filterView.layer.frame.size.height;
//    size_t width = self.filterView.layer.frame.size.width;
    
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
    
//    let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
//        DispatchQueue.main.async {
//            if let results = request.results as? [VNFaceObservation] {
//                self.handleFaceDetectionResults(results)
//            } else {
//                self.clearDrawings()
//            }
//        }
//    })
//    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
//    try? imageRequestHandler.perform([faceDetectionRequest])
}

- (void)handleFaceDetectionResults:(NSArray<VNFaceObservation *> *)observedFaces size:(CGSize)size {
        
    [self clearDrawings];
    NSMutableArray<CAShapeLayer *> *facesBoundingBoxes = [NSMutableArray array];
    
    for (VNFaceObservation *observedFace in observedFaces) {
//        CGRect faceBoundingBoxOnScreen2 = [self.filterView.layer convertRect:observedFace.boundingBox fromLayer:self.filterView.layer];
//        CGAffineTransform scale = CGAffineTransformMakeScale(self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
        CGFloat scaleX = self.filterView.layer.frame.size.width / size.width;
        CGFloat scaleY = self.filterView.layer.frame.size.height / size.height;
        
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleX, -scaleY), 0, -1);
        
//        let scale = CGAffineTransform.identity.scaledBy(x: viewRect.width, y: viewRect.height)
//            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        
//        CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(CGRectApplyAffineTransform(observedFace.boundingBox, transform), self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
        CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(CGRectApplyAffineTransform(observedFace.boundingBox, transform), size.width, size.height);
        
//        CGRect faceBoundingBoxOnScreen = CGRectZero;
//        faceBoundingBoxOnScreen.size.height = self.filterView.layer.frame.size.height * observedFace.boundingBox.size.width;
//        faceBoundingBoxOnScreen.size.width = self.filterView.layer.frame.size.width * observedFace.boundingBox.size.height;
//        faceBoundingBoxOnScreen.origin.x = observedFace.boundingBox.origin.y * self.filterView.layer.frame.size.width;
//        faceBoundingBoxOnScreen.origin.y = observedFace.boundingBox.origin.x * self.filterView.layer.frame.size.height;
        
//        CGRect faceBoundingBoxOnScreen = CGRectZero;
//        faceBoundingBoxOnScreen.size.height = self.filterView.layer.frame.size.height * observedFace.boundingBox.size.height;
//        faceBoundingBoxOnScreen.size.width = self.filterView.layer.frame.size.width * observedFace.boundingBox.size.width;
//        faceBoundingBoxOnScreen.origin.x = observedFace.boundingBox.origin.x * self.filterView.layer.frame.size.width;
//        faceBoundingBoxOnScreen.origin.y = observedFace.boundingBox.origin.y * self.filterView.layer.frame.size.height;
        
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
    
//    let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
//        let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
//        let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
//        let faceBoundingBoxShape = CAShapeLayer()
//        faceBoundingBoxShape.path = faceBoundingBoxPath
//        faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
//        faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
//        var newDrawings = [CAShapeLayer]()
//        newDrawings.append(faceBoundingBoxShape)
//        if let landmarks = observedFace.landmarks {
//            newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
//        }
//        return newDrawings
//    })
//    facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
//    self.drawings = facesBoundingBoxes
}
    
- (void)clearDrawings {
    for (CAShapeLayer *drawing in self.drawings) {
        [drawing removeFromSuperlayer];
    }
    
//    self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
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
        CGMutablePathRef eyePath = CGPathCreateMutable();
        
        CGPoint *newEyePoints = malloc(sizeof(CGPoint) * landmarks.allPoints.pointCount);
        NSMutableArray *newEyePointsArray = [NSMutableArray array];
        const CGPoint *pointsInImage = [landmarks.allPoints pointsInImageOfSize:CGSizeMake(self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height)];
        for (int i = 0; i < landmarks.allPoints.pointCount; i++) {
            CGPoint eyePoint = pointsInImage[i];

            CGAffineTransform scale = CGAffineTransformMakeScale(self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
            CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -self.filterView.layer.frame.size.height);
 
            CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(CGRectApplyAffineTransform(screenBoundingBox, transform), self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
            eyePoint = CGPointApplyAffineTransform(eyePoint, transform);
            
            newEyePoints[i] = eyePoint;
            [newEyePointsArray addObject:[NSValue valueWithCGPoint:eyePoint]];
        }
        
        self.stickerFilter.faces = @[newEyePointsArray];
    }
    
    return faceFeaturesDrawings;
    
//    var faceFeaturesDrawings: [CAShapeLayer] = []
//    if let leftEye = landmarks.leftEye {
//        let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
//        faceFeaturesDrawings.append(eyeDrawing)
//    }
//    if let rightEye = landmarks.rightEye {
//        let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
//        faceFeaturesDrawings.append(eyeDrawing)
//    }
//    // draw other face features here
//    return faceFeaturesDrawings
}

- (CAShapeLayer *)drawEye:(VNFaceLandmarkRegion2D *)eye WithBoundingBox:(CGRect)screenBoundingBox size:(CGSize)size {
    CGMutablePathRef eyePath = CGPathCreateMutable();
    
    CGPoint *newEyePoints = malloc(sizeof(CGPoint) * eye.pointCount);
    NSMutableArray *newEyePointsArray = [NSMutableArray array];
//    for (int i = 0; i < eye.pointCount; i++) {
//        CGPoint eyePoint = eye.normalizedPoints[i];
////        eyePoint.x = eyePoint.y * screenBoundingBox.size.height + screenBoundingBox.origin.x;
////        eyePoint.y = eyePoint.x * screenBoundingBox.size.width + screenBoundingBox.origin.y;
//
////        eyePoint.x = eyePoint.x * screenBoundingBox.size.width + screenBoundingBox.origin.x;
////        eyePoint.y = -eyePoint.y * screenBoundingBox.size.height + screenBoundingBox.origin.y;
////        CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(screenBoundingBox, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//
//        CGAffineTransform scale = CGAffineTransformMakeScale(self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -self.filterView.layer.frame.size.height);
////        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
////        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -1);
//
////        let scale = CGAffineTransform.identity.scaledBy(x: viewRect.width, y: viewRect.height)
////            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
//
//        CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(CGRectApplyAffineTransform(screenBoundingBox, transform), self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//
//
////        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
////        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), screenBoundingBox.size.width, screenBoundingBox.size.height);
////        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height);
////        eyePoint = CGPointApplyAffineTransform(VNImagePointForNormalizedPoint(eyePoint, faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height), transform);
//
////        eyePoint = CGPointApplyAffineTransform(VNImagePointForNormalizedPoint(eyePoint, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height), transform);
//
////        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height);
//
////        eyePoint = VNImagePointForNormalizedPoint(eyePoint, faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height);
////        eyePoint = VNImagePointForNormalizedPoint(eyePoint, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//
////        VNImagePointForFaceLandmarkPoint(eye.normalizedPoints, screenBoundingBox, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//
//        newEyePoints[i] = eyePoint;
//        [newEyePointsArray addObject:[NSValue valueWithCGPoint:eyePoint]];
//    }
    
    
//    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -1);
//    CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(CGRectApplyAffineTransform(screenBoundingBox, transform), self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//    const CGPoint *pointsInImage = [eye pointsInImageOfSize:faceBoundingBoxOnScreen.size];
    const CGPoint *pointsInImage = [eye pointsInImageOfSize:CGSizeMake(self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height)];
    for (int i = 0; i < eye.pointCount; i++) {
        CGPoint eyePoint = pointsInImage[i];
//        eyePoint.x = eyePoint.y * screenBoundingBox.size.height + screenBoundingBox.origin.x;
//        eyePoint.y = eyePoint.x * screenBoundingBox.size.width + screenBoundingBox.origin.y;

//        eyePoint.x = eyePoint.x * screenBoundingBox.size.width + screenBoundingBox.origin.x;
//        eyePoint.y = -eyePoint.y * screenBoundingBox.size.height + screenBoundingBox.origin.y;
//        CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(screenBoundingBox, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);

        CGFloat scaleX = self.filterView.layer.frame.size.width / size.width;
        CGFloat scaleY = self.filterView.layer.frame.size.height / size.height;
        
        CGAffineTransform scale = CGAffineTransformMakeScale(self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -self.filterView.layer.frame.size.height);
        CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scaleX, -scaleY), 0, -size.height);
        
//        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -1);

//        let scale = CGAffineTransform.identity.scaledBy(x: viewRect.width, y: viewRect.height)
//            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)

        CGRect faceBoundingBoxOnScreen = VNImageRectForNormalizedRect(CGRectApplyAffineTransform(screenBoundingBox, transform), self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);

        eyePoint = CGPointApplyAffineTransform(eyePoint, transform);
//        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);
//        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), screenBoundingBox.size.width, screenBoundingBox.size.height);
//        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height);
//        eyePoint = CGPointApplyAffineTransform(VNImagePointForNormalizedPoint(eyePoint, faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height), transform);

//        eyePoint = CGPointApplyAffineTransform(VNImagePointForNormalizedPoint(eyePoint, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height), transform);

//        eyePoint = VNImagePointForNormalizedPoint(CGPointApplyAffineTransform(eyePoint, transform), faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height);

//        eyePoint = VNImagePointForNormalizedPoint(eyePoint, faceBoundingBoxOnScreen.size.width, faceBoundingBoxOnScreen.size.height);
//        eyePoint = VNImagePointForNormalizedPoint(eyePoint, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);

//        VNImagePointForFaceLandmarkPoint(eye.normalizedPoints, screenBoundingBox, self.filterView.layer.frame.size.width, self.filterView.layer.frame.size.height);

        newEyePoints[i] = eyePoint;
        [newEyePointsArray addObject:[NSValue valueWithCGPoint:eyePoint]];
    }
    
//    self.stickerFilter.faces = newEyePointsArray;
    
    CGPathAddLines(eyePath, nil, newEyePoints, eye.pointCount);
    CGPathCloseSubpath(eyePath);
    CAShapeLayer *eyeDrawing = [CAShapeLayer layer];
    eyeDrawing.path = eyePath;
    eyeDrawing.fillColor = [UIColor clearColor].CGColor;
    eyeDrawing.strokeColor = [UIColor greenColor].CGColor;
    
    return eyeDrawing;
    
//    let eyePath = CGMutablePath()
//    let eyePathPoints = eye.normalizedPoints
//        .map({ eyePoint in
//            CGPoint(
//                x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
//                y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
//        })
//    eyePath.addLines(between: eyePathPoints)
//    eyePath.closeSubpath()
//    let eyeDrawing = CAShapeLayer()
//    eyeDrawing.path = eyePath
//    eyeDrawing.fillColor = UIColor.clear.cgColor
//    eyeDrawing.strokeColor = UIColor.green.cgColor
//
//    return eyeDrawing
}

@end
