using System;
using System.Data;
using System.Text;
using System.Xml;

namespace Fmk.Framework.Data.Sql
{
    public static class SqlBuilder
    {

        #region *** DB Type Related ***

        private static Dictionary<Type, DbType>? _typeMap;
        private static Dictionary<Type, SqlDbType>? _sqlTypeMap;

        public static DbType GetDbType(Type type)
        {
            if (_typeMap == null)
            {
                _typeMap = new Dictionary<Type, DbType>
                {
                    [typeof(string)] = DbType.String,

                    [typeof(byte)] = DbType.Byte,
                    [typeof(sbyte)] = DbType.SByte,
                    [typeof(short)] = DbType.Int16,
                    [typeof(ushort)] = DbType.UInt16,
                    [typeof(int)] = DbType.Int32,
                    [typeof(uint)] = DbType.UInt32,
                    [typeof(long)] = DbType.Int64,
                    [typeof(ulong)] = DbType.UInt64,
                    [typeof(float)] = DbType.Single,
                    [typeof(double)] = DbType.Double,
                    [typeof(decimal)] = DbType.Decimal,
                    [typeof(bool)] = DbType.Boolean,
                    [typeof(char)] = DbType.StringFixedLength,
                    [typeof(Guid)] = DbType.Guid,
                    [typeof(DateTime)] = DbType.DateTime,
                    [typeof(DateTimeOffset)] = DbType.DateTimeOffset,
                    [typeof(byte[])] = DbType.Binary,
                    [typeof(XmlElement)] = DbType.Xml,
                    
                    [typeof(byte?)] = DbType.Byte,
                    [typeof(sbyte?)] = DbType.SByte,
                    [typeof(short?)] = DbType.Int16,
                    [typeof(ushort?)] = DbType.UInt16,
                    [typeof(int?)] = DbType.Int32,
                    [typeof(uint?)] = DbType.UInt32,
                    [typeof(long?)] = DbType.Int64,
                    [typeof(ulong?)] = DbType.UInt64,
                    [typeof(float?)] = DbType.Single,
                    [typeof(double?)] = DbType.Double,
                    [typeof(decimal?)] = DbType.Decimal,
                    [typeof(bool?)] = DbType.Boolean,
                    [typeof(char?)] = DbType.StringFixedLength,
                    [typeof(Guid?)] = DbType.Guid,
                    [typeof(DateTime?)] = DbType.DateTime,
                    [typeof(DateTimeOffset?)] = DbType.DateTimeOffset
                    //[typeof(System.Data.Linq.Binary)] = DbType.Binary
                };
            }

            if (!_typeMap.ContainsKey(type)) { throw new ArgumentException($"DataType '{type.Name}' is not supported."); }
            return _typeMap[type];
        }

