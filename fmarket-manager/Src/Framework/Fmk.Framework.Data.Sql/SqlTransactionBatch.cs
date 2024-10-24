using System;
using System.Data;
using Microsoft.Data.SqlClient;
using Fmk.Framework.Data.Sql.Contracts;

namespace Fmk.Framework.Data.Sql
{
    public class SqlTransactionBatch : ISqlTransactionBatch
    {

        #region *** Fields ***

        private SqlConnection? _sqlConnection = null;
        private SqlTransaction? _sqlTransaction = null;

        #endregion //  *** Fields ***

        /// <summary>
        /// Connection string to use for data-store interactions.
        /// </summary>

        public string ConnectionString { get; set; }

        /// <summary>
        /// Override data-store interaction timeout (defaults to 30 seconds).
        /// </summary>
        public int? TimeoutSeconds { get; set; }

        public int SqlCommandRetrievalCount { get; private set; }

        public int ExecutionTryCount { get; private set; }

        public int ExecutionSuccessCount { get; private set; } = 0;

        public void ResetForNewTransactionBatch()
        {
            _sqlConnection = null;
            _sqlTransaction = null;
            SqlCommandRetrievalCount = 0;
            ExecutionTryCount = 0;
            ExecutionSuccessCount = 0;
        }

        public SqlCommand GetSqlCommandToExecute()
        {
            ManageConnection();

            SqlCommand sqlCommand = new()
            {
                Connection = _sqlConnection,
                Transaction = _sqlTransaction,
                CommandType = CommandType.Text
            };
            if (TimeoutSeconds.HasValue)
            {
                sqlCommand.CommandTimeout = TimeoutSeconds.Value;
            }

            return sqlCommand;
        }


        private void ManageConnection()
        {
            if (ExecutionTryCount > ExecutionSuccessCount)
            {
                throw new Exception($"Can not provide SqlConnection:  There is a previous error against this data-store transaction. ");
            }

            if (ConnectionString == null)
            {
                throw new Exception("Can not provide SqlConnection:  ConnectionString was not provided.");
            }

            if (_sqlConnection == null)
            {
                _sqlConnection = new SqlConnection(ConnectionString);
                _sqlConnection.Open();
                _sqlTransaction = _sqlConnection.BeginTransaction();
            }
            else
            {
                if (_sqlConnection.ConnectionString != ConnectionString)
                {
                    throw new Exception($"Attempting to utilize a transaction against different connections.  Original Connection '{_sqlConnection.ConnectionString}', 'Current Connection '{ConnectionString}'.  If you are providing a connection string with a password clause, you will need to include the 'Persist Security Info=False;' clause also.");
                }

                if (_sqlConnection.State != 0)
                {
                    return;
                }

                throw new Exception("Can not continue transaction, the connection is closed.");
            }
        }
        
        public void AboutToExecute()
        {
            ExecutionTryCount++;
        }

        public void ExecutionWasSuccessfull()
        {
            ExecutionSuccessCount++;
        }

        public void Complete()
        {
            if (_sqlConnection != null)
            {
                if (ExecutionTryCount == ExecutionSuccessCount)
                {
                    _sqlTransaction?.Commit();
                }
                else
                {
                    _sqlTransaction?.Rollback();
                }

                _sqlConnection?.Close();
                _sqlConnection = null;
            }
        }
    }
}
