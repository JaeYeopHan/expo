/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <ABI45_0_0React/ABI45_0_0RCTImageViewManager.h>

#import <UIKit/UIKit.h>

#import <ABI45_0_0React/ABI45_0_0RCTConvert.h>
#import <ABI45_0_0React/ABI45_0_0RCTImageSource.h>

#import <ABI45_0_0React/ABI45_0_0RCTImageShadowView.h>
#import <ABI45_0_0React/ABI45_0_0RCTImageView.h>
#import <ABI45_0_0React/ABI45_0_0RCTImageLoaderProtocol.h>

@implementation ABI45_0_0RCTImageViewManager

ABI45_0_0RCT_EXPORT_MODULE()

- (ABI45_0_0RCTShadowView *)shadowView
{
  return [ABI45_0_0RCTImageShadowView new];
}

- (UIView *)view
{
  return [[ABI45_0_0RCTImageView alloc] initWithBridge:self.bridge];
}

ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(blurRadius, CGFloat)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(capInsets, UIEdgeInsets)
ABI45_0_0RCT_REMAP_VIEW_PROPERTY(defaultSource, defaultImage, UIImage)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(onLoadStart, ABI45_0_0RCTDirectEventBlock)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(onProgress, ABI45_0_0RCTDirectEventBlock)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(onError, ABI45_0_0RCTDirectEventBlock)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(onPartialLoad, ABI45_0_0RCTDirectEventBlock)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(onLoad, ABI45_0_0RCTDirectEventBlock)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(onLoadEnd, ABI45_0_0RCTDirectEventBlock)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(resizeMode, ABI45_0_0RCTResizeMode)
ABI45_0_0RCT_EXPORT_VIEW_PROPERTY(internal_analyticTag, NSString)
ABI45_0_0RCT_REMAP_VIEW_PROPERTY(source, imageSources, NSArray<ABI45_0_0RCTImageSource *>);
ABI45_0_0RCT_CUSTOM_VIEW_PROPERTY(tintColor, UIColor, ABI45_0_0RCTImageView)
{
  // Default tintColor isn't nil - it's inherited from the superView - but we
  // want to treat a null json value for `tintColor` as meaning 'disable tint',
  // so we toggle `renderingMode` here instead of in `-[ABI45_0_0RCTImageView setTintColor:]`
  view.tintColor = [ABI45_0_0RCTConvert UIColor:json] ?: defaultView.tintColor;
  view.renderingMode = json ? UIImageRenderingModeAlwaysTemplate : defaultView.renderingMode;
}

ABI45_0_0RCT_EXPORT_METHOD(getSize:(NSURLRequest *)request
                  successBlock:(ABI45_0_0RCTResponseSenderBlock)successBlock
                  errorBlock:(ABI45_0_0RCTResponseErrorBlock)errorBlock)
{
  [[self.bridge moduleForName:@"ImageLoader" lazilyLoadIfNecessary:YES]
   getImageSizeForURLRequest:request
   block:^(NSError *error, CGSize size) {
     if (error) {
       errorBlock(error);
     } else {
       successBlock(@[@(size.width), @(size.height)]);
     }
   }];
}

ABI45_0_0RCT_EXPORT_METHOD(getSizeWithHeaders:(ABI45_0_0RCTImageSource *)source
                  resolve:(ABI45_0_0RCTPromiseResolveBlock)resolve
                  reject:(ABI45_0_0RCTPromiseRejectBlock)reject)
{
  [[self.bridge moduleForName:@"ImageLoader" lazilyLoadIfNecessary:YES]
   getImageSizeForURLRequest:source.request
   block:^(NSError *error, CGSize size) {
     if (error) {
       reject(@"E_GET_SIZE_FAILURE", nil, error);
       return;
     }
     resolve(@{@"width":@(size.width),@"height":@(size.height)});
   }];
}

ABI45_0_0RCT_EXPORT_METHOD(prefetchImage:(NSURLRequest *)request
                  resolve:(ABI45_0_0RCTPromiseResolveBlock)resolve
                  reject:(ABI45_0_0RCTPromiseRejectBlock)reject)
{
  if (!request) {
    reject(@"E_INVALID_URI", @"Cannot prefetch an image for an empty URI", nil);
    return;
  }
    id<ABI45_0_0RCTImageLoaderProtocol> imageLoader = (id<ABI45_0_0RCTImageLoaderProtocol>)[self.bridge
                                                                          moduleForName:@"ImageLoader" lazilyLoadIfNecessary:YES];
    [imageLoader loadImageWithURLRequest:request
                                priority:ABI45_0_0RCTImageLoaderPriorityPrefetch
                                callback:^(NSError *error, UIImage *image) {
        if (error) {
            reject(@"E_PREFETCH_FAILURE", nil, error);
            return;
        }
        resolve(@YES);
    }];
}

ABI45_0_0RCT_EXPORT_METHOD(queryCache:(NSArray *)requests
                  resolve:(ABI45_0_0RCTPromiseResolveBlock)resolve
                  reject:(ABI45_0_0RCTPromiseRejectBlock)reject)
{
  resolve([[self.bridge moduleForName:@"ImageLoader"] getImageCacheStatus:requests]);
}

@end
