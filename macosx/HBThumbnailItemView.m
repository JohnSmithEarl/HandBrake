/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Custom NSScrubberItemView used to display an image.
 */

#import "HBThumbnailItemView.h"

@interface HBThumbnailItemView ()

@property (strong) NSImageView *imageView;

@end

#pragma mark -

@implementation HBThumbnailItemView

@synthesize thumbnail = _thumbnail;

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self != nil)
    {
        _thumbnail = [[NSImage alloc] initWithSize:frameRect.size];
        _imageView = [NSImageView imageViewWithImage:_thumbnail];
        [_imageView setAutoresizingMask:(NSAutoresizingMaskOptions)(NSViewWidthSizable | NSViewHeightSizable)];

        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)updateLayer
{
    self.layer.backgroundColor = NSColor.controlColor.CGColor;
}

- (void)layout
{
    [super layout];
    _imageView.frame = self.bounds;
}

- (NSImage *)thumbnail
{
    return _imageView.image;
}

- (void)setThumbnail:(NSImage *)thumbnail
{
    _imageView.hidden = NO;
    _imageView.image = thumbnail;
}

- (void)setThumbnailIndex:(NSUInteger)thumbnailIndex
{
    _thumbnailIndex = thumbnailIndex;

    _imageView.hidden = YES;

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        HBPreviewGenerator *generator = self.generator;

        [generator copySmallImageAtIndex:thumbnailIndex completionHandler:^(CGImageRef  _Nullable result)
         {
             if (result != NULL)
             {
                 NSSize size = NSMakeSize(CGImageGetWidth(result), CGImageGetHeight(result));
                 NSImage *thumbnail = [[NSImage alloc] initWithCGImage:result size:size];

                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self setThumbnail:thumbnail];
                 });
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self setThumbnail:nil];
                 });
             }
         }];
    });
}

@end
