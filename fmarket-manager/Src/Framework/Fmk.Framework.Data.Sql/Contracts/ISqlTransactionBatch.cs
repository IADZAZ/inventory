using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fmk.Framework.Data.Sql.Contracts
{
    public interface ISqlTransactionBatch
    {

        /// <summary>
        /// Connection string to use for data-store interactions.
        /// </summary>
        string ConnectionString { get; set; }

        /// <summary>
        /// Override data-store interaction timeout (defaults to 30 seconds).
        /// </summary>
        int? TimeoutSeconds { get; set; }

        int SqlCommandRetrievalCount { get; }

        int ExecutionTryCount { get; }

        int ExecutionSuccessCount { get; }

        void ResetForNewTransactionBatch();

        SqlCommand GetSqlCommandToExecute();

        void Complete();

        void AboutToExecute();

        void ExecutionWasSuccessfull();
    }
}
