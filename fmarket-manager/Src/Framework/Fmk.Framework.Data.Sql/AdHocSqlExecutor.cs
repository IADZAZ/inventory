using System;
using Fmk.Framework.Data.Sql.Contracts;

namespace Fmk.Framework.Data.Sql
{
    public interface IAdHocSqlExecutor
    {
        int Insert(ISqlTransactionBatch sqlTransactionBatch, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters);
        int Insert(string connectionString, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters);
        void Update(ISqlTransactionBatch sqlTransactionBatch, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters, IList<QueryParameter> whereQueryParameters);
        void Delete(ISqlTransactionBatch sqlTransactionBatch, string tableNamespace, string tableName, IList<QueryParameter> whereQueryParameters);
        void Update(string connectionString, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters, IList<QueryParameter> whereQueryParameters);
        void Delete(string connectionString, string tableNamespace, string tableName, IList<QueryParameter> whereQueryParameters);
    }

    public class AdHocSqlExecutor : IAdHocSqlExecutor
    {
        /// <summary>
        /// Does a simple row insert using specified table name and fields/values derived from 
        /// passed in 'Value' QueryParameters.
        /// </summary>
        /// <param name="connectionString"></param>
        /// <param name="tableNamespace"></param>
        /// <param name="tableName"></param>
        /// <param name="valueQueryParameters"></param>
        /// <returns>UniqueId of inserted record</returns>
        public int Insert(string connectionString, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters)
        {
            if (string.IsNullOrEmpty(connectionString)) { throw new ArgumentNullException(nameof(connectionString)); }
            if (string.IsNullOrEmpty(tableName)) { throw new ArgumentNullException(nameof(tableName)); }
            if (valueQueryParameters == null || valueQueryParameters.Count < 1) { throw new ArgumentException("The 'valueQueryParameters' List argument must have at least one value"); }

            ISqlTransactionBatch sqlTransBatch = new SqlTransactionBatch { ConnectionString = connectionString };
            int newId = Insert(sqlTransBatch, tableNamespace, tableName, valueQueryParameters);
            sqlTransBatch.Complete();
            return newId;
        }

        /// <summary>
        /// Does a simple row insert using specified table name and fields/values derived from 
        /// passed in 'Value' QueryParameters.
        /// </summary>
        /// <param name="sqlTransactionBatch"></param>
        /// <param name="tableNamespace"></param>
        /// <param name="tableName"></param>
        /// <param name="valueQueryParameters"></param>
        /// <returns>UniqueId of inserted record</returns>
        public int Insert(ISqlTransactionBatch sqlTransactionBatch, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters)
        {
            if (sqlTransactionBatch == null) { throw new ArgumentNullException(nameof(sqlTransactionBatch)); }
            if (string.IsNullOrEmpty(tableName)) { throw new ArgumentNullException(nameof(tableName)); }
            if (valueQueryParameters == null || valueQueryParameters.Count < 1) { throw new ArgumentException("The 'valueQueryParameters' List argument must have at least one value"); }

            string sql = $"{SqlBuilder.GetInsertToTableSql(tableNamespace, tableName, valueQueryParameters)}SET @__NewId=SCOPE_IDENTITY(); ";

            QueryParameter newIdQueryParam = new(0, "@__NewId", typeof(int));
            valueQueryParameters.Add(newIdQueryParam);

            new SqlExecutor().ExecuteNonQuery(sqlTransactionBatch, sql, valueQueryParameters);

            return (int)newIdQueryParam.Value;
        }

        /// <summary>
        /// Does a simple row(s) update using specified table name and fields/values derived from 
        /// passed in 'Value' QueryParameters.  The Where clause is derived from passed in 
        /// 'Where' QueryParameters (and-ed together)
        /// </summary>
        /// <param name="connectionString"></param>
        /// <param name="tableNamespace"></param>
        /// <param name="tableName"></param>
        /// <param name="valueQueryParameters"></param>
        /// <param name="whereQueryParameters"></param>
        /// <returns>UniqueId of inserted record</returns>
        public void Update(string connectionString, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters, IList<QueryParameter> whereQueryParameters)
        {
            if (string.IsNullOrEmpty(connectionString)) { throw new ArgumentNullException(nameof(connectionString)); }
            if (string.IsNullOrEmpty(tableName)) { throw new ArgumentNullException(nameof(tableName)); }
            if (valueQueryParameters == null || valueQueryParameters.Count < 1) { throw new ArgumentException("The 'valueQueryParameters' List argument must have at least one value"); }
            if (whereQueryParameters == null || whereQueryParameters.Count < 1) { throw new ArgumentException("The 'whereQueryParameters' List argument must have at least one value"); }

            ISqlTransactionBatch sqlTransBatch = new SqlTransactionBatch { ConnectionString = connectionString };
            Update(sqlTransBatch, tableNamespace, tableName, valueQueryParameters, whereQueryParameters);
            sqlTransBatch.Complete();
        }

