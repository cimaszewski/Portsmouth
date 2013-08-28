//  Copyright 2013 Chris Cimaszewski
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  PortsmouthDefines.h
//  Portsmouth


#ifndef Portsmouth_PortsmouthDefines_h
#define Portsmouth_PortsmouthDefines_h

#ifndef SINGLETON_BOILERPLATE

#define SINGLETON_BOILERPLATE(_object_name_, _shared_obj_name_) SINGLETON_BOILERPLATE_FULL(_object_name_, _shared_obj_name_, init)

#endif // SINGLETON_BOILERPLATE

#ifndef SINGLETON_BOILERPLATE_FULL

#define SINGLETON_BOILERPLATE_FULL(_object_name_, _shared_obj_name_, _init_) \
static _object_name_ *z##_shared_obj_name_ = nil;  \
+ (_object_name_ *)_shared_obj_name_ {             \
@synchronized(self) {                            \
if (z##_shared_obj_name_ == nil) {             \
/* Note that 'self' may not be the same as _object_name_ */                               \
/* first assignment done in allocWithZone but we must reassign in case init fails */      \
z##_shared_obj_name_ = [[self alloc] _init_];                                               \
}                                              \
}                                                \
return z##_shared_obj_name_;                     \
}                                                  \
+ (id)allocWithZone:(NSZone *)zone {               \
@synchronized(self) {                            \
if (z##_shared_obj_name_ == nil) {             \
z##_shared_obj_name_ = [super allocWithZone:zone]; \
return z##_shared_obj_name_;                 \
}                                              \
}                                                \
\
/* We can't return the shared instance, because it's been init'd */ \
return nil;                                      \
}                                                  \
                                                \
- (id)copyWithZone:(NSZone *) __unused zone { \
return self;                                     \
}                                                  \

#endif // SINGLETON_BOILERPLATE_FULL


#endif
