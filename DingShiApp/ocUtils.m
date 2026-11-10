//
//  ocUtils.m
//  DWKeyboard
//
//  Created by Aliang on 16/6/27.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ocUtils.h"
#import <CoreText/CoreText.h>


@implementation ocUtils

extern const char * gSkAry[];


// 百度翻译时用
+(NSString *)getHZFlashSkary:(int)index
{
    const char * sk = gSkAry[index];
    
    if (sk != 0)
    {
        return [NSString stringWithUTF8String:sk];
    }
    return nil;
}



+(void)showMessage:(NSString *)message
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    //CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, 1, 1);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [label sizeToFit];
    [showview addSubview:label];
    CGSize LabelSize = label.frame.size;
    showview.frame = CGRectMake((window.frame.size.width - LabelSize.width - 20)/2, window.frame.size.height - 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:1.5 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}


// 百度翻译时用
+(NSString *)composeInputModeResult:(id)aObj
{
    NSMutableString *tmpString = [[NSMutableString alloc] initWithString:@""];
    for (NSArray *result in aObj)
    {
        NSDictionary *dic = [result objectAtIndex:0];
        NSString *candidateWord = [[dic allKeys] objectAtIndex:0];
        [tmpString appendString:candidateWord];
    }
    
    return tmpString;
}

+(void) drawWordPath:(NSString*)word
                    :(NSString*)fontName
                    :(UIImageView*) imageView
                    :(NSArray*) skAry
                    :(CFIndex) flashIndex
{
    CGMutablePathRef letters = CGPathCreateMutable();
    CTFontRef font;
    
    if([fontName isEqualToString: @"KaiTi_GB2312_v2"])
        font = CTFontCreateWithName(CFSTR("KaiTi_GB2312_v2"), imageView.frame.size.width, NULL);
    else
        font = CTFontCreateWithName(CFSTR("楷体_GB2312_v2"), imageView.frame.size.width, NULL);
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:word attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CGFloat offset = ((imageView.frame.size.height - imageView.frame.size.width) / 2);

    // for each RUN
    CFIndex aryCount = CFArrayGetCount(runArray);
    NSLog(@"aryCount = %ld", aryCount);
    for (CFIndex runIndex = 0; runIndex < aryCount; runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        CFIndex gCount = CTRunGetGlyphCount(run);
        NSLog(@"gCount = %ld", gCount);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < gCount; runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGFloat y = position.y + offset;
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
                NSLog(@"y = %f", y);
            }
        }
    }

    // 设置画图环境
    {
        UIGraphicsBeginImageContext(imageView.frame.size);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1);                // set sk width
        CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), true);
        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);         // set 线条平滑
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 0.8); // set color rgb f
    }
    
    // 分解成单个笔画
    {
        // 找出最大 Y
        void CGPathGetMaxYCallback(void *info, const CGPathElement *element);
        CGFloat maxY = 0;
        CGPathApply(letters, &maxY, CGPathGetMaxYCallback);        // 找最大Ｙ

        // 分解
        void CGPathEnumerationCallback(void *info, const CGPathElement *element);
        NSMutableArray * pathAry = [NSMutableArray array];
        CGMutablePathRef first = CGPathCreateMutable();
        [pathAry addObject:(__bridge id _Nonnull)(first)];
        void * params[] = {&maxY, (__bridge void * _Nullable)(pathAry)};
        CGPathApply(letters, params, CGPathEnumerationCallback);

        // 画轮廓
        for (CFIndex i = 0; i < [pathAry count]; i++)
        {
            CGMutablePathRef currentPath = (__bridge CGMutablePathRef)([pathAry objectAtIndex:i]);
            CGContextAddPath(UIGraphicsGetCurrentContext(), currentPath);
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext());   // 渲染轮廓
        
        // 画实心笔画
        for (CFIndex i = 0; i <= flashIndex && skAry != nil; i++)
        {
            NSInteger idx = [skAry[i] integerValue] - 1;
            if (idx < pathAry.count) {
                CGMutablePathRef currentPath = (__bridge CGMutablePathRef)([pathAry objectAtIndex:idx]);
                CGContextAddPath(UIGraphicsGetCurrentContext(), currentPath);
            }
        }
        CGContextFillPath(UIGraphicsGetCurrentContext());   // 渲染实心笔画

        // 释放
        for (CFIndex i = 0; i < [pathAry count]; i++)
        {
            CGMutablePathRef currentPath = (__bridge CGMutablePathRef)([pathAry objectAtIndex:i]);
            CGPathRelease(currentPath);
        }
    }
    
    // 得到画图结果
    {
        imageView.image = UIGraphicsGetImageFromCurrentImageContext(); // 取出图片
        UIGraphicsEndImageContext();
    }
    
    CFRelease(line);
    CGPathRelease(letters);
    CFRelease(font);
}


