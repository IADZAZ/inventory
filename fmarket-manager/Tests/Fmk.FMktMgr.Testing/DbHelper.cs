using Fmk.Framework.Data.Sql.Dac;

namespace Fmk.FMktMgr.Testing
{
    public static class DbHelper
    {
        public static string SqlServerInstanceName { get; set; } = "(local)";
        public static string DatabaseName => "FMktMgr_TestDb";
        public static string LoggingDatabaseName => "Logging_TestDb";
        public static string ConnectionParameterString => "Integrated Security=SSPI; TrustServerCertificate=true;";
        public static string DbConnectionString => $"Data Source={SqlServerInstanceName}; Initial Catalog={DatabaseName}; {ConnectionParameterString}";


        /// <summary>
        /// Restore database from its dacpac if it does not exist on SQL Server instance.
        /// </summary>
        /// <returns>'True' if database was restored (was missing)</returns>
        public static bool RestoreDatabasesIfMissing()
        {
            string dacpacLocation;
            string dacpacName;


            dacpacLocation = $@"{TestHelper.BaseDatabasePath}\{TestHelper.LoggingDatabaseProjectName}\Snapshots";
            dacpacName = $"{TestHelper.LoggingDatabaseProjectName}.dacpac";
            bool logDbWasRestored = SqlDatabaseRestoreUtil.RestoreDatabaseIfMissing(ConnectionParameterString, SqlServerInstanceName, LoggingDatabaseName,
                $@"{dacpacLocation}\{dacpacName}");
                
            dacpacLocation = $@"{TestHelper.BaseDatabasePath}\{TestHelper.DatabaseProjectName}\Snapshots";
            dacpacName = $"{TestHelper.DatabaseProjectName}.dacpac";
            bool dbWasRestored = SqlDatabaseRestoreUtil.RestoreDatabaseIfMissing(ConnectionParameterString, SqlServerInstanceName, DatabaseName,
                $@"{dacpacLocation}\{dacpacName}");
            return dbWasRestored;

        }


    }
}