        /// <summary>
        /// Does a simple row(s) update using specified table name and fields/values derived from 
        /// passed in 'Value' QueryParameters.  The Where clause is derived from passed in 
        /// 'Where' QueryParameters (and-ed together)
        /// </summary>
        /// <param name="sqlTransactionBatch"></param>
        /// <param name="tableNamespace"></param>
        /// <param name="tableName"></param>
        /// <param name="valueQueryParameters"></param>
        /// <param name="whereQueryParameters"></param>
        /// <returns>UniqueId of inserted record</returns>
        public void Update(ISqlTransactionBatch sqlTransactionBatch, string tableNamespace, string tableName, IList<QueryParameter> valueQueryParameters, IList<QueryParameter> whereQueryParameters)
        {
            if (sqlTransactionBatch == null) { throw new ArgumentNullException(nameof(sqlTransactionBatch)); }
            if (string.IsNullOrEmpty(tableName)) { throw new ArgumentNullException(nameof(tableName)); }
            if (valueQueryParameters == null || valueQueryParameters.Count < 1) { throw new ArgumentException("The 'valueQueryParameters' List argument must have at least one value"); }
            if (whereQueryParameters == null || whereQueryParameters.Count < 1) { throw new ArgumentException("The 'whereQueryParameters' List argument must have at least one value"); }

            string sql = SqlBuilder.GetUpdateTableSql(tableNamespace, tableName, valueQueryParameters, whereQueryParameters);

            IList<QueryParameter> allQueryParameters = [.. valueQueryParameters];
            foreach (QueryParameter qParam in whereQueryParameters)
            {
                if (allQueryParameters.Any(x => x.Name == qParam.Name)) { throw new ApplicationException($"The QueryParameter '{qParam.Name}' can not be in both the Value and Where set."); }
                allQueryParameters.Add(qParam);
            }

            new SqlExecutor().ExecuteNonQuery(sqlTransactionBatch, sql, allQueryParameters);
        }

        /// <summary>
        /// Does a simple row(s) delete using specified table name.  The Where clause is derived
        /// from passed in 'Where' QueryParameters (and-ed together)
        /// </summary>
        /// <param name="connectionString"></param>
        /// <param name="tableNamespace"></param>
        /// <param name="tableName"></param>
        /// <param name="whereQueryParameters"></param>
        /// <returns>UniqueId of inserted record</returns>
        public void Delete(string connectionString, string tableNamespace, string tableName, IList<QueryParameter> whereQueryParameters)
        {
            if (string.IsNullOrEmpty(connectionString)) { throw new ArgumentNullException(nameof(connectionString)); }
            if (string.IsNullOrEmpty(tableName)) { throw new ArgumentNullException(nameof(tableName)); }
            if (whereQueryParameters == null || whereQueryParameters.Count < 1) { throw new ArgumentException("The 'whereQueryParameters' List argument must have at least one value"); }

            ISqlTransactionBatch sqlTransBatch = new SqlTransactionBatch { ConnectionString = connectionString };
            string sql = SqlBuilder.GetDeleteFromTableSql(tableNamespace, tableName, whereQueryParameters);
            new SqlExecutor().ExecuteNonQuery(sqlTransBatch, sql, whereQueryParameters);
            sqlTransBatch.Complete();
        }
        /// <summary>
        /// Does a simple row(s) delete using specified table name.  The Where clause is derived
        /// from passed in 'Where' QueryParameters (and-ed together)
        /// </summary>
        /// <param name="sqlTransactionBatch"></param>
        /// <param name="tableNamespace"></param>
        /// <param name="tableName"></param>
        /// <param name="whereQueryParameters"></param>
        /// <returns>UniqueId of inserted record</returns>
        public void Delete(ISqlTransactionBatch sqlTransactionBatch, string tableNamespace, string tableName, IList<QueryParameter> whereQueryParameters)
        {
            if (sqlTransactionBatch == null) { throw new ArgumentNullException(nameof(sqlTransactionBatch)); }
            if (string.IsNullOrEmpty(tableName)) { throw new ArgumentNullException(nameof(tableName)); }
            if (whereQueryParameters == null || whereQueryParameters.Count < 1) { throw new ArgumentException("The 'whereQueryParameters' List argument must have at least one value"); }

            string sql = SqlBuilder.GetDeleteFromTableSql(tableNamespace, tableName, whereQueryParameters);
            new SqlExecutor().ExecuteNonQuery(sqlTransactionBatch, sql, whereQueryParameters);
        }
    }
}
