//
//  RLMResults+ToArray.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/21.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMResults (ToArray)

- (NSArray<RLMObject *> *)toArray;

@end
