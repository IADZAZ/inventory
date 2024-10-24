using System;
using Microsoft.SqlServer.Dac;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace Fmk.Framework.Data.Sql.Dac
{
    public static class SqlDatabaseRestoreUtil
    {
        /// <summary>
        /// Restore database from its dacpac if it does not exist on SQL Server instance.
        /// </summary>
        /// <param name="minConnectionString">Database connection string WITHOUT 'Data Source' or 'Database' ('Initial Catalog') parameters</param>
        /// <param name="sqlServerInstanceName">Sql Server Instance</param>
        /// <param name="databaseName">Name of database to check/create</param>
        /// <param name="dacpacPathAndName"></param>
        /// <returns>'True' if database was restored (was missing)</returns>
        public static bool RestoreDatabaseIfMissing(string minConnectionString, string sqlServerInstanceName, string databaseName, string dacpacPathAndName)
        {
            ValidateConnectionString(minConnectionString);

            bool dbExists = DoesDatabaseExist(minConnectionString, sqlServerInstanceName, databaseName);
            if (!dbExists)
            {
                RestoreDatabase(minConnectionString, sqlServerInstanceName, databaseName, dacpacPathAndName, false);
            }
            return (!dbExists);
        }

        public static bool DoesSqlServerInstanceExist(string minConnectionString, string sqlServerInstanceName)
        {
            // Can't have timeout info in minConnectionString.
            if (minConnectionString.Contains("Timeout="))
            {
                throw new ApplicationException($"When checking if database instance exists, {minConnectionString} can not contain timeout information.");
            }

            // Just checking if the database exists, need to provide a minimal timeout.
            minConnectionString += "; Connection Timeout=1";

            ValidateConnectionString(minConnectionString);

            SqlTransactionBatch con = new()
            {
                ConnectionString = $"Data Source={sqlServerInstanceName}; Database=master; {minConnectionString}; Connection Timeout=1",
                TimeoutSeconds = 1
            };

            // Does Db exist?
            try
            {
                string dbExistsSql = "SELECT TOP 1 [dbid] FROM [master].[dbo].[sysdatabases];";
                var ds = new SqlExecutor().ExecuteGetDataSet(con, dbExistsSql, null, true);
                return true;
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("The server was not found or was not accessible.")) { return false; }
                throw ex;
            }
        }

        /// <summary>
        /// Does database exist on SQL Server instance.
        /// </summary>
        /// <param name="minConnectionString">Database connection string WITHOUT 'Data Source' or 'Database' ('Initial Catalog') parameters</param>
        /// <param name="sqlServerInstanceName">Sql Server Instance</param>
        /// <param name="databaseName">Name of database to check</param>
        /// <returns></returns>
        public static bool DoesDatabaseExist(string minConnectionString, string sqlServerInstanceName, string databaseName)
        {
            ValidateConnectionString(minConnectionString);

            SqlTransactionBatch con = new()
            {
                ConnectionString = $"Data Source={sqlServerInstanceName}; Database=master; {minConnectionString}",
                TimeoutSeconds = 1
            };

            // Does Db exist?
            string dbExistsSql = $"SELECT [dbid] FROM [master].[dbo].[sysdatabases] WHERE [name]='{databaseName}';";
            var ds = new SqlExecutor().ExecuteGetDataSet(con, dbExistsSql, null, true);
            return (ds.Tables[0].Rows.Count > 0);
        }

        /// <summary>
        /// Restore database from its dacpac.
        /// </summary>
        /// <param name="minConnectionString">Database connection string WITHOUT 'Data Source' or 'Database' ('Initial Catalog') parameters</param>
        /// <param name="sqlServerInstanceName">Sql Server Instance</param>
        /// <param name="databaseName">Name of database to create</param>
        /// <param name="dacpacPathAndName"></param>
        /// <param name="upgradeExistingDb"></param>
        public static void RestoreDatabase(string minConnectionString, string sqlServerInstanceName, string databaseName, string dacpacPathAndName, bool upgradeExistingDb = false)
        {
            ValidateConnectionString(minConnectionString);

            //string executingLocation = Path.GetDirectoryName(Assembly.GetExecutingAssembly().CodeBase.Replace(@"file:///", string.Empty).Replace(@"FILE:///", string.Empty));
            //string startPath = executingLocation.Substring(0, executingLocation.IndexOf(@"tests") - 1);

            // Verify dacpac exists.
            if (!File.Exists(dacpacPathAndName))
            {
                throw new ApplicationException($"dacpac '{dacpacPathAndName}' could not be found.'");
            }

            // Restore Database.
            try
            {
                // Use DacServices to load it (NuGet - 'Microsoft.SqlServer.DacFX' - NOT x86 or x64) v150.4573.2 finally worked.
                var dacpac = DacPackage.Load(dacpacPathAndName);
                //var dbDeployOptions = new DacDeployOptions { BlockOnPossibleDataLoss = false };

                string connectionString = $"Data Source={sqlServerInstanceName}; Database={databaseName}; {minConnectionString}";
                var dbServices = new DacServices(connectionString);
                dbServices.Deploy(dacpac, databaseName, upgradeExistingDb);
            }
            catch (Exception ex)
            {
                throw new ApplicationException($"Error restoring database '{databaseName}' from dacpac '{dacpacPathAndName}'.", ex);
            }
        }

        /// <summary>
        /// Validate that passed in connection string does not contain 'Data Source', 'Database', or 
        /// 'Initial Catalog' parameters
        /// </summary>
        /// <param name="minConnectionString">Database connection string WITHOUT 'Data Source' or 'Database' ('Initial Catalog') parameters</param>
        private static void ValidateConnectionString(string minConnectionString)
        {
            if (minConnectionString.Contains("Data Source") || minConnectionString.Contains("Database") || minConnectionString.Contains("Initial Catalog"))
            {
                throw new ApplicationException($"Provided connection string ({nameof(minConnectionString)}) can not contain 'Data Source', 'Database', or 'Initial Catalog' parameters");
            }
        }
    }
}
