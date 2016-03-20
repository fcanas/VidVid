//
//  VVDecoder.m
//  VidVid
//
//  Created by Fabian Canas on 3/18/16.
//  Copyright © 2016 Fabián Cañas. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <VideoToolbox/VideoToolbox.h>

#import "VVDecoder.h"

@interface VVDecoder ()
@property (nonatomic, strong) __attribute__((NSObject)) VTDecompressionSessionRef decompressionSession;
- (void)decompressedFrame:(CVImageBufferRef)imageBuffer atTime:(CMTime)presentationTimeStamp;
@end

void VVDecoderVTDecompressionCallback(void * CM_NULLABLE decompressionOutputRefCon,
                                      void * CM_NULLABLE sourceFrameRefCon,
                                      OSStatus status,
                                      VTDecodeInfoFlags infoFlags,
                                      CM_NULLABLE CVImageBufferRef imageBuffer,
                                      CMTime presentationTimeStamp, 
                                      CMTime presentationDuration )
{
    if (decompressionOutputRefCon == NULL) {
        return;
    }
    
    VVDecoder *decoder = (__bridge VVDecoder *)(decompressionOutputRefCon);
    
    [decoder decompressedFrame:imageBuffer atTime:presentationTimeStamp];
}

@implementation VVDecoder

- (instancetype)init
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    CMVideoFormatDescriptionRef videoFormatDescription;
    OSStatus status = CMVideoFormatDescriptionCreate(NULL,
                                                     kCMVideoCodecType_H264,
                                                     480,
                                                     480,
                                                     NULL,
                                                     &videoFormatDescription);
    
    if (status != noErr) {
        return nil;
    }
    
    VTDecompressionOutputCallbackRecord callbackRecord = { .decompressionOutputCallback = &VVDecoderVTDecompressionCallback, (__bridge void * _Nullable)(self) };
    
    VTDecompressionSessionCreate(NULL,
                                 videoFormatDescription,
                                 NULL,
                                 NULL,
                                 &callbackRecord,
                                 &_decompressionSession);
    
    CFRelease(videoFormatDescription);
    
    return self;
}

- (void)decompressedFrame:(CVImageBufferRef)imageBuffer atTime:(CMTime)presentationTimeStamp
{
    CGSize decodedFrameSize = CVImageBufferGetEncodedSize(imageBuffer);
    NSLog(@"Decoded %@x%@ frame at %@s", @(decodedFrameSize.width), @(decodedFrameSize.height), @(CMTimeGetSeconds(presentationTimeStamp)));
}

- (void)debug
{
    VTDecompressionSessionInvalidate(_decompressionSession);
}

@end
