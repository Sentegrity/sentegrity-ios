/*
 * (c) 2015 Good Technology Corporation. All rights reserved.
 */

#pragma once

#if defined(__APPLE__)

#include <Availability.h>

#if defined(__OBJC__) && defined(__cplusplus)

namespace GD {
    template <typename CastT, typename ArgT>
    static inline CastT* NSCheckedCast(ArgT arg) {
        if (!arg || [arg isKindOfClass:[CastT class]]) {
            return (CastT*)arg;
        } else {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"%@ is not of type %@", arg, NSStringFromClass([CastT class])] userInfo:nil];
        }
    }
    
    template <typename CastT, typename ArgT>
    static inline CastT* CFCheckedCast(ArgT arg) {
        if (!(__bridge CastT)arg || [(__bridge CastT)arg isKindOfClass:[CastT class]]) {
            return (__bridge CastT*)arg;
        } else {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"%@ is not of type %@", (__bridge CastT*)arg, NSStringFromClass([CastT class])] userInfo:nil];
        }
    }
}


#endif // __OBJC__

#if defined(__MAC_10_11) || defined(__IPHONE_9_0)
    #define GD_NSKINDOF __kindof
#else
    #define GD_NSKINDOF
#endif

#if defined(__has_feature)
    #if __has_feature(nullability)
        #define GD_NSNULLABLE_PROP      nullable,
        #define GD_NSNULLABLE           nullable
        #define GD_NSNON_NULL           nonnull
        #define GD_NSNULL_UNSPECIFIED   null_unspecified

        #if defined(__MAC_10_11) || defined(__IPHONE_9_0)
            #define GD_NSNULLABLE_POINTER           _Nullable
            #define GD_NSNON_NULL_POINTER           _Nonnull
            #define GD_NSNULL_UNSPECIFIED_POINTER   _Null_unspecified
        #else
            #define GD_NSNULLABLE_POINTER           __nullable
            #define GD_NSNON_NULL_POINTER           __nonnull
            #define GD_NSNULL_UNSPECIFIED_POINTER   __null_unspecified
        #endif

        #define GD_NSNON_NULL_CAST(ObjectType, Expression) ((ObjectType __nonnull)(ObjectType)Expression)

        #define GD_NS_ASSUME_NONNULL_BEGIN  NS_ASSUME_NONNULL_BEGIN
        #define GD_NS_ASSUME_NONNULL_END    NS_ASSUME_NONNULL_END
    #else
        #define GD_NSNULLABLE_PROP
        #define GD_NSNULLABLE
        #define GD_NSNON_NULL
        #define GD_NSNULL_UNSPECIFIED

        #define GD_NSNULLABLE_POINTER
        #define GD_NSNON_NULL_POINTER
        #define GD_NSNULL_UNSPECIFIED_POINTER

        #define GD_NSNON_NULL_CAST(ObjectType, Expression) ((ObjectType)Expression)

        #define GD_NS_ASSUME_NONNULL_BEGIN
        #define GD_NS_ASSUME_NONNULL_END
    #endif

    #if __has_feature(objc_generics)
        #define GD_NSDictionary(KeyType, ObjectType)        NSDictionary<KeyType, ObjectType>
        #define GD_NSMutableDictionary(KeyType, ObjectType) NSMutableDictionary<KeyType, ObjectType>

        #define GD_NSArray(ObjectType)                  NSArray<ObjectType>
        #define GD_NSMutableArray(ObjectType)           NSMutableArray<ObjectType>

        #define GD_NSSet(ObjectType)                    NSSet<ObjectType>
        #define GD_NSMutableSet(ObjectType)             NSMutableSet<ObjectType>

        #define GD_NSDirectoryEnumerator(ObjectType)    NSDirectoryEnumerator<ObjectType>
    #else
        #define GD_NSDictionary(KeyType, ObjectType)        NSDictionary
        #define GD_NSMutableDictionary(KeyType, ObjectType) NSMutableDictionary

        #define GD_NSArray(ObjectType)                  NSArray
        #define GD_NSMutableArray(ObjectType)           NSMutableArray

        #define GD_NSSet(ObjectType)                    NSSet
        #define GD_NSMutableSet(ObjectType)             NSMutableSet

        #define GD_NSDirectoryEnumerator(ObjectType)    NSDirectoryEnumerator
    #endif
#endif

#endif
