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


-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    char text[50];
    
    switch (self.processType) {
        case 1:
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"xml"];
            self.faceClassifier = cv::CascadeClassifier([filePath UTF8String]);
            
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
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"eye" ofType:@"xml"];
            self.eyesClassifier = cv::CascadeClassifier([filePath UTF8String]);
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
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Mouth" ofType:@"xml"];
            self.mouthClassifier = cv::CascadeClassifier([filePath UTF8String]);
            int minNeighbors = 5;
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.mouthClassifier.detectMultiScale(image_copy, objects, minNeighbors);
            
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
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lefteye" ofType:@"xml"];
            self.leftEyesClassifier = cv::CascadeClassifier([filePath UTF8String]);
            
            NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"righteye" ofType:@"xml"];
            self.rightEyesClassifier = cv::CascadeClassifier([filePath2 UTF8String]);
            
            NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"eye" ofType:@"xml"];
            self.eyesClassifier = cv::CascadeClassifier([filePath3 UTF8String]);
            
            int minNeighbors = 4;
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> re;
            vector<cv::Rect> le;
            vector<cv::Rect> e;
            char text[50];
            
            // run classifier
            // error if this is not set!
            self.leftEyesClassifier.detectMultiScale(image_copy, le, minNeighbors);
            self.rightEyesClassifier.detectMultiScale(image_copy, re, minNeighbors);
            self.eyesClassifier.detectMultiScale(image_copy, e, minNeighbors);
            
            if (re.size() > 0 && e.size() < 2){
                sprintf(text,"left eye blinking");
                cv::putText(image, text, cv::Point(60, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
            }
            else if (le.size() > 0 && e.size() < 2){
                sprintf(text,"right eye blinking");
                cv::putText(image, text, cv::Point(120, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
            }
            
            else if (e.size() == 0){
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

@end

