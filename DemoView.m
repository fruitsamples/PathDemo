/*
 DemoView.m
 PathDemo

 Author: Nick Kocharhook (the Cocoa portion)
         Other CG engineers
 Created 11 July 2003

 Copyright (c) 2003, Apple Computer, Inc., all rights reserved.
*/

/*
 IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in
 consideration of your agreement to the following terms, and your use, installation,
 modification or redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject to these
 terms, Apple grants you a personal, non-exclusive license, under Apple's copyrights in
 this original Apple software (the "Apple Software"), to use, reproduce, modify and
 redistribute the Apple Software, with or without modifications, in source and/or binary
 forms; provided that if you redistribute the Apple Software in its entirety and without
 modifications, you must retain this notice and the following text and disclaimers in all
 such redistributions of the Apple Software.  Neither the name, trademarks, service marks
 or logos of Apple Computer, Inc. may be used to endorse or promote products derived from
 the Apple Software without specific prior written permission from Apple. Except as expressly
 stated in this notice, no other rights or licenses, express or implied, are granted by Apple
 herein, including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES,
 EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT,
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS
 USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE,
 REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND
 WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR
 OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "DemoView.h"
#include <ApplicationServices/ApplicationServices.h>

#define PI 3.14159265358979323846

@interface DemoView (Private)

CGRect convertToCGRect(NSRect inRect);

@end

@implementation DemoView

void rectangles(CGContextRef gc, NSRect rect);
void circles(CGContextRef gc, NSRect rect);
void bezierPaths(CGContextRef gc, NSRect rect);
void circleClipping(CGContextRef gc, NSRect rect);

void drawRandomPaths(CGContextRef context, int w, int h);

- (id)initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];
	return self;
}

- (void)drawRect:(NSRect)rect
{
    CGContextRef gc = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSetGrayFillColor(gc, 1.0, 1.0);
    CGContextFillRect(gc, convertToCGRect(rect));
    
    switch (num) {
        case 0:
            rectangles(gc, rect);
            break;
        case 1:
            circles(gc, rect);
            break;
        case 2:
            bezierPaths(gc, rect);
            break;
        case 3:
            circleClipping(gc, rect);
            break;
        default:
            NSLog(@"Invalid item");
    }
}

- (void)setDemoNumber:(int)newNum
{
    num = newNum;
}

/*
 * The various demo functions
 */

void rectangles(CGContextRef gc, NSRect rect)
{
    int i;
    int w = rect.size.width;
    int h = rect.size.height;

    // Draw random rectangles (some stroked some filled)
    for (i = 0; i < 20; i++) {
        if(i % 2) {
            CGContextSetRGBFillColor(gc, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255);
            CGContextFillRect(gc, CGRectMake(rand()%w, rand()%h, rand()%w, rand()%h));
        }
        else {
            CGContextSetLineWidth(gc, (rand()%10)+2);
            CGContextSetRGBStrokeColor(gc, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255);
            CGContextStrokeRect(gc, CGRectMake(rand()%w, rand()%h, rand()%w, rand()%h));
        }
    }
}

void circles(CGContextRef gc, NSRect rect)
{
    int i;
    int w = rect.size.width;
    int h = rect.size.height;

    // Draw random circles (some stroked, some filled)
    for (i = 0; i < 20; i++) {
        CGContextBeginPath(gc);
        CGContextAddArc(gc, rand()%w, rand()%h, rand()%((w>h) ? h : w), 0, 2*PI, 0);
        CGContextClosePath(gc);

        if(i % 2) {
            CGContextSetRGBFillColor(gc, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255);
            CGContextFillPath(gc);
        }
        else {
            CGContextSetLineWidth(gc, (rand()%10)+2);
            CGContextSetRGBStrokeColor(gc, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255);
            CGContextStrokePath(gc);
        }
    }
}

void bezierPaths(CGContextRef gc, NSRect rect)
{
    int w = rect.size.width;
    int h = rect.size.height;
    
    drawRandomPaths(gc, w, h);
}

void circleClipping(CGContextRef gc, NSRect rect)
{
    int w = rect.size.width;
    int h = rect.size.height;

    // Clipping example - draw a random path through a circular clip
    CGContextBeginPath(gc);
    CGContextAddArc(gc, w/2, h/2, ((w>h) ? h : w)/2, 0, 2*PI, 0);
    CGContextClosePath(gc);
    CGContextClip(gc);
    
    // Draw something into the clip
    drawRandomPaths(gc, w, h);
    
    // Draw a clip path on top as a black stroked circle
    CGContextBeginPath(gc);
    CGContextAddArc(gc, w/2, h/2, ((w>h) ? h : w)/2, 0, 2*PI, 0);
    CGContextClosePath(gc);
    CGContextSetLineWidth(gc, 1);
    CGContextSetRGBStrokeColor(gc, 0, 0, 0, 1);
    CGContextStrokePath(gc);
}

void drawRandomPaths(CGContextRef context, int w, int h)
{
    int i;
    
    for (i = 0; i < 20; i++) {
        int numberOfSegments = rand() % 8;
        int j;
        float sx = rand() % w;
        float sy = rand() % h;
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, rand()%w, rand()%h);
        for (j = 0; j < numberOfSegments; j++) {
            if (j % 2) {
                CGContextAddLineToPoint(context, rand()%w, rand()%h);
            }
            else {
                CGContextAddCurveToPoint(context, rand()%w, rand()%h,  
                    rand()%w, rand()%h,  rand()%h, rand()%h);
            }
        }
        if(i % 2) {
            CGContextAddCurveToPoint(context, rand()%w, rand()%h,
                    rand()%w, rand()%h,  sx, sy);
            CGContextClosePath(context);
            CGContextSetRGBFillColor(context, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255);
            CGContextFillPath(context);
        }
        else {
            CGContextSetLineWidth(context, (rand()%10)+2);
            CGContextSetRGBStrokeColor(context, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255, (float)(rand()%256)/255, 
                    (float)(rand()%256)/255);
            CGContextStrokePath(context);
        }
    }
}

// A convenience function to get a CGRect from an NSRect. You can also use the
// *(CGRect *)&nsRect sleight of hand, but this way is a bit clearer.
CGRect convertToCGRect(NSRect inRect)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height);
}

@end
