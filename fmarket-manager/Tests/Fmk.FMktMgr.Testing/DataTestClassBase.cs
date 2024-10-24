using System;
using System.Diagnostics;
using System.Runtime.CompilerServices;


namespace Fmk.FMktMgr.Testing
{
    public class DataTestClassBase : IDisposable
    {

        #region *** Testing Initialize/Cleanup ***

        public DataTestClassBase(string testContext = "(unknown)")
        {
            // Restore needed database from dacpac (if database does not already exist). 
            bool needsInitialData = DbHelper.RestoreDatabasesIfMissing();

            // Create Initial data if its a new database. 
            if (needsInitialData) { /*TestDataGenerator.CreateInitialData();*/ }
        }

        public void Dispose()
        {
        }

        public void RunBeforeEachTest()
        {
        }

        public void RunAfterEachTest()
        {
        }

        #endregion *** Testing Initialize/Cleanup ***

        #region *** Debugging Related Methods ***

        /// <summary>
        /// Write a line to the VS Output window.
        /// </summary>
        /// <param name="message"></param>
        protected void WriteLineToOutputWindow(string message)
        {
            Debug.WriteLine(message);
        }

        /// <summary>
        /// Get's calling method's name.
        /// </summary>
        /// <returns></returns>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static string GetThisMethodName()
        {
            var st = new StackTrace(new StackFrame(1));
            return st.GetFrame(0).GetMethod().Name;
        }

        #endregion *** Debugging Related Methods ***

    }
}
