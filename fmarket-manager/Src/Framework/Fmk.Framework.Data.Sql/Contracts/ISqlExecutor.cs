using System;
using System.Data;
using System.Xml;
using Microsoft.Data.SqlClient;

namespace Fmk.Framework.Data.Sql.Contracts
{
    public interface ISqlExecutor
    {
        /// <summary>
        /// Populate a SqlDataReader by executing passed in parameterized SQL statement.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="SqlDataReader"/></returns>
        SqlDataReader ExecuteGetReader(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Populate a SqlDataReader by executing a stored procedure.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="SqlDataReader"/></returns>
        SqlDataReader ExecuteGetReader(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Populate a DataSet by executing passed in parameterized SQL statement.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="DataSet"/></returns>
        DataSet ExecuteGetDataSet(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Populate a DataSet by executing a stored procedure.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="DataSet"/></returns>
        DataSet ExecuteGetDataSet(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Populate a <see cref="XmlDocument"/> List by executing passed in parameterized SQL 
        /// statements. Data select queries would presumably be constructed using 'FOR XML'.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="XmlDocument"/> List</returns>
        /// <exception cref="ApplicationException"></exception>
        IList<XmlDocument> ExecuteGetXmlList(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Populate a <see cref="XmlDocument"/> List by executing a stored procedure. Data 
        /// select queries would presumably be constructed using 'FOR XML'.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="XmlDocument"/> List</returns>
        /// <exception cref="ApplicationException"></exception>
        IList<XmlDocument> ExecuteGetXmlList(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Populate a <see cref="XmlDocument"/> by executing passed in parameterized SQL statement. 
        /// Data select query would presumably be constructed using 'FOR XML'. If multiple 
        /// XML result sets exist, data from the first is returned.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="XmlDocument"/></returns>
        XmlDocument ExecuteGetXml(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Populate a <see cref="XmlDocument"/> by executing a stored procedure. Data select 
        /// query would presumably be constructed using 'FOR XML'. If the stored procedure 
        /// returns multiple XML result sets, data from the first is returned.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="XmlDocument"/></returns>
        XmlDocument ExecuteGetXml(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Executes passed in parameterized SQL statement.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        void ExecuteNonQuery(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);

        /// <summary>
        /// Executes passed in stored procedure.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        void ExecuteNonQuery(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false);
    }
}
