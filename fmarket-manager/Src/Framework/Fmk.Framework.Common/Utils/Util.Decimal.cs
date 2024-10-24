using System;
using System.Collections.Generic;

namespace Fmk.Framework.Common.Utils
{
    public static partial class Util
    {

        #region *** Largest/Smallest ***

        /// <summary>
        /// Return the largest value in a provided list of numbers.
        /// </summary>
        /// <param name="list">List of values to check</param>
        /// <param name="indexUsed">Position of item in the list that was returned</param>
        /// <returns>>Largest value in list</returns>
        public static decimal GetLargestNumber(IEnumerable<decimal> list, out int indexUsed)
        {
            decimal largestDecimal = decimal.MinValue;
            int currentIndex = -1;
            int usedIndex = -1;
            foreach (decimal d in list)
            {
                currentIndex++;
                if (d > largestDecimal)
                {
                    largestDecimal = d;
                    usedIndex = currentIndex;
                }
            }

            indexUsed = usedIndex;
            return (largestDecimal > decimal.MinValue) ? largestDecimal : 0;
        }

        /// <summary>
        /// Return the smallest value in a provided list of numbers.
        /// </summary>
        /// <param name="list">List of values to check</param>
        /// <param name="indexUsed">Position of item in the list that was returned</param>
        /// <returns>>Smallest value in list</returns>
        public static decimal GetSmallestNumber(IEnumerable<decimal> list, out int indexUsed)
        {
            decimal smallestDecimal = decimal.MaxValue;
            int currentIndex = -1;
            int usedIndex = -1;
            foreach (decimal d in list)
            {
                currentIndex++;
                if (d < smallestDecimal)
                {
                    smallestDecimal = d;
                    usedIndex = currentIndex;
                }
            }

            indexUsed = usedIndex;
            return (smallestDecimal < decimal.MaxValue) ? smallestDecimal : 0;
        }

        #endregion

        #region *** Rounding ***

        /// <summary>
        /// Round the specified Number to the specified DecimalPlaces.  x.5 and above rounds up, x.4 and below rounds 
        /// down. if a negative value for DecimalPlaces is passed in, 0 is used.
        /// </summary>
        /// <param name="number">Decimal to round</param>
        /// <param name="decimalPlaces">Number of DecimalPlaces to round to</param>
        /// <returns>A decimal rounded to the specified DecimalPlaces</returns>
        public static decimal RoundAtMidpoint(decimal number, int decimalPlaces)
        {
            if (decimalPlaces < 0) { decimalPlaces = 0; }
            return Math.Round(number, decimalPlaces, MidpointRounding.AwayFromZero);
        }

        /// <summary>
        /// Round up the specified Number to the specified DecimalPlaces.  x.51 and above rounds up to x.6.
        /// </summary>
        /// <param name="number">Decimal to round</param>
        /// <param name="decimalPlaces">Number of DecimalPlaces to round to</param>
        /// <returns>A decimal rounded up to the specified DecimalPlaces</returns>
        public static decimal RoundUp(decimal number, int decimalPlaces)
        {
            decimal factor = RoundFactor(decimalPlaces);
            number *= factor;
            number = Math.Ceiling(number);
            number /= factor;
            return number;
        }

        /// <summary>
        /// Round down the specified Number to the specified DecimalPlaces.  x.59 and below rounds down to x5.
        /// </summary>
        /// <param name="number">Decimal to round</param>
        /// <param name="decimalPlaces">Number of DecimalPlaces to round to</param>
        /// <returns>A decimal rounded down to the specified DecimalPlaces</returns>
        public static decimal RoundDown(decimal number, int decimalPlaces)
        {
            decimal factor = RoundFactor(decimalPlaces);
            number *= factor;
            number = Math.Floor(number);
            number /= factor;
            return number;
        }

        internal static decimal RoundFactor(int decimalPlaces)
        {
            decimal factor = 1m;

            if (decimalPlaces < 0)
            {
                decimalPlaces = -decimalPlaces;
                for (int i = 0; i < decimalPlaces; i++)
                {
                    factor /= 10m;
                }
            }

            else
            {
                for (int i = 0; i < decimalPlaces; i++)
                {
                    factor *= 10m;
                }
            }

            return factor;
        }

        #endregion

    }
}
