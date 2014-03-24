/*
     File: RosyWriterVideoProcessor.m
 Abstract: The class that creates and manages the AV capture session and asset writer
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (c) 2012 yong wang. All rights reserved.
 
 */

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraVideoProcessor.h"
#include "sys/stat.h"

#define INBUF_SIZE 4096
#define AUDIO_INBUF_SIZE 20480
#define AUDIO_REFILL_THRESH 4096

#define BYTES_PER_PIXEL 3

@interface CameraVideoProcessor ()

// Redeclared as readwrite so that we can write to the property and still be atomic with external readers.
@property (readwrite) Float64 videoFrameRate;
@property (readwrite) CMVideoDimensions videoDimensions;
@property (readwrite) CMVideoCodecType videoType;
@property (readwrite) size_t videoSize;

@property (readwrite, getter=isRecording) BOOL recording;

@end

@implementation CameraVideoProcessor

@synthesize delegate;
@synthesize videoFrameRate, videoDimensions, videoType, videoSize;
@synthesize videoOrientation;
@synthesize recording;
@synthesize movieURL;
@synthesize segmentationTimer;
@synthesize movieURLs;
@synthesize ffEncoder;
@synthesize appleEncoder1, appleEncoder2;



- (id) init
{
    if (self = [super init]) {
        previousSecondTimestamps = [[NSMutableArray alloc] init];
        self.movieURL = [self newMovieURL];
        self.movieURLs = [NSMutableArray array];
        [movieURLs addObject:movieURL];
        self.ffEncoder = [[FFEncoder alloc] init];
    }
    return self;
}


- (NSURL*) newMovieURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *movieName = [NSString stringWithFormat:@"%f.mp4",[[NSDate date] timeIntervalSince1970]];
    NSURL *newMovieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", basePath, movieName]];
    NSLog(@"newMovieURL      %@",[newMovieURL absoluteString]);
    return newMovieURL;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = 0.0;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI_2;
			break;
		default:
			break;
	}
    
	return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	// Calculate offsets from an arbitrary reference orientation (portrait)
	CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
	CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
	
	// Find the difference in angle between the passed in orientation and the current video orientation
	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
	transform = CGAffineTransformMakeRotation(angleOffset);
	
	return transform;
}

#pragma mark Utilities

- (void) calculateFramerateAtTimestamp:(CMTime) timestamp
{
    //get FPS per sec
	[previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
    
	CMTime oneSecond = CMTimeMake( 1, 1 );
	CMTime oneSecondAgo = CMTimeSubtract( timestamp, oneSecond );
    
	while( CMTIME_COMPARE_INLINE( [[previousSecondTimestamps objectAtIndex:0] CMTimeValue], <, oneSecondAgo ) )
		[previousSecondTimestamps removeObjectAtIndex:0];
    
	Float64 newRate = (Float64) [previousSecondTimestamps count];
	self.videoFrameRate = (self.videoFrameRate + newRate) / 2;
}

- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
		if (!success)
			[self showError:error];
    }
}



#pragma mark Recording







- (void) startRecording
{
	dispatch_async(movieWritingQueue, ^{
	
		if ( recordingWillBeStarted || self.recording )
			return;

		recordingWillBeStarted = YES;

		// recordingDidStart is called from captureOutput:didOutputSampleBuffer:fromConnection: once the asset writer is setup
		[self.delegate recordingWillStart];
			
        [self initializeAssetWriters];
	});


}

- (void) initializeAssetWriters {
    // Create an asset writer
    self.appleEncoder1 = [[AVAppleEncoder alloc] initWithURL:[self newMovieURL]];
    self.appleEncoder2 = [[AVSegmentingAppleEncoder alloc] initWithURL:[self newMovieURL] segmentationInterval:5.0f];
}

/*- (long long) fileSizeAtPath:(NSString*) filePath{  
    struct stat st;  
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){  
        return st.st_size;  
    }  
    return 0;  
}  */

- (long long) fileSizeAtPath:(NSString*) filePath{  
    NSFileManager* manager = [NSFileManager defaultManager];  
    if ([manager fileExistsAtPath:filePath]){  
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];  
    }  
    return 0;  
}  

