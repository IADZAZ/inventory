using System;
using System.Collections.Generic;
using System.Linq;

namespace Fmk.Framework.Common.Utils
{
    public static partial class Util
    {

        public static IEnumerable<TEnum> GetValues<TEnum>() where TEnum : struct
        {
            return Enum.GetValues(typeof(TEnum)).Cast<TEnum>();
        }

        public static List<string> GetValuesAsStringList<TEnum>() where TEnum : struct
        {
            return GetValues<TEnum>().Select(v => v.ToString()).ToList();
        }

    }
}