        public static SqlDbType GetSqlDbType(Type type)
        {
            if (_sqlTypeMap == null)
            {
                _sqlTypeMap = new Dictionary<Type, SqlDbType>
                {
                    [typeof(string)] = SqlDbType.VarChar,

                    [typeof(byte)] = SqlDbType.TinyInt,
                    //[typeof(sbyte)] = SqlDbType.SByte,
                    [typeof(short)] = SqlDbType.SmallInt,
                    [typeof(ushort)] = SqlDbType.SmallInt,
                    [typeof(int)] = SqlDbType.Int,
                    [typeof(uint)] = SqlDbType.Int,
                    [typeof(long)] = SqlDbType.BigInt,
                    [typeof(ulong)] = SqlDbType.BigInt,
                    [typeof(float)] = SqlDbType.Float,
                    [typeof(double)] = SqlDbType.Float,
                    [typeof(decimal)] = SqlDbType.Decimal,
                    [typeof(bool)] = SqlDbType.Bit,
                    [typeof(char)] = SqlDbType.Char,
                    [typeof(Guid)] = SqlDbType.UniqueIdentifier,
                    [typeof(DateTime)] = SqlDbType.DateTime,
                    [typeof(DateTimeOffset)] = SqlDbType.DateTimeOffset,
                    [typeof(byte[])] = SqlDbType.VarBinary,
                    [typeof(XmlElement)] = SqlDbType.Xml,

                    [typeof(byte?)] = SqlDbType.TinyInt,
                    //[typeof(sbyte?)] = SqlDbType.SByte,
                    [typeof(short?)] = SqlDbType.SmallInt,
                    [typeof(ushort?)] = SqlDbType.SmallInt,
                    [typeof(int?)] = SqlDbType.Int,
                    [typeof(uint?)] = SqlDbType.Int,
                    [typeof(long?)] = SqlDbType.BigInt,
                    [typeof(ulong?)] = SqlDbType.BigInt,
                    [typeof(float?)] = SqlDbType.Float,
                    [typeof(double?)] = SqlDbType.Float,
                    [typeof(decimal?)] = SqlDbType.Decimal,
                    [typeof(bool?)] = SqlDbType.Bit,
                    [typeof(char?)] = SqlDbType.Char,
                    [typeof(Guid?)] = SqlDbType.UniqueIdentifier,
                    [typeof(DateTime?)] = SqlDbType.DateTime,
                    [typeof(DateTimeOffset?)] = SqlDbType.DateTimeOffset
                    //[typeof(System.Data.Linq.Binary)] = SqlDbType.Binary
                };
            }

            if (!_sqlTypeMap.ContainsKey(type)) { throw new ArgumentException($"DataType '{type.Name}' is not supported."); }
            return _sqlTypeMap[type];
        }

        public static bool IsSuportedType(Type type)
        {
            // Force load.
            if (_typeMap == null) { DbType dbType = GetDbType(typeof(string)); }
            return _typeMap.ContainsKey(type);
        }

        #endregion *** DB Type Related ***

        #region *** Generic Insert/Update SQL ***

        public static string GetInsertToTableSql(string tableNamespace, string tableName)
        {
            return $"INSERT INTO {GetTable(tableNamespace, tableName)}";
        }

        public static string GetInsertToTableSql(string tableNamespace, string tableName, List<string> columns, List<string> values)
        {
            if (columns == null || columns.Count < 1) { throw new ArgumentException("The 'columns' List argument must have at least one value"); }
            if (values == null || values.Count < 1) { throw new ArgumentException("The 'values' List argument must have at least one value"); }
            if (columns.Count != values.Count) { throw new ArgumentException("The 'columns' and 'values' Lists must have the same number of values"); }

            StringBuilder sql = new StringBuilder();
            foreach (string column in columns)
            {
                if (sql.Length > 0) { sql.Append(","); }
                sql.Append($"[{column.Replace("[", "").Replace("]", "")}]");
            }

            StringBuilder sql2 = new StringBuilder();
            foreach (string value in values)
            {
                if (sql2.Length > 0) { sql2.Append(","); }
                sql2.Append(value);
            }

            return $"{GetInsertToTableSql(tableNamespace, tableName)} ({sql}) VALUES ({sql2}); ";
        }

        public static string GetInsertToTableSql(string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters)
        {
            if (valueQueryParameters == null || valueQueryParameters.Count < 1) { throw new ArgumentException("The 'ValueQueryParameters' List argument must have at least one value"); }

            StringBuilder sql = new StringBuilder();
            foreach (QueryParameter qParam in valueQueryParameters)
            {
                if (sql.Length > 0) { sql.Append(","); }
                sql.Append($"[{qParam.Name.Replace("@", "")}]");
            }

            StringBuilder sql2 = new StringBuilder();
            foreach (QueryParameter qParam in valueQueryParameters)
            {
                if (sql2.Length > 0) { sql2.Append(","); }
                sql2.Append(qParam.Name);
            }

            return $"{GetInsertToTableSql(tableNamespace, tableName)} ({sql}) VALUES ({sql2}); ";
        }

