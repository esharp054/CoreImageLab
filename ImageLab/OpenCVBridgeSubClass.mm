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
@property (nonatomic) bool displayText;
@property (nonatomic) bool cameraCover;
@property (nonatomic) float bpm;
@property (nonatomic) double timeInterval;
@property (atomic) cv::CascadeClassifier faceClassifier;
@property (atomic) cv::CascadeClassifier eyesClassifier;
@property (atomic) cv::CascadeClassifier leftEyesClassifier;
@property (atomic) cv::CascadeClassifier rightEyesClassifier;
@property (atomic) cv::CascadeClassifier mouthClassifier;
@property (atomic) cv::CascadeClassifier smileClassifier;
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
    
    cv::Mat frame_gray,image_copy;
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"xml"];
    self.faceClassifier = cv::CascadeClassifier([filePath UTF8String]);
    
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"eye" ofType:@"xml"];
    self.eyesClassifier = cv::CascadeClassifier([filePath1 UTF8String]);
    
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"Mouth" ofType:@"xml"];
    self.mouthClassifier = cv::CascadeClassifier([filePath2 UTF8String]);
    
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"lefteye" ofType:@"xml"];
    self.leftEyesClassifier = cv::CascadeClassifier([filePath3 UTF8String]);
    
    NSString *filePath4 = [[NSBundle mainBundle] pathForResource:@"righteye" ofType:@"xml"];
    self.rightEyesClassifier = cv::CascadeClassifier([filePath4 UTF8String]);
    
    NSString *filePath5 = [[NSBundle mainBundle] pathForResource:@"eye" ofType:@"xml"];
    self.eyesClassifier = cv::CascadeClassifier([filePath5 UTF8String]);
    
    
    
    switch (self.processType) {
        
        case 0:
        {
            // Calculate how much time each frame represents
            
            // Keep adding time while the array is being filled
            static NSDate *currentTime = [NSDate date];
            static double timeSum = 0.0;
            NSTimeInterval tempTimeInterval = [currentTime timeIntervalSinceNow];
            currentTime = [NSDate date];
            timeSum += -tempTimeInterval;
            
            //Only when avgRed array is full, set timePerFrame
            if(self.counter == ARRAY_SIZE - 1){
                self.timeInterval = timeSum;
                timeSum = 0.0;
            }
            
            cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
            avgPixelIntensity = cv::mean( image_copy );
            sprintf(text,"Avg. B: %.0f, G: %.0f, R: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
            cv::putText(image, text, cv::Point(60, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
            
            // Get sample of data when camera is covered for analysis
            if( avgPixelIntensity.val[2] < 60){ // If covered
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
            break;
        }
        case 1:
        {
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.faceClassifier.detectMultiScale(image_copy, objects);
            
            // display bounding rectangles around the detected objects
            for( vector<cv::Rect>::const_iterator r = objects.begin(); r != objects.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            //image already in the correct color space
            
            self.image = image;
            break;
        }
        case 2:
        {
        
            int minNeighbors = 3;
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.eyesClassifier.detectMultiScale(image_copy, objects, minNeighbors);
            
            // display bounding rectangles around the detected objects
            for( vector<cv::Rect>::const_iterator r = objects.begin(); r != objects.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            //image already in the correct color space
            self.image = image;
            break;
        }
        case 3:
        {
            int minNeighbors = 5;
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.mouthClassifier.detectMultiScale(image_copy, objects, 3, minNeighbors);
            
            // display bounding rectangles around the detected objects
            for( vector<cv::Rect>::const_iterator r = objects.begin(); r != objects.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            //image already in the correct color space
            self.image = image;
            break;
        }
        case 4:
        {
            
            int minNeighbors = 3;
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> re;
            vector<cv::Rect> le;
            vector<cv::Rect> e;
            char text[50];
            
            // run classifier
            // error if this is not set!
            self.leftEyesClassifier.detectMultiScale(image_copy, le,3, minNeighbors);
            self.rightEyesClassifier.detectMultiScale(image_copy, re,3, minNeighbors);
            self.eyesClassifier.detectMultiScale(image_copy, e, 3,minNeighbors);
            
            if (e.size() == 2){
                sprintf(text,"Both eyes open");
                cv::putText(image, text, cv::Point(60, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
            }
            
            else if (re.size() == 1 && e.size() == 1){
                sprintf(text,"left eye blinking");
                cv::putText(image, text, cv::Point(60, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
            }
            else if (le.size() == 1 && e.size() == 1){
                sprintf(text,"right eye blinking");
                cv::putText(image, text, cv::Point(120, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
            }
            
            else if (e.size() == 0 ){
                sprintf(text,"Both eyes blinking");
                cv::putText(image, text, cv::Point(60, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
            }
            
            for( vector<cv::Rect>::const_iterator r = e.begin(); r != e.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            
            //image already in the correct color space
            self.image = image;
            break;
        }
            
        default:
            break;
    }
    
}

-(void) calculateBPM {
    
//    int window = 5;
    
    // Find out how many time intervals fit in 60 seconds
    float perMinute = (60 / self.timeInterval);
    
    //If array is full, analyze current data and reset cosunter
    if (self.counter >= ARRAY_SIZE) {
        
        // Find all maximums
        NSMutableArray *localMax = [[NSMutableArray alloc] init];
        

        // Counter starts at 0, get the middle value of 7
        for (int i = 2; i < ARRAY_SIZE; i++){
            //Check if current point is a maximum
            if(self.avgRed[i] > self.avgRed[i-1] && self.avgRed[i] > self.avgRed[i-2] && self.avgRed[i] > self.avgRed[i+1] && self.avgRed[i] > self.avgRed[i+1] && self.avgRed[i] > self.avgRed[i+2])
                // add to peaks array
//                [localMax addObject:[NSNumber numberWithFloat:self.avgRed[i]]];
                 [localMax addObject:[NSNumber numberWithInt:i]];
        }
        
        for (int i = 0; i < localMax.count; i++){
            NSLog(@" %d ", [localMax[i] intValue]);
        }
        
        NSUInteger numBeats = localMax.count;
        self.bpm = (float)numBeats * perMinute;
        NSLog(@"TimeInterval:  %f    NumBeats: %d    BPM: %f", self.timeInterval, (int) numBeats, self.bpm);
        
        // Reset counter for next set of data
        self.counter = 0;
    }
    
}

@end

