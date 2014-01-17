//
//  FMDBHelper.h
//  Team Wurzel
//
//  Created by Ralf Schleicher on 30.12.13.
//  Copyright (c) 2013 Team Wurzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBORMLibrary.h"

@class FMDBORMModel, FMResultSet;

@interface FMDBORMHelper : NSObject
/*!
 * @param classRepresentation # a class implementing the FMDBORMTableProtocol
 * @return the statement
 */
+(NSString*)createStatementForClass:(Class)classRepresentation;

/*!
 * @param classRepresentation # a class implementing the FMDBORMTableProtocol
 * @return the statement
 */
+(NSString*)dropStatementForClass:(Class)classRepresentation;

/*!
 * @param classRepresentation # a class implementing the FMDBORMTableProtocol
 * @return the statement
 */
+(NSString*)selectStatementForClass:(Class)classRepresentation;

/*!
 * @param classRepresentation # a class implementing the FMDBORMTableProtocol
 * @return the statement
 */
+(NSString*)insertStatementForClass:(Class)classRepresentation;

/*!
 * @param classRepresentation # a class implementing the FMDBORMTableProtocol
 * @return the statement
 */
+(NSString*)updateStatementForClass:(Class)classRepresentation;

/*!
 * @param classRepresentation # a class implementing the FMDBORMTableProtocol
 * @return the statement
 */
+(NSString*)deleteStatementForClass:(Class)classRepresentation;
@end
