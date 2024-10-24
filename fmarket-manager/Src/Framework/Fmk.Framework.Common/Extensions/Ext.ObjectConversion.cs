using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Fmk.Framework.Common.Extensions.ObjectConversion
{
    public static partial class Ext
    {

        private static string ValueTypeErrMessage = "Value '{0}' does not cast to {1}.";

        #region *** String ***

        /// <summary>
        /// Converts an object into a string. Returns string.Empty if value is null or DBNull.Value
        /// </summary>
        public static string ToSafeString(this object val)
        {
            return val.ToSafeString(string.Empty);
        }

        /// <summary>
        /// Converts an object into a string. Returns defaultVal if value is null or DBNull.Value
        /// </summary>
        public static string ToSafeString(this object val, string defaultVal)
        {
            if (val == null || val == DBNull.Value) { return defaultVal; }
            return val.ToString().Trim();
        }

        /// <summary>
        /// Converts an object into a string. Returns null if value is null or DBNull.Value
        /// </summary>
        public static string ToSafeNullString(this object val)
        {
            if (val == null || val == DBNull.Value) { return null; }
            return val.ToString().Trim();
        }

        #endregion *** String ***

        #region *** Integer ***

        /// <summary>
        /// Converts an string into an integer (Int32). If the value will not cast to an integer, 
        /// an ArgumentException is generated.
        /// </summary>
        public static int ToInt(this string val)
        {
            int testVal = val.ToSafeInt(int.MinValue);
            return (testVal == int.MinValue) ? throw new ArgumentException(string.Format(ValueTypeErrMessage, val, typeof(int).Name)) : testVal;
        }

        /// <summary>
        /// Converts an object into a integer (Int32).  Returns double.MinValue if value does not cast to integer.
        /// </summary>
        public static int ToSafeInt(this object val)
        {
            return val.ToSafeInt(int.MinValue);
        }

        /// <summary>
        /// Converts an object into an integer (Int32). Returns passed in defaultVal if value does not cast to integer.
        /// </summary>
        public static int ToSafeInt(this object val, int defaultVal = Int32.MinValue)
        {
            if (val == null || val == DBNull.Value) { return defaultVal; }

            if (val is string)
            {
                int v = defaultVal;
                string stringVal = val.ToString().Replace(",", string.Empty);
                if (int.TryParse(stringVal, out v)) { return v; }
                return defaultVal;
            }

            // Anything else, use Convert.  On error return default.
            try
            {
                return Convert.ToInt32(val);
            }
            catch (Exception)
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Converts an object into a nullable integer (Int32).  Returns null if value does not cast to integer.
        /// </summary>
        public static int? ToSafeNullInt(this object val)
        {
            int testVal = val.ToSafeInt(int.MinValue);
            if (testVal == int.MinValue) { return null; }
            return testVal;
        }

        #endregion *** Integer ***

        #region *** Long ***

        /// <summary>
        /// Converts an string into an long (Int64). If the value will not cast to a long, an
        /// ArgumentException is generated.
        /// </summary>
        public static long ToLong(this string val)
        {
            long testVal = val.ToSafeLong(long.MinValue);
            return (testVal == long.MinValue) ? throw new ArgumentException(string.Format(ValueTypeErrMessage, val, "long (Int64)")) : testVal;
        }

        /// <summary>
        /// Converts an object into a long (Int64).  Returns long.MinValue if value does not cast to long.
        /// </summary>
        public static long ToSafeLong(this object val)
        {
            return val.ToSafeLong(long.MinValue);
        }

        /// <summary>
        /// Converts an object into a long (Int64). Returns passed in defaultVal if value does not cast to long.
        /// </summary>
        public static long ToSafeLong(this object val, long defaultVal = Int64.MinValue)
        {
            if (val == null || val == DBNull.Value) { return defaultVal; }

            if (val is string)
            {
                long v = defaultVal;
                string stringVal = val.ToString().Replace(",", string.Empty);
                if (long.TryParse(stringVal, out v)) { return v; }
                else { return defaultVal; }
            }

            // Anything else, use Convert.  On error return default.
            try
            {
                return Convert.ToInt64(val);
            }
            catch (Exception)
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Converts an object into a nullable long.  Returns null if value does not cast to long.
        /// </summary>
        public static long? ToSafeNullLong(this object val)
        {
            long testVal = val.ToSafeLong(long.MinValue);
            if (testVal == long.MinValue) { return null; }
            return testVal;
        }

        #endregion *** Long ***

        #region *** Decimal ***

        /// <summary>
        /// Converts an string into a decimal. If the value will not cast to a decimal, an
        /// ArgumentException is generated.
        /// </summary>
        public static decimal ToDecimal(this string val)
        {
            decimal testVal = val.ToSafeDecimal(decimal.MinValue);
            return (testVal == decimal.MinValue) ? throw new ArgumentException(string.Format(ValueTypeErrMessage, val, typeof(decimal).Name)) : testVal;
        }

        /// <summary>
        /// Converts an object into a decimal.  Returns decimal.MinValue if value does not cast to decimal.
        /// </summary>
        public static decimal ToSafeDecimal(this object val)
        {
            return val.ToSafeDecimal(decimal.MinValue);
        }

        /// <summary>
        /// Converts an object into a decimal. Returns passed in defaultVal if value does not cast to decimal.
        /// </summary>
        public static decimal ToSafeDecimal(this object val, decimal defaultVal = decimal.MinValue)
        {
            if (val == null || val == DBNull.Value) { return defaultVal; }

            if (val is string)
            {
                decimal v = defaultVal;
                string stringVal = val.ToString().Replace("$", "").Replace(",", "");
                if (stringVal.EndsWith(".")) { return defaultVal; }
                if (decimal.TryParse(stringVal, out v))
                {
                    if (v == 0) return 0;
                    return v;
                }
                return defaultVal;
            }

            // Anything else, use Convert.  On error return default.
            try
            {
                return Convert.ToDecimal(val);
            }
            catch (Exception)
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Converts an object into a nullable decimal.  Returns null if value does not cast to decimal.
        /// </summary>
        public static decimal? ToSafeNullDecimal(this object val)
        {
            decimal testVal = val.ToSafeDecimal(decimal.MinValue);
            if (testVal == decimal.MinValue) { return null; }
            return testVal;
        }

        #endregion *** Decimal ***

        #region *** Double ***

        /// <summary>
        /// Converts an string into a double. If the value will not cast to a double, an
        /// ArgumentException is generated.
        /// </summary>
        public static double ToDouble(this string val)
        {
            double testVal = val.ToSafeDouble(double.MinValue);
            return (testVal == double.MinValue) ? throw new ArgumentException(string.Format(ValueTypeErrMessage, val, typeof(double).Name)) : testVal;
        }

        /// <summary>
        /// Converts an object into a double.  Returns double.MinValue if value does not cast to double.
        /// </summary>
        public static double ToSafeDouble(this object val)
        {
            return val.ToSafeDouble(double.MinValue);
        }

        /// <summary>
        /// Converts an object into a double.  Returns passed in defaultVal if value does not cast to double.
        /// </summary>
        public static double ToSafeDouble(this object val, double defaultVal = double.MinValue)
        {
            if (val == null || val == DBNull.Value) { return defaultVal; }

            if (val is string)
            {
                double v = defaultVal;
                string stringVal = val.ToString().Replace("$", "").Replace(",", "");
                if (double.TryParse(stringVal, out v)) { return v; }
                return defaultVal;
            }

            // Anything else, use Convert.  On error return default.
            try
            {
                return Convert.ToDouble(val);
            }
            catch (Exception)
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Converts an object into a nullable double.  Returns null if value does not cast to double.
        /// </summary>
        public static double? ToSafeNullDouble(this object val)
        {
            double testVal = val.ToSafeDouble(double.MinValue);
            if (testVal == double.MinValue) { return null; }
            return testVal;
        }

        #endregion *** Double ***

        #region *** Boolean ***

        /// <summary>
        /// Converts an string into a 'Boolean'. If the value will not cast to a Boolean, an
        /// ArgumentException is generated.
        /// </summary>
        public static bool ToBool(this string val)
        {
            if (!val.IsValidBool(false)) { throw new ArgumentException(string.Format(ValueTypeErrMessage, val, typeof(double).Name)); }
            return val.ToSafeBool();
        }

        /// <summary>
        /// Converts an object into an Boolean. Returns passed in defaultVal if value does not 
        /// cast to GUID. Default value of 'false' is used if no defaultVal argument is provided.
        /// </summary>
        public static bool ToSafeBool(this object val, bool defaultVal = false)
        {
            if (val == null || val == DBNull.Value) { return defaultVal; }

            if (val is Int32) { val = val.ToString(); }

            if (val is string)
            {
                switch (val.ToString().ToLower())
                {
                    case "0":
                    case "false":
                        return false;
                    case "1":
                    case "true":
                        return true;
                    default:
                        return defaultVal;
                }
            }

            // Anything else, use Convert.  On error return default.
            try
            {
                return Convert.ToBoolean(val);
            }
            catch (Exception)
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Converts an object into a nullable Boolean.  Returns null if value does not cast to Boolean.
        /// </summary>
        public static bool? ToNullBool(this object val)
        {
            try
            {
                return Convert.ToBoolean(val);
            }
            catch (Exception)
            {
                return null;
            }
        }

        #endregion *** Boolean ***

        #region *** DateTime ***

        /// <summary>
        /// Converts an string into a DateTime. If the value will not cast to a DateTime, an
        /// ArgumentException is generated.
        /// </summary>
        public static DateTime ToDate(this string val)
        {
            DateTime testVal = val.ToSafeDate(DateTime.MinValue);
            return (testVal == DateTime.MinValue) ? throw new ArgumentException(string.Format(ValueTypeErrMessage, val, typeof(DateTime).Name)) : testVal;
        }

        /// <summary>
        /// Converts an object into a DateTime. Returns DateTime.MinValue if value does not cast to GUID.
        /// </summary>
        public static DateTime ToSafeDate(this object val)
        {
            return val.ToSafeDate(DateTime.MinValue);
        }

        /// <summary>
        /// Converts an object into a DateTime. Returns passed in defaultVal if value does not cast to DateTime.
        /// </summary>
        public static DateTime ToSafeDate(this object val, DateTime defaultVal)
        {
            if (val == null || val is DBNull) { return defaultVal; }

            if (val is string)
            {
                if (val != null && val.ToString().StartsWith("'")) { val = val.ToString().Replace("'", ""); }
                if (val.ToString() == string.Empty) { return defaultVal; }
                DateTime dt;
                CultureInfo ci = CultureInfo.GetCultureInfo("en-US");
                List<string> datePatterns = ci.DateTimeFormat.GetAllDateTimePatterns().ToList();
                datePatterns.Add("yyyyMMdd");
                if (DateTime.TryParseExact(val.ToString(), datePatterns.ToArray(), ci, DateTimeStyles.AssumeLocal, out dt)) { return dt; }

                // Check for strange 'yyyy/MM/dd' date format.
                if (val.ToString().IndexOf('/') == 4)
                {
                    string dtStr = val.ToString().Substring(5) + "/" + val.ToString().Substring(0, 4);
                    if (DateTime.TryParse(dtStr, out dt)) { return dt; }
                }

                return defaultVal;
            }

            // Anything else, use Convert.  On error return default.
            try
            {
                return (DateTime)val;
            }
            catch
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Converts an object into a nullable DateTime.  Returns null if value does not cast to DateTime.
        /// </summary>
        public static DateTime? ToSafeNullDate(this object val)
        {
            DateTime testVal = val.ToSafeDate(DateTime.MinValue);
            if (testVal == DateTime.MinValue) { return null; }
            return testVal;
        }

        #endregion *** DateTime ***

        #region *** DateTimeOffset ***

        /// <summary>
        /// Converts an string into a 'DateTimeOffset'. If the value will not cast to a DateTimeOffset, 
        /// an ArgumentException is generated.
        /// </summary>
        public static DateTimeOffset ToDateTimeOffset(this string val)
        {
            DateTimeOffset testVal = val.ToSafeDateTimeOffset(DateTimeOffset.MinValue);
            return (testVal == DateTimeOffset.MinValue) ? throw new ArgumentException(string.Format(ValueTypeErrMessage, val, typeof(DateTimeOffset).Name)) : testVal;
        }

        /// <summary>
        /// Converts an object into a DateTimeOffset. Returns DateTime.MinValue if value does not cast to DateTimeOffset.
        /// </summary>
        public static DateTimeOffset ToSafeDateTimeOffset(this object val)
        {
            return val.ToSafeDateTimeOffset(DateTime.MinValue);
        }

        /// <summary>
        /// Converts an object into a DateTimeOffset. Returns passed in defaultVal if value does not cast to DateTimeOffset.
        /// </summary>
        public static DateTimeOffset ToSafeDateTimeOffset(this object val, DateTimeOffset defaultVal)
        {
            if (val == null || val is DBNull) { return defaultVal; }

            if (val is string)
            {
                if (val != null && val.ToString().StartsWith("'")) { val = val.ToString().Replace("'", ""); }
                if (val.ToString() == string.Empty) { return defaultVal; }
                DateTimeOffset dtOff;
                CultureInfo ci = CultureInfo.GetCultureInfo("en-US");
                string[] fmts = ci.DateTimeFormat.GetAllDateTimePatterns();
                if (DateTimeOffset.TryParseExact(val.ToString(), fmts.ToArray(), ci, DateTimeStyles.AssumeLocal, out dtOff)) { return dtOff; }

                // Check for strange 'yyyy/MM/dd' date format.
                if (val.ToString().IndexOf('/') == 4)
                {
                    string dtStr = val.ToString().Substring(5) + "/" + val.ToString().Substring(0, 4);
                    if (DateTimeOffset.TryParse(dtStr, out dtOff)) { return dtOff; }
                }

                return defaultVal;
            }

            // Anything else, use Convert.  On error return default.
            try
            {
                return (DateTimeOffset)val;
            }
            catch
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Converts an object into a nullable DateTimeOffset.  Returns null if value does not cast to DateTimeOffset.
        /// </summary>
        public static DateTimeOffset? ToSafeNullDateTimeOffset(this object val)
        {
            DateTimeOffset testVal = val.ToSafeDateTimeOffset(DateTimeOffset.MinValue);
            if (testVal == DateTimeOffset.MinValue) { return null; }
            return testVal;
        }

        #endregion *** DateTimeOffset ***

        #region *** Guid ***

        /// <summary>
        /// Converts an string into a GUID. If the value will not cast to a GUID, an 
        /// ArgumentException is generated.
        /// </summary>
        public static Guid ToGuid(this string val)
        {
            Guid testVal = val.ToSafeGuid(Guid.Empty);
            return (testVal == Guid.Empty) ? throw new ArgumentException(string.Format(ValueTypeErrMessage, val, typeof(Guid).Name)) : testVal;
        }

        /// <summary>
        /// Converts an object into a GUID.  Returns Guid.MinValue if value does not cast to GUID.
        /// </summary>
        public static Guid ToSafeGuid(this object val)
        {
            return val.ToSafeGuid(Guid.Empty);
        }

        /// <summary>
        /// Converts an object into a GUID. Returns passed in defaultVal if value does not cast to GUID.
        /// </summary>
        public static Guid ToSafeGuid(this object val, Guid defaultVal)
        {
            if (val == null || val == DBNull.Value) { return defaultVal; }

            if (val is string)
            {
                Guid v = defaultVal;
                if (Guid.TryParse(val.ToString(), out v)) { return v; }
                return defaultVal;
            }

            return defaultVal; //only a string can be converted to a GUID
        }

        /// <summary>
        /// Converts an object into a nullable GUID.  Returns null if value does not cast to GUID.
        /// </summary>
        public static Guid? ToSafeNullGuid(this object val)
        {
            Guid testVal = val.ToSafeGuid(Guid.Empty);
            if (testVal == Guid.Empty) { return null; }
            return testVal;
        }

        #endregion *** Guid ***

    }
}