        public static string GetUpdateTableSql(string tableNamespace, string tableName)
        {
            return $"UPDATE {GetTable(tableNamespace, tableName)}";
        }

        public static string GetUpdateTableSql(string tableNamespace, string tableName, List<string> columns, List<string> values, string idColumnName, string idValue)
        {
            if (columns == null || columns.Count < 1) { throw new ArgumentException("The 'columns' List argument must have at least one value"); }
            if (values == null || values.Count < 1) { throw new ArgumentException("The 'values' List argument must have at least one value"); }
            if (columns.Count != values.Count) { throw new ArgumentException("The 'columns' and 'values' Lists must have the same number of values"); }

            StringBuilder sql = new StringBuilder();
            for (int i = 0; i < columns.Count; i++)
            {
                if (sql.Length > 0) { sql.Append(","); }
                sql.Append($"[{columns[i].Replace("[", "").Replace("]", "")}]={values[i]}");
            }

            return $"{GetUpdateTableSql(tableNamespace, tableName)} SET {sql} WHERE [{idColumnName}]={idValue}; ";
        }

        public static string GetUpdateTableSql(string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters, IList<QueryParameter> whereQueryParameters)
        {
            if (valueQueryParameters == null || valueQueryParameters.Count < 1) { throw new ArgumentException("The 'ValueQueryParameters' List argument must have at least one value"); }

            StringBuilder sql = new StringBuilder();
            foreach (QueryParameter qParam in valueQueryParameters)
            {
                if (sql.Length > 0) { sql.Append(","); }
                sql.Append($"[{qParam.Name.Replace("@", "")}]={qParam.Name}");
            }

            StringBuilder sql2 = new StringBuilder();
            if (whereQueryParameters != null && whereQueryParameters.Count > 0)
            {
                sql2.Append(" WHERE ");
                foreach (QueryParameter qParam in whereQueryParameters)
                {
                    if (sql2.Length > 7) { sql2.Append(" AND "); }
                    sql2.Append($"([{qParam.Name.Replace("@", "")}]={qParam.Name})");
                }
            }
            
            return $"{GetUpdateTableSql(tableNamespace, tableName)} SET {sql}{sql2}; ";
        }

        public static string GetInsertToRelationshipTableSql(string tableNamespace, string tableName, string parentIdColumnName, string parentIdOrParameterName,
            string childIdColumnName, string childIdOrParameterName, bool protectAgainstDupeRecord)
        {
            string insertSql = $"{GetInsertToTableSql(tableNamespace, tableName)} ([{parentIdColumnName}],[{childIdColumnName}]) VALUES ({parentIdOrParameterName},{childIdOrParameterName})";
            if (protectAgainstDupeRecord)
            {
                insertSql = $"IF NOT EXISTS(SELECT [{parentIdColumnName}] FROM [{tableNamespace}].[{tableName}] WHERE [{parentIdColumnName}]={parentIdOrParameterName} AND [{childIdColumnName}]={childIdOrParameterName}) BEGIN {insertSql} END";
            }
            return insertSql;
        }
        
        #endregion

        #region *** Generic Delete SQL ***

        public static string GetDeleteFromTableSql(string tableNamespace, string tableName)
        {
            return $"DELETE FROM {GetTable(tableNamespace, tableName)}";
        }

        public static string GetDeleteFromTableSql(string tableNamespace, string tableName, string idColumnName, string idValue)
        {
            return $"{GetDeleteFromTableSql(tableNamespace, tableName)} WHERE [{idColumnName}]={idValue}; ";
        }

