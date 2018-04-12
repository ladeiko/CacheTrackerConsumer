//
//  CacheTracker+TryCatch.h
//  CacheTrackerConsumer
//
//  Created by Siarhei Ladzeika on 4/12/18.
//

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable CacheTrackerConsumer_tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

