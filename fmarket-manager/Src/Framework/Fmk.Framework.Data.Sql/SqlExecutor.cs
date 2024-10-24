using System;
using System.Data;
using System.Text;
using System.Xml;
using Microsoft.Data.SqlClient;
using Fmk.Framework.Data.Sql.Contracts;

namespace Fmk.Framework.Data.Sql
{
    public class SqlExecutor : ISqlExecutor
    {

        #region *** ISqlExecutor Implementation ***

        /// <summary>
        /// Populate a SqlDataReader by executing passed in parameterized SQL statement.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="SqlDataReader"/></returns>
        public SqlDataReader ExecuteGetReader(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, sql, false, queryParameters);
            SqlDataReader sqlDataReader = ExecuteGetReader(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters);
            return sqlDataReader;
        }

        /// <summary>
        /// Populate a SqlDataReader by executing a stored procedure.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="SqlDataReader"/></returns>
        public SqlDataReader ExecuteGetReader(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, GetStoredProcedureCommandText(storedProcNamespace, storedProcName), true, queryParameters);
            SqlDataReader sqlDataReader = ExecuteGetReader(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters); //Stored Procedures support output parameters: Populate from executed SqlCommand.
            return sqlDataReader;
        }

        /// <summary>
        /// Populate a DataSet by executing passed in parameterized SQL statement.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="DataSet"/></returns>
        public DataSet ExecuteGetDataSet(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, sql, false, queryParameters);
            DataSet dataSet = ExecuteGetDataSet(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters);
            return dataSet;
        }

        /// <summary>
        /// Populate a DataSet by executing a stored procedure.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        /// <returns><see cref="DataSet"/></returns>
        public DataSet ExecuteGetDataSet(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, GetStoredProcedureCommandText(storedProcNamespace, storedProcName), true, queryParameters);
            DataSet dataSet = ExecuteGetDataSet(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters);//Stored Procedures support output parameters: Populate from executed SqlCommand.
            return dataSet;
        }

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
        public IList<XmlDocument> ExecuteGetXmlList(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, sql, isForStoredProcedure: false, queryParameters);
            SqlDataReader sqlDataReader = ExecuteGetReader(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters);
            try
            {
                return GetXmlFromSqlDataReader(sqlDataReader);
            }
            catch (Exception innerException)
            {
                throw new ApplicationException("Error populating XmlDocument using SqlDataReader.", innerException);
            }
            finally
            {
                if (!sqlDataReader.IsClosed) { sqlDataReader.Close(); }
            }
        }

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
        public IList<XmlDocument> ExecuteGetXmlList(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, GetStoredProcedureCommandText(storedProcNamespace, storedProcName), isForStoredProcedure: true, queryParameters);
            SqlDataReader sqlDataReader = ExecuteGetReader(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters);
            try
            {
                return GetXmlFromSqlDataReader(sqlDataReader);
            }
            catch (Exception innerException)
            {
                throw new ApplicationException("Error populating XmlDocument using SqlDataReader.", innerException);
            }
            finally
            {
                if (!sqlDataReader.IsClosed) { sqlDataReader.Close(); }
            }
        }

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
        public XmlDocument ExecuteGetXml(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            IList<XmlDocument> list = ExecuteGetXmlList(sqlTransactionBatch, sql, queryParameters, completeTransaction);
            if (list.Count < 1) { return null; }
            return list[0];
        }

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
        public XmlDocument ExecuteGetXml(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            IList<XmlDocument> list = ExecuteGetXmlList(sqlTransactionBatch, storedProcNamespace, storedProcName, queryParameters, completeTransaction);
            if (list.Count < 1) { return null; }
            return list[0];
        }

        /// <summary>
        /// Executes passed in parameterized SQL statement.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="sql">Parameterized SQL statement to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        public void ExecuteNonQuery(ISqlTransactionBatch sqlTransactionBatch, string sql, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, sql, false, queryParameters);
            ExecuteNonQuery(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters);
        }

        /// <summary>
        /// Executes passed in stored procedure.
        /// </summary>
        /// <param name="sqlTransactionBatch">Provides Connection/Transaction</param>
        /// <param name="storedProcNamespace">Namespace of the stored procedure to execute</param>
        /// <param name="storedProcName">Name of the stored procedure to execute</param>
        /// <param name="queryParameters">Parameters for passed in Parameterized SQL statement</param>
        /// <param name="completeTransaction">Parameters for passed in Parameterized SQL statement</param>
        public void ExecuteNonQuery(ISqlTransactionBatch sqlTransactionBatch, string storedProcNamespace, string storedProcName, IList<QueryParameter>? queryParameters = null, bool completeTransaction = false)
        {
            SqlCommand sqlCommand = GetSqlCommand(sqlTransactionBatch, GetStoredProcedureCommandText(storedProcNamespace, storedProcName), true, queryParameters);
            ExecuteNonQuery(sqlTransactionBatch, sqlCommand, completeTransaction);
            PopulateOutputParameterValues(sqlCommand, queryParameters);//Stored Procedures support output parameters: Populate from executed SqlCommand.
        }

        #endregion //  *** ISqlExecutor Implementation ***

        #region *** Private Execution Methods ***

        private SqlDataReader ExecuteGetReader(ISqlTransactionBatch sqlTransactionBatch, SqlCommand sqlCommand, bool completeTransaction)
        {
            SqlDataReader sqlDataReader = null;
            try
            {
                sqlTransactionBatch.AboutToExecute();
                sqlDataReader = sqlCommand.ExecuteReader();
                sqlTransactionBatch.ExecutionWasSuccessfull();
                if (completeTransaction) { sqlTransactionBatch.Complete(); }
                return sqlDataReader;
            }
            catch (Exception ex)
            {
                sqlTransactionBatch.Complete();
                throw ex;
            }
        }

        private DataSet ExecuteGetDataSet(ISqlTransactionBatch sqlTransactionBatch, SqlCommand sqlCommand, bool completeTransaction)
        {
            DataSet dataSet = new();
            try
            {
                sqlTransactionBatch.AboutToExecute();
                new SqlDataAdapter(sqlCommand).Fill(dataSet);
                sqlTransactionBatch.ExecutionWasSuccessfull();
                if (completeTransaction) { sqlTransactionBatch.Complete(); }
                return dataSet;
            }
            catch (Exception ex)
            {
                sqlTransactionBatch.Complete();
                throw ex;
            }
        }

        private void ExecuteNonQuery(ISqlTransactionBatch sqlTransactionBatch, SqlCommand sqlCommand, bool completeTransaction)
        {
            try
            {
                sqlTransactionBatch.AboutToExecute();
                sqlCommand.ExecuteNonQuery();
                sqlTransactionBatch.ExecutionWasSuccessfull();
                if (completeTransaction) { sqlTransactionBatch.Complete(); }
            }
            catch (Exception ex)
            {
                sqlTransactionBatch.Complete();
                throw ex;
            }
        }

        #endregion // *** Private Execution Methods ***

        #region *** Private Helper Methods ***

        private string GetStoredProcedureCommandText(string storedProcNamespace, string storedProcName)
        {
            if(storedProcNamespace == null) { storedProcNamespace = "dbo"; }
            if (storedProcName == null) { throw new ArgumentNullException(nameof(storedProcName)); }
            storedProcNamespace = storedProcNamespace.Replace("[", "").Replace("]", "");
            storedProcName = storedProcName.Replace("[", "").Replace("]", "");
            return $"[{storedProcNamespace}].[{storedProcName}]";
        }

        private SqlCommand GetSqlCommand(ISqlTransactionBatch sqlTransactionBatch, string commandText, bool isForStoredProcedure, IList<QueryParameter>? queryParameters = null)
        {
            // Get a SqlCommand initialized with Connection/Transaction from SqlTransactionBatch.
            SqlCommand sqlCommand = sqlTransactionBatch.GetSqlCommandToExecute();
            sqlCommand.CommandText = commandText;
            if (isForStoredProcedure) { sqlCommand.CommandType = CommandType.StoredProcedure;}
            
            if (queryParameters != null && queryParameters.Count > 0)
            {
                foreach (QueryParameter queryParameter in queryParameters)
                {
                    SqlParameter sqlParameter = new SqlParameter
                    {
                        ParameterName = queryParameter.Name,
                        Value = queryParameter.Value ?? DBNull.Value,
                        DbType = SqlBuilder.GetDbType(queryParameter.EntityDataType)
                    };
                    sqlParameter.Direction = (queryParameter.IsOutput) ? ParameterDirection.Output : ParameterDirection.Input;
                    if(queryParameter.EntityDataType == typeof(int) && queryParameter.Name == "@return_value") { sqlParameter.Direction = ParameterDirection.ReturnValue; }
                    sqlCommand.Parameters.Add(sqlParameter);
                }
            }
            return sqlCommand;
        }

        private void PopulateOutputParameterValues(SqlCommand sqlCommand, IList<QueryParameter>? queryParameters)
        {
            if (queryParameters == null) { return; }

            foreach (QueryParameter qParam in queryParameters.Where(x => x.IsOutput))
            {
                if(sqlCommand.Parameters.Contains(qParam.Name))
                {
                    qParam.Value = sqlCommand.Parameters[qParam.Name].Value;
                }
            }
        }

        /// <summary>
        /// Read string XML data from SqlDataReader (has multiple single column rows if is
        /// too long) and return a populated list of System.Xml.XmlDocuments.
        /// </summary>
        /// <param name="sqlDataReader"></param>
        /// <param name="emptyResultSetTolerance"></param>
        /// <returns>List of XmlDocuments</returns>
        /// <exception cref="ArgumentNullException"></exception>
        private IList<XmlDocument> GetXmlFromSqlDataReader(SqlDataReader sqlDataReader, int emptyResultSetTolerance = 10)
        {
            List<XmlDocument> list = [];
            int num = 0;
            if (sqlDataReader.HasRows)
            {
                while (sqlDataReader.HasRows)
                {
                    num++;
                    StringBuilder stringBuilder = new StringBuilder();
                    if (sqlDataReader.FieldCount > 1 || sqlDataReader.FieldCount < 1 || sqlDataReader.GetFieldType(0) != typeof(string))
                    {
                        throw new ArgumentNullException(string.Format("Problem loading returned XML data from {0} (ResultSet {1}) - expecting a single nvarchar (string) column for XML data.", "SqlDataReader", num));
                    }

                    while (sqlDataReader.Read())
                    {
                        stringBuilder.Append((string)sqlDataReader[0]);
                    }

                    try
                    {
                        XmlDocument xmlDocument = new XmlDocument();
                        xmlDocument.LoadXml(stringBuilder.ToString());
                        list.Add(xmlDocument);
                    }
                    catch (Exception innerException)
                    {
                        throw new ArgumentNullException(string.Format("Problem loading result XML from {0} string to {1} (ResultSet {2})", "SqlDataReader", "XmlDocument", num), innerException);
                    }

                    sqlDataReader.NextResult();
                    for (int i = 0; !sqlDataReader.HasRows && i < emptyResultSetTolerance; i++)
                    {
                        sqlDataReader.NextResult();
                    }
                }
            }

            return list;
        }

        #endregion // *** Private Helper Methods ***

    }
}
