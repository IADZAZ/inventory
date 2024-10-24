using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fmk.FMktMgr.Core.Contracts
{
    public interface ISoftDeletable
    {
        DateTimeOffset? DateDeactivated { get; set; }
    }
}