- (void) stopRecording
{
    /*
    dispatch_async(ffmpegWritingQueue, ^{
        [self.ffEncoder.videoEncoder finishEncoding];
        [self.ffEncoder.audioEncoder finishEncoding];
    });
     */
	dispatch_async(movieWritingQueue, ^{
		if ( recordingWillBeStopped || self.recording == NO)
			return;
		
		recordingWillBeStopped = YES;
		
		// recordingDidStop is called from saveMovieToCameraRoll
		[self.delegate recordingWillStop];
        [appleEncoder1 finishEncoding];
        [appleEncoder2 finishEncoding];
        recordingWillBeStopped = NO;
        self.recording = NO;
        
        videoSize = [self fileSizeAtPath:[self.movieURL absoluteString]];
        NSLog(@"%@",[self.movieURL absoluteString]);
        
        [self.delegate recordingDidStop];
        [self clearMovieURLs];
        self.movieURL = [self newMovieURL];
        [self initializeAssetWriters];
	});
    [self.segmentationTimer invalidate];
    self.segmentationTimer = nil;
}

- (void) clearMovieURLs {
    // TODO: write out movie file names to file
    self.movieURLs = [NSMutableArray array];
}

#pragma mark Processing

- (void)processPixelBuffer: (CVImageBufferRef)pixelBuffer
{
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0); 
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    UIImage *coverImage = [UIImage imageNamed:@"psb.jpg"];
    int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);  
    int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);  
    int bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);  
    
    unsigned char * frameBaseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);  
    CGContextRef context = CGBitmapContextCreate(frameBaseAddress, bufferWidth, bufferHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);  
    CGContextDrawImage(context, CGRectMake (30, 380, 30, 30), coverImage.CGImage); //和图片进行合成.  
//  char* text = "SYAAAAA";//(char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
//  CGContextSelectFont(context, "Georgia", 30, kCGEncodingFontSpecific);
//  CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 255, 0, 0, 1);
//  CGContextShowTextAtPoint(context, 66, 380, text, strlen(text));
    
    UIGraphicsPushContext(context); 
    //CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES);
    [@"水印" drawAtPoint:CGPointMake(66, 380) withFont:[UIFont systemFontOfSize:34]];
    UIGraphicsPopContext();
    CGContextRelease(context); 

    
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    CGColorSpaceRelease(colorSpace);
    return;
//    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
//	
//	int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
//	int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
//	unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
//    int wOff = 0;
//	int pixOff = 0;
//	for( int row = 0; row < bufferHeight; row++ ) {	
//        pixOff = wOff;
//		for( int column = 0; column < bufferWidth; column++ ) {
//            
//            int red = (unsigned char)pixel[pixOff];
//			int green = (unsigned char)pixel[pixOff+1];
//			int blue = (unsigned char)pixel[pixOff+2];
//            int alpha = (unsigned char)pixel[pixOff+3];
//            //changeRGBA(&red, &green, &blue, &alpha, colormatrix_heibai);
//            
//            //回写数据
//			pixel[pixOff] = red;
//			pixel[pixOff+1] = green;
//			pixel[pixOff+2] = blue;
//            pixel[pixOff+3] = alpha;
//            
//			
//			pixOff += 4; //将数组的索引指向下四个元素
//		}
//        
//		wOff += row * 4;
//	}
//	
//	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );

}

static void changeRGBA(int *red,int *green,int *blue,int *alpha, const float* f)//修改RGB的值
{
    int redV = *red;
    int greenV = *green;
    int blueV = *blue;
    int alphaV = *alpha;
    
    *red = f[0] * redV + f[1] * greenV + f[2] * blueV + f[3] * alphaV + f[4];
    *green = f[0+5] * redV + f[1+5] * greenV + f[2+5] * blueV + f[3+5] * alphaV + f[4+5];
    *blue = f[0+5*2] * redV + f[1+5*2] * greenV + f[2+5*2] * blueV + f[3+5*2] * alphaV + f[4+5*2];
    *alpha = f[0+5*3] * redV + f[1+5*3] * greenV + f[2+5*3] * blueV + f[3+5*3] * alphaV + f[4+5*3];
    
    if (*red > 255) 
    {
        *red = 255;
    }
    if(*red < 0)
    {
        *red = 0;
    }
    if (*green > 255) 
    {
        *green = 255;
    }
    if (*green < 0) 
    {
        *green = 0;
    }
    if (*blue > 255) 
    {
        *blue = 255;
    }
    if (*blue < 0) 
    {
        *blue = 0;
    }
    if (*alpha > 255) 
    {
        *alpha = 255;
    }
    if (*alpha < 0) 
    {
        *alpha = 0;
    }
}

