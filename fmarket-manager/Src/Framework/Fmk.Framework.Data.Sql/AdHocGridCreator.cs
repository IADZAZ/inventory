using System;
using System.Data;
using Fmk.Framework.Data.Sql.Contracts;

namespace Fmk.Framework.Data.Sql
{
    /// <summary>
    /// Used to create a "Grid" of data by populating a list of MinObjects (of type T) using ad hoc SQL.
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class AdHocGridCreator<T> : IAdHocGridCreator<T>
    {
        /// <summary>
        /// Return list of MinObjects (of type T) based on passed in ad hoc SQL. SQL column names must match
        /// object property names to facilitate mapping.
        /// </summary>
        /// <returns></returns>
        public IList<T> Get(string connectionString, string sql, IList<QueryParameter> queryParameters, int? timeoutSeconds = null)
        {
            ISqlTransactionBatch sqlTransBatch = new SqlTransactionBatch { ConnectionString = connectionString };
            if (timeoutSeconds != null) { sqlTransBatch.TimeoutSeconds = timeoutSeconds.Value; }
            IList<T> gridRows = Get(sqlTransBatch, sql, queryParameters);
            sqlTransBatch.Complete();
            return gridRows;
        }

        /// <summary>
        /// Return list of MinObjects (of type T) based on passed in ad hoc SQL. SQL column names must match
        /// object property names to facilitate mapping.
        /// </summary>
        /// <returns></returns>
        public IList<T> Get(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter> queryParameters)
        {
            // Get data (using DataSets for now)
            DataSet ds = new SqlExecutor().ExecuteGetDataSet(sqlTransactionBatch, sql, queryParameters);

            // Load up and return grid rows.
            return DataObjectBuilder.PopulateProperties<T>(ds.Tables[0]);
        }
    }
}
