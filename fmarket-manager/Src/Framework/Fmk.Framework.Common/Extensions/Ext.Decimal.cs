using System;
using System.Collections.Generic;
using System.Text;
using Fmk.Framework.Common.Utils;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {

        /// <summary>
        /// Round decimal to the specified DecimalPlaces.  x.55 and above rounds up to x.6, x.54 and below rounds down 
        /// to x5. if a negative value for DecimalPlaces is passed in, 0 is used.
        /// </summary>
        /// <param name="number">Decimal to round</param>
        /// <param name="decimalPlaces">Number of DecimalPlaces to round to</param>
        /// <returns></returns>
        public static decimal RoundAtMidpoint(this decimal number, int decimalPlaces)
        {
            return Util.RoundAtMidpoint(number, decimalPlaces);
        }

        /// <summary>
        /// Round up decimal to the specified DecimalPlaces.  x.51 and above rounds up to x.6.
        /// </summary>
        /// <param name="number">Decimal to round</param>
        /// <param name="decimalPlaces">Number of DecimalPlaces to round to</param>
        /// <returns>A decimal rounded up to the specified DecimalPlaces</returns>
        public static decimal RoundUp(this decimal number, int decimalPlaces)
        {
            return Util.RoundUp(number, decimalPlaces);
        }

        /// <summary>
        /// Round down decimal to the specified DecimalPlaces.  x.59 and below rounds down to x5.
        /// </summary>
        /// <param name="number">Decimal to round</param>
        /// <param name="decimalPlaces">Number of DecimalPlaces to round to</param>
        /// <returns>A decimal rounded down to the specified DecimalPlaces</returns>
        public static decimal RoundDown(this decimal number, int decimalPlaces)
        {
            return Util.RoundDown(number, decimalPlaces);
        }


        // NOTE: Use ToSafeDecimal() or ToSafeNullDecimal();
        ///// <summary>
        ///// Get a decimal from given string representing money.
        ///// </summary>
        ///// <param name="moneyString"></param>
        ///// <returns>decimal representation of given money string or null if given value can not be converted to a decimal</returns>
        //public static decimal? GetDecimalFromMoneyString(this string moneyString)
        //{
        //    moneyString = moneyString.Replace("$", "").Replace(",", "");
        //    if (decimal.TryParse(moneyString, out decimal val))
        //    {
        //        return val;
        //    }
        //    else
        //    {
        //        return null;
        //    }
        //}
    }
}
