//
//  FMDBColumn.h
//  Team Wurzel
//
//  Created by Ralf Schleicher on 30.12.13.
//  Copyright (c) 2013 Team Wurzel. All rights reserved.
//

#import <Foundation/Foundation.h>

// Type Strings
extern NSString* const FMDBORMTypeNull;
extern NSString* const FMDBORMTypeInteger;
extern NSString* const FMDBORMTypeText;
extern NSString* const FMDBORMTypeReal;
extern NSString* const FMDBORMTypeBlob;

// Extra Strings
extern NSString* const FMDBORMExtraPrimaryKey;
extern NSString* const FMDBORMExtraAutoIncrement;
extern NSString* const FMDBORMExtraUnique;
extern NSString* const FMDBORMExtraNotNull;

/*!
 * FMDBORMColumn is designed to be a object specification of a sqlite column
 */
@interface FMDBORMColumn : NSObject
/*!
 * the column name
 */
@property (atomic, retain) NSString *name;
@property (atomic, retain) NSString *type;
@property (atomic, retain) NSArray *extraModifier;
-(id)initWithColumnName:(NSString*)columnName andType:(NSString*)typeName;
-(id)initWithColumnName:(NSString*)columnName andType:(NSString*)typeName andExtraModifier:(NSArray*)extras;
@end