#pragma mark Capture
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection 
{	
   
	CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
	if ( connection == videoConnection ) {
	
		// Get framerate
		CMTime timestamp = CMSampleBufferGetPresentationTimeStamp( sampleBuffer );
		[self calculateFramerateAtTimestamp:timestamp];
        
		// Get frame dimensions (for onscreen display)
		if (self.videoDimensions.width == 0 && self.videoDimensions.height == 0)
			self.videoDimensions = CMVideoFormatDescriptionGetDimensions( formatDescription );
		
		// Get buffer type
		if ( self.videoType == 0 )
			self.videoType = CMFormatDescriptionGetMediaSubType( formatDescription );

		CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
		[self processPixelBuffer:pixelBuffer];

		// Enqueue it for preview.  This is a shallow queue, so if image processing is taking too long,
		// we'll drop this frame for preview (this keeps preview latency low).
		OSStatus err = CMBufferQueueEnqueue(previewBufferQueue, sampleBuffer);
		if ( !err ) {        
			dispatch_async(dispatch_get_main_queue(), ^{
				CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
   
				if (sbuf) {
            
                    size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
                    self.videoSize = buffeSize;
                    //UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
					CVImageBufferRef pixBuf = CMSampleBufferGetImageBuffer(sbuf);
                    
                    
                    UIImage* image = [self imageFromSampleBuffer:sampleBuffer];
                    [self.delegate pixelBufferReadyForDisplay:pixBuf];
                    if([image isKindOfClass:[UIImage class]])
                    {
                        [self.delegate imageBufferReadyForDisplay:image];
                    }
                    
					CFRelease(sbuf);
				}
			});
		}
	}
    //
    CFRetain(sampleBuffer);
	CFRetain(formatDescription);
    //CFRetain(formatDescription);

    
	dispatch_async(movieWritingQueue, ^{
		if ( appleEncoder1 && (self.recording || recordingWillBeStarted)) {
		
			BOOL wasReadyToRecord = (appleEncoder1.readyToRecordAudio && appleEncoder1.readyToRecordVideo);
			
			if (connection == videoConnection) {
				
				// Initialize the video input if this is not done yet
				if (!appleEncoder1.readyToRecordVideo) {
					[appleEncoder1 setupVideoEncoderWithFormatDescription:formatDescription];
                }
				
				// Write video data to file
				if (appleEncoder1.readyToRecordVideo && appleEncoder1.readyToRecordAudio) {
					[appleEncoder1 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                }
			}
			else if (connection == audioConnection) {
				
				// Initialize the audio input if this is not done yet
				if (!appleEncoder1.readyToRecordAudio) {
                    [appleEncoder1 setupAudioEncoderWithFormatDescription:formatDescription];
                }
				
				// Write audio data to file
				if (appleEncoder1.readyToRecordAudio && appleEncoder1.readyToRecordVideo)
					[appleEncoder1 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
			}
			
			BOOL isReadyToRecord = (appleEncoder1.readyToRecordAudio && appleEncoder1.readyToRecordVideo);
			if ( !wasReadyToRecord && isReadyToRecord ) {
				recordingWillBeStarted = NO;
				self.recording = YES;
				[self.delegate recordingDidStart];
			}
		}
        if ( appleEncoder2 && (self.recording || recordingWillBeStarted)) {
            
			BOOL wasReadyToRecord = (appleEncoder2.readyToRecordAudio && appleEncoder2.readyToRecordVideo);
			
			if (connection == videoConnection) {
				
				// Initialize the video input if this is not done yet
				if (!appleEncoder2.readyToRecordVideo) {
					[appleEncoder2 setupVideoEncoderWithFormatDescription:formatDescription bitsPerSecond:8000];
                }
				
				// Write video data to file
				if (appleEncoder2.readyToRecordVideo && appleEncoder2.readyToRecordAudio) {
					[appleEncoder2 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                }
			}
			else if (connection == audioConnection) {
				
				// Initialize the audio input if this is not done yet
				if (!appleEncoder2.readyToRecordAudio) {
                    [appleEncoder2 setupAudioEncoderWithFormatDescription:formatDescription];
                }
				
				// Write audio data to file
				if (appleEncoder2.readyToRecordAudio && appleEncoder2.readyToRecordVideo)
					[appleEncoder2 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
			}
			
			BOOL isReadyToRecord = (appleEncoder2.readyToRecordAudio && appleEncoder2.readyToRecordVideo);
			if ( !wasReadyToRecord && isReadyToRecord ) {
				recordingWillBeStarted = NO;
				self.recording = YES;
				[self.delegate recordingDidStart];
			}
		}
		CFRelease(sampleBuffer);
		CFRelease(formatDescription);
	});
    
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    size_t pixWidth = CGImageGetWidth(image);
    size_t pixHeight = CGImageGetHeight(image);
    CVPixelBufferRef pxbuffer = NULL;
    
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI_2);
    

    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, pixWidth,
                                          pixHeight, kCVPixelFormatType_32ARGB, (__bridge  CFDictionaryRef) options, 
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, pixWidth,
                                                pixHeight, 8, 4*pixWidth, rgbColorSpace, 
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, rotation);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), 
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [[UIImage alloc] initWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return image;
}

- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position 
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    
    return nil;
}

- (AVCaptureDevice *)audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0)
        return [devices objectAtIndex:0];
    
    return nil;
}

