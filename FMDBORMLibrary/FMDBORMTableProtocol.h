//
//  TableProtocol.h
//  Team Wurzel
//
//  Created by Ralf Schleicher on 30.12.13.
//  Copyright (c) 2013 Team Wurzel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase, FMResultSet;

/*!
 * This protocol is designed to specify an Object Related Mapping for the fmdb sqlite database wrapper.
 */
@protocol FMDBORMTableProtocol <NSObject>

/*!
 * @return if the given object is abstract or not
 */
+(BOOL)isAbstract;

/*!
 * returns the name of the table
 * the used format is inherited from sqlite3 tablename format
 *
 * @return the name of the table
 */
+(NSString*)tableName;

/*!
 * relizes a variable <-> column mapping in an specific manner
 *
 * @return the variable <-> column mapping
 */
+(NSDictionary*)mapping;

/*!
 * @return the create statement for the specified table
 */
+(NSString*)createStatement;

/*!
 * @return the drop statement for the specified table
 */
+(NSString*)dropStatement;

/*!
 * @return a generic select statement without the where clause
 */
+(NSString*)genericSelectStatement;

/*!
 * @return a generic insert statement containing ? for substitution of values
 */
+(NSString*)genericInsertStatement;

/*!
 * @return a generic update statement containing ? for substitution of values
 */
+(NSString*)genericUpdateStatement;

/*!
 * @return a generic update statement containing ? for substitution of values
 */
+(NSString*)genericDeleteStatement;

/*!
 * @return an object of the model's type from result set
 */
+(id)newObjectWithResultSet:(FMResultSet*)set;

/*!
 * @return a complete array consisting of elements of the model's type from result set
 */
+(NSMutableArray*)newObjectsWithResultSet:(FMResultSet*)set;

/*!
 * @return an object of the model's type from json object
 */
+(id)newObjectWithJSONObject:(NSDictionary*)jsonObject;

/*!
 * @return a complete array consisting of elements of the model's type from json array
 */
+(NSMutableArray*)newObjectsWithJSONObjectArray:(NSArray*)jsonObjectArray;

/*!
 * Creates a table in the specified database.
 *
 * @param db # the database where the table should be created in
 * @return if the table could be created
 */
+(BOOL)createTable:(FMDatabase*)db;

/*!
 * Drops a table in the specified database.
 *
 * @param db # the database where the table should dropped from
 * @return if the table could be dropped
 */
+(BOOL)dropTable:(FMDatabase*)db;

/*!
 * Returns if the object already exists in database.
 *
 * @param db # the database where the given object should be tested for existence in table
 * @return if the object already exists
 */
-(BOOL)exists:(FMDatabase*)db;

/*!
 * @return the condition which uniquely identifies a row
 */
-(NSString*)uniqueWhereCondition;

/*!
 * @return the value used to fill the unique where condition
 */
-(NSObject*)uniqueValue;

/*!
 * Creates or updates the object in the database's table
 *
 * @param db # the database to put the dataset into the related table
 */
-(void)put:(FMDatabase*)db;

/*!
 * Deletes the object from the given database
 *
 * @param db # the database to delete from
 */
-(void)erase:(FMDatabase*)db;

/*!
 * @return a dictionary containing all the objects data
 */
-(NSDictionary*)jsonObject;

@end
