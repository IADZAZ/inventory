using System;
using System.Collections.Generic;
using System.Text;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {

        /// <summary>
        /// Exception's concatenated Message (Message and any inner Exception Messages) 
        /// </summary>
        /// <param name="exception">The exception.</param>
        /// <param name="delimiter">What character(s) to use to separate each execution level</param>
        public static string Flatten(this Exception exception, string delimiter = "; ")
        {
            string errMsg = exception.Message;
            Exception exc = exception;
            while (exc.InnerException != null)
            {
                errMsg += delimiter + exception.InnerException;
                exc = exc.InnerException;
            }
            return errMsg;
        }

        /// <summary>
        /// Exception's concatenated Message (Message and any inner Exception Messages) 
        /// </summary>
        /// <param name="exception">The exception.</param>
        /// <param name="delimiter">What character(s) to use to separate each execution level</param>
        public static string MessageDeep(this Exception exception, string delimiter = "; ")
        {
            StringBuilder sb = new StringBuilder();
            Exception ex = exception;
            sb.Append(ex.Message);
            while (ex.InnerException != null)
            {
                ex = ex.InnerException;
                sb.Append($"{delimiter}{ex.Message}");
            }
            sb.Append($" [{ex.GetType().Name}]");
            return sb.ToString();
        }
    }
}