- (BOOL) setupCaptureSession 
{
	/*
		Overview: RosyWriter uses separate GCD queues for audio and video capture.  If a single GCD queue
		is used to deliver both audio and video buffers, and our video processing consistently takes
		too long, the delivery queue can back up, resulting in audio being dropped.
		
		When recording, RosyWriter creates a third GCD queue for calls to AVAssetWriter.  This ensures
		that AVAssetWriter is not called to start or finish writing from multiple threads simultaneously.
		
		RosyWriter uses AVCaptureSession's default preset, AVCaptureSessionPresetHigh.
	 */
	 
    /*
	 * Create capture session
	 */
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    /*
	 * Create audio connection
	 */
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    if ([captureSession canAddInput:audioIn])
        [captureSession addInput:audioIn];
	
	AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
	dispatch_release(audioCaptureQueue);
	if ([captureSession canAddOutput:audioOut])
		[captureSession addOutput:audioOut];
	audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
	/*
	 * Create video connection
	 */
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];

    if ([captureSession canAddInput:videoIn])
        [captureSession addInput:videoIn];
    
    videoOut = [[AVCaptureVideoDataOutput alloc] init];
    
	/*
		RosyWriter prefers to discard late video frames early in the capture pipeline, since its
		processing can take longer than real-time on some platforms (such as iPhone 3GS).
		Clients whose image processing is faster than real-time should consider setting AVCaptureVideoDataOutput's
		alwaysDiscardsLateVideoFrames property to NO. 
	 */
	[videoOut setAlwaysDiscardsLateVideoFrames:YES];
    // mark: discard if the data output queue is blocked (as we process the still image)
 
    
    //mark ios  420v 420f BGRA
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(__bridge  id)kCVPixelBufferPixelFormatTypeKey]];
	dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
	dispatch_release(videoCaptureQueue);
	if ([captureSession canAddOutput:videoOut])
		[captureSession addOutput:videoOut];
	videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
	self.videoOrientation = [videoConnection videoOrientation];
    
	return YES;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}


#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (void)swapFrontAndBackCameras {
    
    // Assume the session is already running

    NSArray *inputs = captureSession.inputs;

    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self backFacingCamera];
            else
                newCamera = [self frontFacingCamera];
            

            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [captureSession beginConfiguration];
            [captureSession removeInput:input];
            [captureSession addInput:newInput];
            // Changes take effect once the outermost commitConfiguration is invoked.
            [captureSession commitConfiguration];
            break;
        }
    } 
    
    for(AVCaptureConnection *connection in videoOut.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if([[port mediaType] isEqualToString:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
       
    }
}


#pragma mark Device Counts
// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (NSUInteger) micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}


- (void) setupAndStartCaptureSession
{
	// Create a shallow queue for buffers going to the display for preview.
	OSStatus err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
	if (err)
		[self showError:[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]];
    err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &ffmpegBufferQueue);
	if (err)
		[self showError:[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]];
    
	// Create serial queue for movie writing
	movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
	ffmpegWritingQueue = dispatch_queue_create("FFmpeg Writing Queue", DISPATCH_QUEUE_SERIAL);
    
    if ( !captureSession )
		[self setupCaptureSession];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionStoppedRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	
	if ( !captureSession.isRunning )
		[captureSession startRunning];
}

- (void) pauseCaptureSession
{
	if ( captureSession.isRunning )
		[captureSession stopRunning];
}

- (void) setRecoredPause
{
    
}

- (void) resumeCaptureSession
{
	if ( !captureSession.isRunning )
		[captureSession startRunning];
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
	dispatch_async(movieWritingQueue, ^{
		if ( [self isRecording] ) {
			[self stopRecording];
		}
	});
}

- (void) stopAndTearDownCaptureSession
{
    [captureSession stopRunning];
	if (captureSession)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	captureSession = nil;
	if (previewBufferQueue) {
		CFRelease(previewBufferQueue);
		previewBufferQueue = NULL;	
	}
    if (ffmpegBufferQueue) {
		CFRelease(ffmpegBufferQueue);
		ffmpegBufferQueue = NULL;
	}
	if (movieWritingQueue) {
		dispatch_release(movieWritingQueue);
		movieWritingQueue = NULL;
	}
    if (ffmpegWritingQueue) {
		dispatch_release(ffmpegWritingQueue);
		ffmpegWritingQueue = NULL;
	}
}

- (void)showError:(NSError *)error
{
    NSLog(@"Error: %@%@",[error localizedDescription], [error userInfo]);
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

@end
