using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {
        /// <summary>
        /// Parses string to the given enum
        /// </summary>
        public static TEnum ParseEnum<TEnum>(this string str, bool ignoreCase = true) where TEnum : struct
        {
            if (str == null) { throw new ArgumentNullException(nameof(str)); }

            if (!Enum.IsDefined(typeof(TEnum), str)) { throw new ArgumentException($"The string value '{str}' is not defined in the enumeration '{typeof(TEnum).Name}'."); }

            return (TEnum)Enum.Parse(typeof(TEnum), str, ignoreCase);
        }

        /// <summary>
        /// Parses int to the given enum
        /// </summary>
        public static TEnum ParseEnum<TEnum>(this int val) where TEnum : struct
        {
            if (!Enum.IsDefined(typeof(TEnum), val)) { throw new ArgumentException($"The integer value '{val}' is not defined in the enumeration '{typeof(TEnum).Name}'."); }

            return (TEnum)Enum.Parse(typeof(TEnum), val.ToString(CultureInfo.CurrentCulture), true);
        }
    }
}