        public static string GetDeleteFromTableSql(string tableNamespace, string tableName, IList<QueryParameter> whereQueryParameters)
        {
            // Note:  Technically, could have a delete w/o a where, but guarding against that here anyway.
            if (whereQueryParameters == null || whereQueryParameters.Count < 1) { throw new ArgumentException("The 'WhereQueryParameters' List argument must have at least one value"); }

            StringBuilder sql = new StringBuilder();
            foreach (QueryParameter qParam in whereQueryParameters)
            {
                if (sql.Length > 0) { sql.Append(" AND "); }
                sql.Append($"([{qParam.Name.Replace("@", "")}]={qParam.Name})");
            }

            return $"{GetDeleteFromTableSql(tableNamespace, tableName)} WHERE ({sql}); ";
        }

        public static string GetDeleteFromRelationshipTableSql(string tableNamespace, string tableName, string parentIdColumnName, string parentIdOrPlaceholder,
            string childIdColumnName, List<string> childIdsOrPlaceholders)
        {
            if (childIdsOrPlaceholders.Count < 1)
            {
                return string.Empty;
            }
            else if (childIdsOrPlaceholders.Count == 1)
            {
                return $"{GetDeleteFromTableSql(tableNamespace, tableName)} WHERE [{parentIdColumnName}]={parentIdOrPlaceholder} AND [{childIdColumnName}]={childIdsOrPlaceholders.First()}; ";
            }
            else
            {
                return $"{GetDeleteFromTableSql(tableNamespace, tableName)} WHERE [{parentIdColumnName}]={parentIdOrPlaceholder} AND [{childIdColumnName}] IN ({string.Join(",", childIdsOrPlaceholders)}); ";
            }
        }

        //public static string GetIdsOfChildrenToDeleteSql(string tableNamespace, string tableName, string parentIdColumnName, string parentIdValue,
        //    string childIdColumnName, List<string> notTheseChildIdValues)
        //{
        //    string valueList = string.Join(",", notTheseChildIdValues);
        //    return $"SELECT {childIdColumnName} FROM {GetTable(tableNamespace, tableName)} WHERE {parentIdColumnName}={parentIdValue} AND {childIdColumnName} NOT IN ({valueList})";
        //}

        #endregion *** Generic Delete SQL ***

        #region *** Generic Select SQL ***

        public static void AddConstantToColumnSql(IList<string> columnSql, string constant)
        {
            columnSql.Add($"{constant}");
        }

        public static void AddValueToColumnSql(IList<string> columnSql, object value, bool isUnquoted = false)
        {
            if (isUnquoted) { columnSql.Add($"{value}"); }
            else { columnSql.Add($"'{value}'"); }
        }

        public static void AddColumnRefToColumnSql(IList<string> columnSql, string tablelNamesapce, string tableName, string columnName)
        {
            columnSql.Add($"{GetTable(tablelNamesapce, tableName)}.[{columnName}]");
        }

        public static string GetSelectForListsOfParts(IList<string> columnSqls, IList<string> relateSqls, IList<string> filterSqls = null)
        {
            StringBuilder sql = new StringBuilder();
            sql.Append("SELECT ");
            sql.Append(string.Join(",", columnSqls) + " ");
            sql.Append(string.Join(" ", relateSqls) + " ");

            if (filterSqls != null && filterSqls.Count > 0)
            {
                sql.Append(GetCombinedFilterSqls(filterSqls) + " ");
            }

            sql.Length -= 1;
            return sql + "; ";
        }

        public static string GetCombinedFilterSqls(IList<string> filterSqls)
        {
            StringBuilder sql = new StringBuilder();
            if (filterSqls != null && filterSqls.Count > 0)
            {
                int cnt = 0;
                foreach (string filter in filterSqls)
                {
                    cnt++;
                    sql.Append((cnt == 1) ? "WHERE " : "AND ");
                    sql.Append($"{filter} ");
                }
                sql.Length -= 1;
            }
            return sql.ToString();
        }

        #endregion

        #region *** Generic Relate SQL ***

        public static string GetFromSql(string tableAlias, string tableNamespace, string tableName)
        {
            return $"FROM [{tableNamespace}].[{tableName}] [{tableAlias}]";
        }

