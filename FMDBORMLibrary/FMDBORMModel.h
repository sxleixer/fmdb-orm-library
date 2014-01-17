//
//  FMDBORMModel.h
//  Team Wurzel
//
//  Created by Ralf Schleicher on 16.01.14.
//  Copyright (c) 2014 Team Wurzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBORMLibrary.h"

/*!
 * FMDBORMModel is a basic implementation of the FMDBORMTableProtocol.
 * It handles all the basic tasks of the objects and its inherited classes
 *
 * For implementation details @implementation of this class
 *
 */
@interface FMDBORMModel : NSObject<FMDBORMTableProtocol>
/*!
 * uid property for a unique row identification
 */
@property (nonatomic, retain) NSNumber *uid;
@end
