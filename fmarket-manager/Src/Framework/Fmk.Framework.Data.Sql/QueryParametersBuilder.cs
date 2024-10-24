using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml;

namespace Fmk.Framework.Data.Sql
{
    /// <summary>
    /// Utility used to build a list of QueryParameters to be passed along with a SQL statement
    /// to SqlExecutor.
    /// </summary>
    public class QueryParametersBuilder
    {

        #region *** Public Properties ***

        public List<QueryParameter> QueryParameters { get; } = [];

        #endregion // *** Public Properties ***

        #region *** Parameter Add Methods (Public) ***

        /// <summary>
        /// Add a stored procedure return value parameter to the collection.
        /// Note:  Special case - When this QueryParameter is converted to a SqlParameter, SqlExecutor will
        /// set ParameterDirection to 'ReturnValue' based on its name ("@return_value").
        /// </summary>
        public void AddStoredProcReturnValueParameter()
        {
            QueryParameters.Add(new QueryParameter(NextIndex, "@return_value", typeof(int)));
        }

        /// <summary>
        /// Add a String Input parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterSize">Parameter's size (since it is a string)</param>
        public void AddStringInParameter(string parameterName, int parameterSize, string parameterValue)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(string), parameterSize));
        }

        /// <summary>
        /// Add a String Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterSize">Parameter's size (since it is a string)</param>
        public void AddStringOutParameter(string parameterName, int parameterSize)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(string), parameterSize));
        }

        /// <summary>
        /// Add a Text Input parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddTextInParameter(string parameterName, string parameterValue)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(string)));
        }

        /// <summary>
        /// Add a Text Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddTextOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(string)));
        }

        /// <summary>
        /// Add an Integer Input parameter to the collection (can pass int.MinValue to represent null).
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddIntegerInParameter(string? parameterName, int? parameterValue)
        {
            if (parameterValue == int.MinValue) { parameterValue = null; }
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(int)));
        }

        /// <summary>
        /// Add an Integer Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddIntegerOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(int)));
        }

        /// <summary>
        /// Add a Long Input parameter to the collection (can pass long.MinValue to represent null).
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddLongInParameter(string parameterName, long? parameterValue)
        {
            if (parameterValue == long.MinValue) { parameterValue = null; }
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(long)));
        }

        /// <summary>
        /// Add a Long Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddLongOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(long)));
        }
        
        /// <summary>
        /// Add a Double Input parameter to the collection (can pass double.MinValue to represent null).
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddDoubleInParameter(string parameterName, double? parameterValue)
        {
            if (parameterValue == double.MinValue) { parameterValue = null; }
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(double)));
        }
        
        /// <summary>
        /// Add a Double Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddDoubleOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(double)));
        }

        /// <summary>
        /// Add a Decimal Input parameter to the collection (can pass decimal.MinValue to represent null).
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddDecimalInParameter(string parameterName, decimal? parameterValue)
        {
            if (parameterValue == decimal.MinValue) { parameterValue = null; }
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(decimal)));
        }

        /// <summary>
        /// Add a Decimal Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddDecimalOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(decimal)));
        }

        /// <summary>
        /// Add a Boolean Input parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddBooleanInParameter(string parameterName, bool? parameterValue)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(bool)));
        }
        
        /// <summary>
        /// Add a Boolean Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddBoolOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(bool)));
        }

        /// <summary>
        /// Add a DateTime Input parameter to the collection (can pass DateTime.MinValue to represent null).
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddDateTimeInParameter(string parameterName, DateTime? parameterValue)
        {
            if (parameterValue == DateTime.MinValue) { parameterValue = null; }
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(DateTime)));
        }

        /// <summary>
        /// Add a DateTime Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddDateTimeOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(DateTime)));
        }

        /// <summary>
        /// Add an XML Input parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        /// <param name="parameterValue">Parameter's value</param>
        public void AddXmlInParameter(string parameterName, string parameterValue)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, parameterValue, typeof(XmlElement)));
        }
        
        /// <summary>
        /// Add an XML Output parameter to the collection.
        /// </summary>
        /// <param name="parameterName">Parameter's name</param>
        public void AddXmlOutParameter(string parameterName)
        {
            QueryParameters.Add(new QueryParameter(NextIndex, parameterName, typeof(XmlElement)));
        }

        #endregion //  *** Parameter Add Methods (Public) ***

        #region *** Private Helper Methods ***

        private int NextIndex
        {
            get
            {
                return (QueryParameters.Count < 1) ? 0 : QueryParameters.Max(x => x.Index) + 1;
            }

        }

        #endregion //  *** Private Helper Methods ***

    }
}