        public static string GetJoinSql(bool isInnerJoin, string parentTblAlias, string parentTblRefCol, string childTblAlias, string childTblNamesapce, 
            string childTblName, string childTblRefCol)
        {
            string jnType = (isInnerJoin) ? "INNER" : "LEFT OUTER";
            string childTbl = GetTable(childTblNamesapce, childTblName);
            return $"{jnType} JOIN {childTbl} [{childTblAlias}] ON [{parentTblAlias}].[{parentTblRefCol}]=[{childTblAlias}].[{childTblRefCol}]";
        }

        public static string GetJoinSql(bool isInnerJoin, string parentTblAlias, string parentTblRefCol, string jnTblAlias, string jnTblNamesapce, 
            string jnTblName, string jnTblParentIdCol, string jnTblChildIdCol, string childTblAlias, string childTblNamesapce, string childTblName, 
            string childTblRefCol)
        {
            string jnType = (isInnerJoin) ? "INNER" : "LEFT OUTER";
            string jnTbl = GetTable(jnTblNamesapce, jnTblName);
            string childTbl = GetTable(childTblNamesapce, childTblName);
            return $"{jnType} JOIN {jnTbl} [{jnTblAlias}] ON [{parentTblAlias}].[{parentTblRefCol}]=[{jnTblAlias}].[{jnTblParentIdCol}] {jnType} JOIN {childTbl} [{childTblAlias}] ON [{jnTblAlias}].[{jnTblChildIdCol}]=[{childTblAlias}].[{childTblRefCol}]";
        }

        #endregion

        #region *** Generic Filter SQL ***

        public static string GetFilterSql(string tableNamespace, string tableName, string columnName, string parameterName, EqualityType equalityType, 
            bool isNegate, bool isXmlDataType)
        {
            string tblCol = $"{GetTable(tableNamespace, tableName)}.[{columnName}]";
            if (isXmlDataType) { tblCol = $"CAST({tblCol} as nvarchar(max))"; }
            return $"{tblCol}{GetParameterEquality(parameterName, equalityType, isNegate)}";
        }

        /// <summary>
        /// Get "of parent" filter SQL when Child has Parent's Id.
        /// </summary>
        /// <param name="childTblNamespace"></param>
        /// <param name="childTblName"></param>
        /// <param name="parentRefIdOnChild"></param>
        /// <param name="parameterName"></param>
        /// <returns></returns>
        public static string GetChildrenWithParentIdFilterSql(string childTblNamespace, string childTblName, string parentRefIdOnChild, string parameterName)
        {
            string childTbl = GetTable(childTblNamespace, childTblName);
            return $"({childTbl}.[{parentRefIdOnChild}]={parameterName})";
        }

        /// <summary>
        /// Get "of parent" filter SQL when Parent has Child's Id.
        /// </summary>
        /// <param name="childTblNamespace"></param>
        /// <param name="childTblName"></param>
        /// <param name="childIdColumnName"></param>
        /// <param name="parentTblNamespace"></param>
        /// <param name="parentTblName"></param>
        /// <param name="parentIdColumnName"></param>
        /// <param name="childRefIdOnParent"></param>
        /// <param name="parameterName"></param>
        /// <returns></returns>
        public static string GetParentHasChildIdFilterSql(string childTblNamespace, string childTblName, string childIdColumnName, string parentTblNamespace,
            string parentTblName, string parentIdColumnName, string childRefIdOnParent, string parameterName)
        {
            string childTbl = GetTable(childTblNamespace, childTblName);
            string parentTbl = GetTable(parentTblNamespace, parentTblName);
            return $"{childTbl}.[{childIdColumnName}] = (SELECT [{childRefIdOnParent}] FROM {parentTbl} WHERE [{parentIdColumnName}]={parameterName})";
        }

