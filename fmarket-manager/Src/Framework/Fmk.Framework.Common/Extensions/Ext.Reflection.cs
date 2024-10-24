using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace Fmk.Framework.Common.Extensions
{
    static partial class Ext
    {
        /// <summary>
        /// Set value on a property that could potentially be on a base class.  This is necessary 
        /// only because, for private properties, PropertyInfo must be from actual class (not child 
        /// class) when attempting a call to SetValue(). 
        /// </summary>
        /// <param name="type"></param>
        /// <param name="propertyName"></param>
        public static void SetValueWithPotentiallyPrivateSetter(this PropertyInfo propertyInfo, object obj, object val)
        {
            while (propertyInfo != null && propertyInfo.SetMethod == null && propertyInfo.ReflectedType != propertyInfo.DeclaringType)
            {
                propertyInfo = propertyInfo.DeclaringType.GetProperty(propertyInfo.Name);
            }
            propertyInfo.SetValue(obj, val);
        }

        /// <summary>
        /// Get property that could potentially be on a base class.  This is necessary only 
        /// because, for private properties, PropertyInfo must be from actual class (not child 
        /// class) when attempting a call to SetValue(). 
        /// </summary>
        /// <param name="type"></param>
        /// <param name="propertyName"></param>
        /// <returns></returns>
        public static PropertyInfo GetPropertyWithPotentiallyPrivateSetter(this Type type, string propertyName)
        {
            PropertyInfo? pi = type.GetProperty(propertyName);
            while (pi != null && pi.SetMethod == null && pi.ReflectedType != pi.DeclaringType)
            {
                pi = pi.DeclaringType.GetProperty(propertyName);
            }
            return pi;
        }
        /// <summary>
        /// Get property that could potentially be on a base class.  This is necessary only 
        /// because, for private properties, PropertyInfo must be from actual class (not child 
        /// class) when attempting a call to SetValue(). 
        /// </summary>
        /// <param name="type"></param>
        /// <param name="propertyName"></param>
        /// <param name="bindingFlags"></param>
        /// <returns></returns>
        public static PropertyInfo GetPropertyWithPotentiallyPrivateSetter(this Type type, string propertyName, BindingFlags bindingFlags)
        {
            PropertyInfo? pi = type.GetProperty(propertyName, bindingFlags);
            while (pi != null && pi.SetMethod == null && pi.ReflectedType != pi.DeclaringType)
            {
                pi = pi.DeclaringType.GetProperty(propertyName, bindingFlags);
            }
            return pi;
        }


        ///// <summary>
        ///// Get the Setter of a property of an object.  This deep version checks all parent 
        ///// (inherited from) objects for the property.
        ///// <param name="propertyInfo">PropertyInfo</param>
        ///// <returns>MethodInfo</returns>
        //public static MethodInfo GetSetMethodDeep(this PropertyInfo propertyInfo)
        //{
        //    Type type = propertyInfo.ReflectedType;
        //    return type.GetSetMethodDeep(propertyInfo.Name);
        //}

        ///// <summary>
        ///// Get the Setter of a property of an object.  This deep version checks all parent 
        ///// (inherited from) objects for the property.
        ///// <param name="propertyName">Name of the property</param>
        ///// <returns>MethodInfo</returns>
        //public static MethodInfo GetSetMethodDeep(this Type type, string propertyName)
        //{
        //    Type t = type;
        //    PropertyInfo pi = t.GetProperty(propertyName);
        //    if(pi == null) { return null; }
        //    MethodInfo mi = pi.GetSetMethod(true);
        //    while (mi == null && t.BaseType != typeof(object))
        //    {
        //        t = t.BaseType;
        //        pi = t.GetProperty(propertyName);
        //        mi = pi.GetSetMethod(true);
        //    }
        //    return mi;
        //}
    }
}
