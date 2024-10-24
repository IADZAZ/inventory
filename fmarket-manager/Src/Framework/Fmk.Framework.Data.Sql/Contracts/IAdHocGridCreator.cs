using System;

namespace Fmk.Framework.Data.Sql.Contracts
{
    /// <summary>
    /// Used to create a "Grid" of data by populating a list of MinObjects (of type T) using ad hoc SQL.
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public interface IAdHocGridCreator<T>
    {
        /// <summary>
        /// Return list of MinObjects (of type T) based on passed in ad hoc SQL. SQL column names must match
        /// object property names to facilitate mapping.
        /// </summary>
        /// <returns></returns>
        IList<T> Get(string connectionString, string sql, IList<QueryParameter> queryParameters, int? timeoutSeconds = null);

        /// <summary>
        /// Return list of MinObjects (of type T) based on passed in ad hoc SQL. SQL column names must match
        /// object property names to facilitate mapping.
        /// </summary>
        /// <returns></returns>
        IList<T> Get(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter> queryParameters);
    }

}
