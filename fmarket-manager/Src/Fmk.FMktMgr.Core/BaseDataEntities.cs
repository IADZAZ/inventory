using Fmk.FMktMgr.Core.Contracts;

namespace Fmk.FMktMgr.Core
{
    public abstract class DataEntityBase
    {
        public int Id { get; set; }
    }

    public abstract class BigDataEntityBase
    {
        public long Id { get; set; }
    }

    public abstract class TerminatableDataEntityBase : DataEntityBase, ISoftDeletable
    {
        public DateTimeOffset DateCreated { get; set; }
        public string LastUpdateBy { get; set; } //(255)
        public DateTimeOffset? DateDeactivated { get; set; } = null;
    }

    public abstract class FlexDataEntityBase : TerminatableDataEntityBase
    {
        public string? FlexData { get; set; } //(max)
        //public IList<object> FlexJoins { get; set; } = [];
    }
}
