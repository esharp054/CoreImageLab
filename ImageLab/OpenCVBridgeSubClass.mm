//
//  OpenCVBridgeSub.m
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridgeSubClass.h"

#import "AVFoundation/AVFoundation.h"

#define ARRAY_SIZE 150


using namespace cv;

@interface OpenCVBridgeSubClass()
@property (nonatomic) cv::Mat image;
@property (nonatomic) float* avgBlue;
@property (nonatomic) float* avgRed;
@property (nonatomic) float* avgGreen;
@property (nonatomic) int counter;
@property (nonatomic) float bpm;
@property (nonatomic) double timeInterval;
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

-(float)bpm{
    if(!_bpm){
        _bpm = 0.0;
    }
    return _bpm;
}

-(double)timeInterval{
    if(!_timeInterval){
        _timeInterval = 0.0;
    }
    return _timeInterval;
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
    
    // Calculate how much time each frame represents
    
    // Keep adding time while the array is being filled
    static NSDate *currentTime = [NSDate date];
    static double timeSum = 0.0;
    NSTimeInterval tempTimeInterval = [currentTime timeIntervalSinceNow];
    currentTime = [NSDate date];
    timeSum += -tempTimeInterval;
    
//     Only when avgRed array is full, set timePerFrame
    if(self.counter == ARRAY_SIZE - 1){
        self.timeInterval = timeSum;
        timeSum = 0.0;
    }
    
    // Get timing information for bpm
    // FPS = 120, Frames = 150 (due to this being Array Size, this is how many Frames we are looking at)
    
    
    cv::Mat frame_gray,image_copy;
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    sprintf(text,"Avg. B: %.0f, G: %.0f, R: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
    cv::putText(image, text, cv::Point(60, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    
    // Get sample of data when camera is covered for analysis
    if( avgPixelIntensity.val[2] < 30){ // If covered
        // Display bpm if set
        if(self.bpm != 0.0){
            sprintf(text,"BPM: %.0f", self.bpm);
            cv::putText(image, text, cv::Point(60, 130), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
        }
        self.cameraCover = true;
        
        if(self.counter < ARRAY_SIZE){
            self.avgGreen[self.counter] = avgPixelIntensity.val[1];
            self.avgBlue[self.counter] = avgPixelIntensity.val[0];
            self.avgRed[self.counter] = avgPixelIntensity.val[2];
            self.counter++;
            if(self.counter >= ARRAY_SIZE){
                NSLog(@"Buffer is full/n");
                [self calculateBPM];
            }
        }
    }
    else{
        self.cameraCover = false;
    }

    self.image = image;
    
}

-(void) calculateBPM {
    
    // Find out how many time intervals fit in 60 seconds
    float perMinute = 60 / self.timeInterval;

    //If array is full, analyze current data and reset counter
    if (self.counter >= ARRAY_SIZE) {
        
        // Find all maximums
        NSMutableArray *localMax = [[NSMutableArray alloc] init];
        for (int i = 1; i < ARRAY_SIZE; i++){
            //Check if current point is a maximum
            if(self.avgRed[i] > self.avgRed[i-1] && self.avgRed[i] > self.avgRed[i+1])
                // add to peaks array
                [localMax addObject:[NSNumber numberWithInt:i]];
        }
        
        NSUInteger numBeats = localMax.count;
        self.bpm = (float)numBeats * perMinute;
        NSLog(@"TimeInterval:  %f    NumBeats: %d    BPM: %f", self.timeInterval, (int) numBeats, self.bpm);
        
        self.counter = 0;
    }
    
}

@end