+(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}

@end

void TranslationY(CGPoint * p, CGFloat maxY)
{
    p->y = maxY - p->y;
}

void CGPathEnumerationCallback(void * userParams, const CGPathElement *element)
{
    NSString *description = nil;
    void ** params = (void **)userParams;
    CGFloat maxY = *(CGFloat*)params[0];
    NSMutableArray * pathAry = (__bridge NSMutableArray*)params[1];
    NSUInteger count = [pathAry count];
    CGMutablePathRef currentPath = (__bridge CGMutablePathRef)([pathAry objectAtIndex:count - 1]);  // 取最后一个 path

    switch (element->type)
    {
        case kCGPathElementMoveToPoint:
        {
            CGPoint point = element->points[0];
            TranslationY(&point, maxY);
            CGPathMoveToPoint(currentPath, nil, point.x, point.y);
            description = [NSString stringWithFormat:@"%@: %f %f", @"moveto", point.x, point.y];
            break;
        }
        case kCGPathElementAddLineToPoint:
        {
            CGPoint point = element->points[0];
            TranslationY(&point, maxY);
            CGPathAddLineToPoint(currentPath, nil, point.x, point.y);
            description = [NSString stringWithFormat:@"%@: %f %f", @"lineto", point.x, point.y];
            break;
        }
        case kCGPathElementAddQuadCurveToPoint:
        {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            TranslationY(&point1, maxY);
            TranslationY(&point2, maxY);
            CGPathAddQuadCurveToPoint(currentPath, nil, point1.x, point1.y, point2.x, point2.y);
            description = [NSString stringWithFormat:@"%@: %f %f %f %f", @"QuadCurve", point1.x, point1.y, point2.x, point2.y];
            break;
        }
        case kCGPathElementAddCurveToPoint:
        {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            CGPoint point3 = element->points[2];
            TranslationY(&point1, maxY);
            TranslationY(&point2, maxY);
            TranslationY(&point3, maxY);
            CGPathAddCurveToPoint(currentPath, nil, point1.x, point1.y, point2.x, point2.y, point3.x, point3.y);
            description = [NSString stringWithFormat:@"%@: %f %f %f %f %f %f", @"curveto", point1.x, point1.y, point2.x, point2.y, point3.x, point3.y];
            break;
        }
        case kCGPathElementCloseSubpath:
        {
            description = @"closepath";
            CGMutablePathRef next = CGPathCreateMutable();
            [pathAry addObject:(__bridge id _Nonnull)(next)];
            break;
        }
    }
    //NSLog(@"%@", description);
}


void CGPathGetMaxYCallback(void *info, const CGPathElement *element)
{
    CGFloat * maxY = (CGFloat *)info;
    
    switch (element->type)
    {
        case kCGPathElementMoveToPoint:
        case kCGPathElementAddLineToPoint:
        {
            CGPoint point = element->points[0];
            if (point.y > *maxY) *maxY = point.y;
            break;
        }

        case kCGPathElementAddQuadCurveToPoint:
        {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            if (point1.y > *maxY) *maxY = point1.y;
            if (point2.y > *maxY) *maxY = point2.y;
            break;
        }
        case kCGPathElementAddCurveToPoint:
        {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            CGPoint point3 = element->points[2];
            if (point1.y > *maxY) *maxY = point1.y;
            if (point2.y > *maxY) *maxY = point2.y;
            if (point3.y > *maxY) *maxY = point3.y;
            break;
        }
        case kCGPathElementCloseSubpath:
        {
            break;
        }
    }
}