        /// <summary>
        /// Get "of parent" filter SQL when a join table is in use.
        /// </summary>
        /// <param name="childTblNamespace"></param>
        /// <param name="childTblName"></param>
        /// <param name="childIdColumnName"></param>
        /// <param name="jnTblNamespace"></param>
        /// <param name="jnTblName"></param>
        /// <param name="jnParentIdColumnName"></param>
        /// <param name="jnChildIdColumnName"></param>
        /// <param name="parameterName"></param>
        /// <returns></returns>
        public static string GetChildrenThroughJoinTableFilterSql(string childTblNamespace, string childTblName, string childIdColumnName, string jnTblNamespace, 
            string jnTblName, string jnParentIdColumnName, string jnChildIdColumnName, string parameterName)
        {
            string childTbl = GetTable(childTblNamespace, childTblName);
            string jnTbl = GetTable(jnTblNamespace, jnTblName);
            return $"{childTbl}.[{childIdColumnName}] IN (SELECT [{jnChildIdColumnName}] FROM {jnTbl} WHERE [{jnParentIdColumnName}]={parameterName})";
        }

        /// <summary>
        /// Get equality WHERE statement.
        /// </summary>
        /// <param name="parameterName"></param>
        /// <param name="equalityType"></param>
        /// <param name="isNegate"></param>
        /// <returns></returns>
        public static string GetParameterEquality(string parameterName, EqualityType equalityType, bool isNegate)
        {
            switch (equalityType)
            {
                case EqualityType.EqualTo:
                    if (!isNegate) { return $"={parameterName}"; }
                    return $"!={parameterName}";
                case EqualityType.StartsWith:
                    if (!isNegate) { return $" LIKE CONCAT({parameterName},'%')"; }
                    return $" NOT LIKE CONCAT({parameterName},'%')";
                case EqualityType.EndsWith:
                    if (!isNegate) { return $" LIKE CONCAT('%',{parameterName})"; }
                    return $" NOT LIKE CONCAT('%',{parameterName})";
                case EqualityType.Contains:
                    if (!isNegate) { return $" LIKE CONCAT('%',{parameterName},'%')"; }
                    return $" NOT LIKE CONCAT('%',{parameterName},'%')";
                case EqualityType.GreaterThan:
                    if (!isNegate) { return $">{parameterName}"; }
                    return $"<={parameterName}";
                case EqualityType.GreaterThanOrEqualTo:
                    if (!isNegate) { return $">={parameterName}"; }
                    return $"<{parameterName}";
                case EqualityType.LessThan:
                    if (!isNegate) { return $"<{parameterName}"; }
                    return $">={parameterName}";
                case EqualityType.LessThanOrEqualTo:
                    if (!isNegate) { return $"<={parameterName}"; }
                    return $">{parameterName}";
                case EqualityType.IsNull:
                    if (!isNegate) { return $" IS NULL"; }
                    return $" IS NOT NULL";
                //case EqualityType.IsInList:
                // Note:  No need for "IsInList", can just generate a set of "or"s.
                //    return $" IN({InListReplaceString}) ";
                default:
                    if (!isNegate) { return $"={parameterName}"; }
                    return $"!={parameterName}";
            }
        }

        #endregion

        #region *** Helper Methods ***

        /// <summary>
        /// Get TableName portion of SQL statement based on passed in Namespace and Name
        /// </summary>
        /// <param name="tableNamespace"></param>
        /// <param name="tableName"></param>
        /// <returns></returns>
        public static string GetTable(string tableNamespace, string tableName)
        {
            // Temp Tables and Table Variables cant have parenthesis.
            if (tableName.StartsWith("#") || tableName.StartsWith("@"))
            {
                return tableName;
            }
            if(tableNamespace != null) { tableNamespace = tableNamespace.Trim(); }
            return (string.IsNullOrEmpty(tableNamespace)) ? $"[{tableName}]" : $"[{tableNamespace}].[{tableName}]";
        }

        #endregion *** Helper Methods ***

    }




}
