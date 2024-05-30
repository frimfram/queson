//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<camera_avfoundation/CameraPlugin.h>)
#import <camera_avfoundation/CameraPlugin.h>
#else
@import camera_avfoundation;
#endif

#if __has_include(<google_mlkit_commons/GoogleMlKitCommonsPlugin.h>)
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>
#else
@import google_mlkit_commons;
#endif

#if __has_include(<google_mlkit_image_labeling/GoogleMlKitImageLabelingPlugin.h>)
#import <google_mlkit_image_labeling/GoogleMlKitImageLabelingPlugin.h>
#else
@import google_mlkit_image_labeling;
#endif

#if __has_include(<google_mobile_ads/FLTGoogleMobileAdsPlugin.h>)
#import <google_mobile_ads/FLTGoogleMobileAdsPlugin.h>
#else
@import google_mobile_ads;
#endif

#if __has_include(<path_provider_ios/FLTPathProviderPlugin.h>)
#import <path_provider_ios/FLTPathProviderPlugin.h>
#else
@import path_provider_ios;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [CameraPlugin registerWithRegistrar:[registry registrarForPlugin:@"CameraPlugin"]];
  [GoogleMlKitCommonsPlugin registerWithRegistrar:[registry registrarForPlugin:@"GoogleMlKitCommonsPlugin"]];
  [GoogleMlKitImageLabelingPlugin registerWithRegistrar:[registry registrarForPlugin:@"GoogleMlKitImageLabelingPlugin"]];
  [FLTGoogleMobileAdsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMobileAdsPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
}

@end
