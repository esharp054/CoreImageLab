//
//  OpenCVBridgeSub.m
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridgeSubClass.h"

#import "AVFoundation/AVFoundation.h"

#define ARRAY_SIZE 100


using namespace cv;

@interface OpenCVBridgeSubClass()
@property (nonatomic) cv::Mat image;
@property (nonatomic) float* avgBlue;
@property (nonatomic) float* avgRed;
@property (nonatomic) float* avgGreen;
@property (nonatomic) int counter;
@property (nonatomic) bool displayText;
@property (nonatomic) bool cameraCover;
@end

@implementation OpenCVBridgeSubClass
@dynamic image;
//@dynamic just tells the compiler that the getter and setter methods are implemented not by the class itself but somewhere else (like the superclass or will be provided at runtime).

-(float*) avgBlue {
    if(!_avgBlue){
        _avgBlue = (float*)malloc(sizeof(float)*ARRAY_SIZE);
    }

    return _avgBlue;
}
-(float*) avgRed {
    if(!_avgRed){
        _avgRed = (float*)malloc(sizeof(float)*ARRAY_SIZE);
    }
    
    return _avgRed;
}
-(float*) avgGreen {
    if(!_avgGreen){
        _avgGreen = (float*)malloc(sizeof(float)*ARRAY_SIZE);
    }
    
    return _avgGreen;
}
-(void) dealloc {
    free(self.avgBlue);
    free(self.avgRed);
    free(self.avgGreen);
}

-(int) counter {
    if(!_counter){
        _counter = 0;
    }
    
    return _counter;
}

-(bool) displayText {
    if(!_displayText){
        _displayText = false;
    }
    
    return _displayText;
}
-(bool) cameraCover {
    if(!_cameraCover){
        _cameraCover = false;
    }
    
    return _cameraCover;
}

-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
//    float* avgBlue = (float*)malloc(sizeof(float)*ARRAY_SIZE);
//    float* avgRed = (float*)malloc(sizeof(float)*ARRAY_SIZE);
//    float* avgGreen = (float*)malloc(sizeof(float)*ARRAY_SIZE);
//    int counter = 0;
//    bool displayText = false;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    sprintf(text,"Avg. B: %.0f, G: %.0f, R: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
    cv::putText(image, text, cv::Point(60, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    if( avgPixelIntensity.val[2] < 22){ // If covered
        self.cameraCover = true;
        self.avgGreen[self.counter] = avgPixelIntensity.val[1];
        self.avgBlue[self.counter] = avgPixelIntensity.val[0];
        self.avgRed[self.counter] = avgPixelIntensity.val[2];
        self.counter++;
        if(self.counter >= 100){
            self.displayText = true;
            self.counter = 0;
        }
        if(self.displayText){
            NSLog(@"Buffer is full/n");
        }
    }else{
        self.cameraCover = false;
    }

    self.image = image;
    
}

@end

