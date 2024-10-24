using System;
using System.Xml.Linq;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {

        /// <summary>
        /// Returns 'true' if a valid XML string is passed in.
        /// </summary>
        /// <param name="val">XML string that may or may not ve valid.</param>
        /// <returns></returns>
        public static bool IsValidXmlDoc(this string val)
        {
            try
            {
                XDocument.Parse(val);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        /// <summary>
        /// Wraps text in an XML node.
        /// </summary>
        public static string WrapForXmlNode(this string val)
        {
            if (string.IsNullOrEmpty(val)) { throw new ArgumentException("A null or empty string can not be converted to an XML node string."); }
            val = val.Trim();
            return $"<{val}/>";
        }

    }
}
