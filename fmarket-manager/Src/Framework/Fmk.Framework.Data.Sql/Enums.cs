using System;

namespace Fmk.Framework.Data.Sql
{
    public enum EqualityType
    {
        EqualTo = 1,
        StartsWith = 2,
        EndsWith = 3,
        Contains = 4,
        GreaterThan = 5,
        GreaterThanOrEqualTo = 6,
        LessThan = 7,
        LessThanOrEqualTo = 8,
        IsNull = 9
        //IsInList = 10  Not Supporting IsInList as this time, user can use a series of "or"s to accomplish IN Logic.
    }
}
