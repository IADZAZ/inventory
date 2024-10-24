using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Fmk.FMktMgr.Testing
{
    public class TestHelper
    {
        public static string ExecutingLocation => Path.GetDirectoryName(Assembly.GetExecutingAssembly().CodeBase.Replace(@"file:///", string.Empty).Replace(@"FILE:///", string.Empty));
        public static string TestingProjectName => Assembly.GetCallingAssembly().GetName().Name;
        public static string BaseProjectPath => ExecutingLocation.Substring(0, ExecutingLocation.IndexOf(@"Tests") - 1);
        public static string BaseTestingPath => $@"{BaseProjectPath}\Tests";
        public static string BaseDatabasePath => $@"{BaseProjectPath}\Data";

        public static string LoggingDatabaseProjectName => TestingProjectName.Replace("FMktMgr.Testing", "Logging.Database");
        public static string DatabaseProjectName => TestingProjectName.Replace(".Testing", ".Database");
        

    }
}
