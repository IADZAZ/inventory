using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace Fmk.Framework.Common.Extensions
{
    public static partial class Ext
    {

        public static ObservableCollection<T> ToObservableCollection<T>(this IEnumerable<T> coll)
        {
            var oc = new ObservableCollection<T>();
            foreach (var l in coll) { oc.Add(l); }
            return oc;
        }

    }
}
