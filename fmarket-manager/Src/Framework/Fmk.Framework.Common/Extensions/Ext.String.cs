using System;
using System.Collections.Generic;
using System.Text;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {

        /// <summary>
        /// Adds a space before each capital letter in a given string.
        /// </summary>
        /// <param name="val"></param>
        /// <returns></returns>
        public static string AddSpaceBeforeCap(this string val)
        {
            var rtn = new StringBuilder();
            var A = (int)'A';
            var Z = (int)'Z';
            char chr = 'a';
            for (int i = 0; i < val.Length; i++)
            {
                chr = Convert.ToChar(val.Substring(i, 1));
                if (((int)chr) >= A && ((int)chr) <= Z && i > 0) { rtn.Append(" "); }
                rtn.Append(chr.ToString());
            }
            return rtn.ToString();
        }

        /// <summary>
        /// Returns a portion of a string between two characters within that string.
        /// </summary>
        /// <param name="val"></param>
        /// <param name="startChar"></param>
        /// <param name="endChar"></param>
        /// <returns></returns>
        public static string SubstringBetweenChars(this string val, char startChar, char endChar)
        {
            int startIndex = val.IndexOf(startChar);
            int endIndex = val.IndexOf(endChar);
            if (startChar == endChar)
            {
                endIndex = val.IndexOf(endChar, (startIndex + 1));
            }

            if (startIndex > -1 && endIndex > startIndex)
            {
                return val.Substring((startIndex + 1), (endIndex - (startIndex + 1))).Trim();
            }
            throw new ArgumentException($"Invalid Start '{startChar}' or End '{endChar}' character provided for string '{val}'.");
        }

        /// <summary>
        /// Takes a string list and returns a delimited string containing each of the list's values.
        /// </summary>
        /// <param name="vals"></param>
        /// <param name="delimiter"></param>
        /// <param name="includeSpaceAfterDelimiter"></param>
        /// <returns></returns>
        public static string ToDelimitedString(this List<string> vals, string delimiter, bool includeSpaceAfterDelimiter = true)
        {
            var sb = new StringBuilder();
            int cnt = 0;
            foreach (string val in vals)
            {
                cnt++;
                if (cnt > 1)
                {
                    sb.Append(delimiter);
                    if (includeSpaceAfterDelimiter) { sb.Append(" "); }
                }
                sb.Append(val);
            }
            return sb.ToString();
        }

        /// <summary>
        /// If a string is empty (or null) returns null, otherwise, returns trimmed string.
        /// </summary>
        public static string EmptyStringToNull(this string val)
        {
            if (val == null) { return null; }
            val = val.Trim();
            return string.IsNullOrEmpty(val) ? null : val;
        }

        /// <summary>
        /// If a string is empty (or null) returns null, otherwise, returns trimmed string 
        /// per-pended with the passed in leadingText string.
        /// </summary>
        public static string EmptyStringToNull(this string val, string leadingText)
        {
            if (val == null) { return null; }
            val = val.Trim();
            return string.IsNullOrEmpty(val) ? null : leadingText + val;
        }

        /// <summary>
        /// Returns a camel case (words w/o spaces, first word lower case, each subsequent word 
        /// upper case) version of the string.
        /// </summary>
        /// <param name="val">The full string.</param>
        public static string GetCamelCase(this string val)
        {
            if (val.Length <= 1) { return val; }

            Char[] letters = val.ToCharArray();
            letters[0] = Char.ToLower(letters[0]);

            return new string(letters);
        }

        public static string WithMaxLength(this string val, int maxLength, bool addEllipsis = true)
        {
            if(val == null) { return val; }
            if(val.Length > maxLength)
            {
                string end = addEllipsis ? "..." : string.Empty;
                return $"{val.Substring(0, (maxLength - end.Length))}{end}";
            }
            return val;
            //string ellipsis = (val.Length > maxLength && addEllipsis) ? "..." : string.Empty;
            //return val?.Substring(0, Math.Min(val.Length, maxLength)) + ellipsis;
        }
    }
}
