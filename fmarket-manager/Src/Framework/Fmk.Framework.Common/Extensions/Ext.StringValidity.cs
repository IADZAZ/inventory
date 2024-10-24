using System;
using Fmk.Framework.Common.Extensions.ObjectConversion;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a Integer.
        /// If AllowBlank argument is set to 'True', null and blank values will be allowed.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank">'True' if null or blank value should return 'True'</param>
        /// <returns></returns>
        public static bool IsValidInt(this string val, bool allowBlank)
        {
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val.ToSafeInt() == Int32.MinValue) { return false; }
            return true;
        }

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a Long.
        /// If AllowBlank argument is set to 'True', null and blank values will be allowed.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank">'True' if null or blank value should return 'True'</param>
        /// <returns></returns>
        public static bool IsValidLong(this string val, bool allowBlank)
        {
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val.ToSafeLong() == Int64.MinValue) { return false; }
            return true;
        }

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a Decimal.
        /// If AllowBlank argument is set to 'True', null and blank values will be allowed.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank">'True' if null or blank value should return 'True'</param>
        /// <returns></returns>
        public static bool IsValidDecimal(this string val, bool allowBlank)
        {
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val.ToSafeDecimal() == decimal.MinValue) { return false; }
            return true;
        }

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a Double.
        /// If AllowBlank argument is set to 'True', null and blank values will be allowed.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank">'True' if null or blank value should return 'True'</param>
        /// <returns></returns>
        public static bool IsValidDouble(this string val, bool allowBlank)
        {
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val.ToSafeDouble() == Double.MinValue) { return false; }
            return true;
        }

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a Boolean ("0", "1", 
        /// "true" or "false").
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank"></param>
        /// <returns></returns>
        public static bool IsValidBool(this string val, bool allowBlank)
        {
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val == "0") { return true; }
            if (val == "1") { return true; }
            if (val.ToLower() == "true") { return true; }
            if (val.ToLower() == "false") { return true; }
            return false;
        }

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a DateTime.
        /// If AllowBlank argument is set to 'True', null and blank values will be allowed.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank">'True' if null or blank value should return 'True'</param>
        /// <returns></returns>
        public static bool IsValidDate(this string val, bool allowBlank)
        {
            if (val != null && val.StartsWith("'")) { val = val.Replace("'", ""); }
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val.ToSafeDate(DateTime.MinValue) == DateTime.MinValue) { return false; }
            return true;
        }

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a DateTimeOffset.
        /// If AllowBlank argument is set to 'True', null and blank values will be allowed.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank">'True' if null or blank value should return 'True'</param>
        /// <returns></returns>
        public static bool IsValidDateTimeOffset(this string val, bool allowBlank)
        {
            if (val != null && val.StartsWith("'")) { val = val.Replace("'", ""); }
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val.ToSafeDateTimeOffset(DateTimeOffset.MinValue) == DateTimeOffset.MinValue) { return false; }
            return true;
        }

        /// <summary>
        /// Returns 'True' if passed in value (sting) can be converted to a GUID.
        /// If AllowBlank argument is set to 'True', null and blank values will be allowed.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="allowBlank">'True' if null or blank value should return 'True'</param>
        /// <returns></returns>
        public static bool IsValidGuid(this string val, bool allowBlank)
        {
            if ((val == null) || (val.Trim() == string.Empty)) { return (allowBlank); }
            if (val.ToSafeGuid(Guid.Empty) == Guid.Empty) { return false; }
            return true;
        }

    }
}
