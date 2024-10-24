using System;
using System.Collections.Generic;
using System.Text;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {

        /// <summary>
        /// Gets hours until midnight (rounding up).
        /// </summary>
        /// <returns></returns>
        public static int HoursTillMidnight(this DateTime val)
        {
            var midnight = val.AddDays(1).Date;
            double totalHours = (midnight - val).TotalHours;
            return (int)Math.Ceiling(totalHours);
        }

        /// <summary>
        /// Returns number of milliseconds between passed in DateTime and Now.
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        public static double DurationInMilliseconds(this DateTime val)
        {
            TimeSpan timeSpan = DateTime.Now.Subtract(val);
            return Math.Round(timeSpan.TotalMilliseconds, 2);
        }

        /// <summary>
        /// Returns number of milliseconds between DateTime (StartDateTime) and passed in EndDateTime.
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        public static double DateDiffInMilliseconds(this DateTime val, DateTime endDateTime)
        {
            return ((TimeSpan)(endDateTime - val)).TotalMilliseconds;
        }

        /// <summary>
        /// Get a duration message (difference between this DateTime and Now) in milliseconds, seconds, minutes
        /// or hours (depending on amount of the time difference).
        /// </summary>
        /// <param name="val">Start Time</param>
        public static string DurationToTimeString(this DateTime val)
        {
            double totalMilliseconds = val.DurationInMilliseconds();
            return totalMilliseconds.MillisecondsToTimeString();
        }

        /// <summary>
        /// Get a duration message in milliseconds, seconds, minutes or hours (depending on amount of the time
        /// difference) for passed in milliseconds.
        /// </summary>
        /// <param name="val">Milliseconds</param>
        public static string MillisecondsToTimeString(this double val)
        {
            TimeSpan timeSpan = TimeSpan.FromMilliseconds(val);
            double totalMilliseconds = Math.Round(timeSpan.TotalMilliseconds, 2);

            //string answer = string.Format("{0:D2}hr:{1:D2}min:{2:D2}sec:{3:D3}ms", timeSpan.Hours, timeSpan.Minutes, timeSpan.Seconds, timeSpan.Milliseconds);
            //00h:01m:29s:791ms

            if (timeSpan.Hours > 0)
            {
                return string.Format("{0:D2}h:{1:D2}m", timeSpan.Hours, timeSpan.Minutes);
            }
            if (timeSpan.Minutes > 0)
            {
                return string.Format("{0:D2}m:{1:D2}s", timeSpan.Minutes, timeSpan.Seconds);
            }
            if (timeSpan.Seconds > 0)
            {
                return string.Format("{0:D2}s:{1:D3}ms", timeSpan.Seconds, timeSpan.Milliseconds);
            }
            return string.Format("{0:D3}ms", timeSpan.Milliseconds);

            //if (totalMilliseconds < 1000) { return totalMilliseconds + " ms"; }
            //if (totalMilliseconds < 60000) { return Math.Round(timeSpan.TotalSeconds, 2) + " sec"; }
            //if (totalMilliseconds < 3600000) { return Math.Round(timeSpan.TotalMinutes, 2) + " min"; }
            //return Math.Round(timeSpan.TotalHours, 2) + " hours";
        }

        /// <summary>
        /// Returns a 'Date Time' string given a DataTime truncated to passed in totalLength.
        /// </summary>
        /// <param name="val">DateTime for which 'Date - Time' string is required</param>
        /// <param name="totalLength">Total Length of the returned date/time string.</param>
        /// <returns>'Date - Time' string for passed in DateTime</returns>
        public static string GetDateTimeStamp(this DateTime val, int totalLength = 1000)
        {
            string rtn = val.Year + val.Month.ToString().PadLeft(2, '0') + val.Day.ToString().PadLeft(2, '0') +
                         "_" + GetTimeStamp(val).Replace(":", "");
            return (totalLength >= rtn.Length) ? rtn : rtn.Substring(0, totalLength);
        }

        /// <summary>
        ///  Returns a 'Time' string given a DataTime (with milliseconds).
        /// </summary>
        /// <param name="val">DateTime for which 'Time' string is required</param>
        /// <returns>'Time' string for passed in DataTime</returns>
        public static string GetTimeStamp(this DateTime val)
        {
            return val.Hour.ToString().PadLeft(2, '0') + ":" +
                   val.Minute.ToString().PadLeft(2, '0') + ":" +
                   val.Second.ToString().PadLeft(2, '0') + ":" +
                   val.Millisecond.ToString().PadLeft(3, '0');
        }

        /// <summary>
        /// Returns a 'Date Time' string in the format 'M/d/yyyy HH:mm:ss}' or 'yyyy-MM-dd HH:mm:ss' 
        /// depending on the value of putYearFirst.
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        public static string GetShortDateTimeString(this DateTime val, bool putYearFirst = false)
        {
            if(putYearFirst)
            {
                return string.Format("{0:yyyy-MM-dd HH:mm:ss}", val);
            }
            else
            {
                return string.Format("{0:M/d/yyyy HH:mm:ss}", val);
            }
        }
        
    }
}
