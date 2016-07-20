//
//  WZAssetResourceLoader.m
//  HLSPlayData
//
//  Created by wangzhong on 16/7/20.
//  Copyright © 2016年 wangzhong. All rights reserved.
//

#import "WZAssetResourceLoader.h"

static NSString *redirectScheme = @"rdtp";
static NSString *customPlaylistScheme = @"cplp";
static NSString *httpScheme = @"http";

static int redirectErrorCode = 302;
static int badRequestErrorCode = 400;


static NSString *customPlayListFormatPrefix = @"#EXTM3U\n"
"#EXT-X-TARGETDURATION:7\n"
"#EXT-X-VERSION:3\n"
"#EXT-X-MEDIA-SEQUENCE:0\n";

static NSString *customPlayListFormatElementInfo = @"#EXTINF:6, no desc\n";
static NSString *customPlaylistFormatElementSegment = @"%@/out%d.ts\n";

static NSString *customEncryptionKeyInfo = @"#EXT-X-KEY:METHOD=AES-128,URI=\"%@/file.key\"\n";
static NSString *customPlayListFormatEnd = @"#EXT-X-ENDLIST";

@interface WZAssetResourceLoader ()
- (BOOL) schemeSupported:(NSString*) scheme;
- (void) reportError:(AVAssetResourceLoadingRequest *) loadingRequest withErrorCode:(int) error;
@end

/**
 *WZAssetResourceLoader
 *单个ts文件路径处理
 */
@interface WZAssetResourceLoader (Redirect)
- (BOOL) isRedirectSchemeValid:(NSString*) scheme;
- (BOOL) handleRedirectRequest:(AVAssetResourceLoadingRequest*) loadingRequest;
- (NSURLRequest* ) generateRedirectURL:(NSURLRequest *)sourceURL;
@end

/**
 *WZAssetResourceLoader
 *m3u8文件处理
 */
@interface WZAssetResourceLoader (CustomPlaylist)
- (BOOL) isCustomPlaylistSchemeValid:(NSString*) scheme;
- (NSString*) getCustomPlaylist:(NSString *) urlPrefix andTotalElements:(NSInteger) elements;
- (BOOL) handleCustomPlaylistRequest:(AVAssetResourceLoadingRequest*) loadingRequest;
@end


#pragma mark - WZAssetResourceLoader

@implementation WZAssetResourceLoader
/*!
 *  is scheme supported
 */
- (BOOL) schemeSupported:(NSString *)scheme
{
    if ( [self isRedirectSchemeValid:scheme] ||
        [self isCustomPlaylistSchemeValid:scheme])
        return YES;
    return NO;
}

-(WZAssetResourceLoader *) init
{
    self = [super init];
    return self;
}

- (void) reportError:(AVAssetResourceLoadingRequest *) loadingRequest withErrorCode:(int) error
{
    [loadingRequest finishLoadingWithError:[NSError errorWithDomain: NSURLErrorDomain code:error userInfo: nil]];
}

/*!
 *  Check the given request for valid schemes:
 *
 * 1) Redirect 2) Custom Play list
 */
- (BOOL) resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSString* scheme = [[[loadingRequest request] URL] scheme];
    
    if ([self isRedirectSchemeValid:scheme])
        return [self handleRedirectRequest:loadingRequest];
    
    if ([self isCustomPlaylistSchemeValid:scheme]) {
        dispatch_async (dispatch_get_main_queue(),  ^ {
            [self handleCustomPlaylistRequest:loadingRequest];
        });
        return YES;
    }
    
    return NO;
}

@end

#pragma mark - WZAssetResourceLoader Redirect

@implementation WZAssetResourceLoader (Redirect)
/*!
 * Validates the given redirect schme.
 */
- (BOOL) isRedirectSchemeValid:(NSString *)scheme
{
    return ([redirectScheme isEqualToString:scheme]);
}

-(NSURLRequest* ) generateRedirectURL:(NSURLRequest *)sourceURL
{
    NSURLRequest *redirect = [NSURLRequest requestWithURL:[NSURL URLWithString:[[[sourceURL URL] absoluteString] stringByReplacingOccurrencesOfString:redirectScheme withString:httpScheme]]];
    return redirect;
}
/*!
 *  The delegate handler, handles the received request:
 *
 *  1) Verifies its a redirect request, otherwise report an error.
 *  2) Generates the new URL
 *  3) Create a reponse with the new URL and report success.
 */
- (BOOL) handleRedirectRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSURLRequest *redirect = nil;
    
    redirect = [self generateRedirectURL:(NSURLRequest *)[loadingRequest request]];
    if (redirect)
    {
        [loadingRequest setRedirect:redirect];
        NSLog(@"\n[Function]:%s\n" "[line]:%d\n" "[value]:%@\n",__FUNCTION__, __LINE__, [redirect URL]);
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[redirect URL] statusCode:redirectErrorCode HTTPVersion:nil headerFields:nil];
        [loadingRequest setResponse:response];
        [loadingRequest finishLoading];
        
    } else
    {
        [self reportError:loadingRequest withErrorCode:badRequestErrorCode];
    }
    return YES;
}

@end

#pragma mark - WZAssetResourceLoader CustomPlaylist

@implementation WZAssetResourceLoader (CustomPlaylist)

- (BOOL) isCustomPlaylistSchemeValid:(NSString *)scheme
{
    return ([customPlaylistScheme isEqualToString:scheme]);
}
/*!
 * create a play list based on the given prefix and total elements
 */
- (NSString*) getCustomPlaylist:(NSString *) urlPrefix andTotalElements:(NSInteger) elements
{
#warning For Test
    NSString *Path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"hls-ecb-test/outRun.m3u8"];
    return [NSString stringWithContentsOfFile:Path encoding:NSUTF8StringEncoding error:nil];
    
    
    static NSMutableString  *customPlaylist = nil;
    
    if (customPlaylist)
        return customPlaylist;
    
    customPlaylist = [[NSMutableString alloc] init];
    [customPlaylist appendString:customPlayListFormatPrefix];
    for (int i = 0; i < elements; ++i)
    {
        [customPlaylist appendString:customPlayListFormatElementInfo];
        [customPlaylist appendFormat:customPlaylistFormatElementSegment, urlPrefix, i];
    }
    [customPlaylist appendString:customPlayListFormatEnd];
    return customPlaylist;
}
/*!
 *  Handles the custom play list scheme:
 *
 *  1) Verifies its a custom playlist request, otherwise report an error.
 *  2) Generates the play list.
 *  3) Create a reponse with the new URL and report success.
 */
- (BOOL) handleCustomPlaylistRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    //Prepare the playlist with redirect scheme.
    NSString *prefix = [[[[loadingRequest request] URL] absoluteString] stringByReplacingOccurrencesOfString:customPlaylistScheme withString:redirectScheme];// stringByDeletingLastPathComponent];
    NSRange range = [prefix rangeOfString:@"/" options:NSBackwardsSearch];
    prefix = [prefix substringToIndex:range.location];
    NSData *data = [[self getCustomPlaylist:prefix andTotalElements:22] dataUsingEncoding:NSUTF8StringEncoding];
    
    if (data)
    {
        [loadingRequest.dataRequest respondWithData:data];
        [loadingRequest finishLoading];
    } else
    {
        [self reportError:loadingRequest withErrorCode:badRequestErrorCode];
    }
    
    return YES;
}
@end





