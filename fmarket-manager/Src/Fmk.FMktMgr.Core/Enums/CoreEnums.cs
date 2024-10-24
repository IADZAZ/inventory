using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fmk.FMktMgr.Core.Enums
{
    public class CoreEnums
    {
        public enum AddressType
        {
            Primary = 1,
            Shipping = 2,
            Billing = 3,
            Home = 4,
            Work = 5,
        }

        public enum CommentType
        {
            General = 1,
            PostEvent = 2
        }

        public enum CompanyType
        {
            Supply = 1,
        }

        public enum ContactItemType
        {
            Phone = 1,
            Email = 2,
            URL = 3,
        }

        public enum EventRentType
        {
	        EighteenPercent = 1,
            TieredType1 = 2,
        }

        public enum EventType
        {
            FarmersMarket = 1,
}

        public enum Gender
        {
            Male = 1,
            Female = 2,
            Unknown = 3,
        }

        public enum InventoryTransactionType
        {
            Purchase = 1,
            Adjustment = 2,
            Assemble = 3,
            Sold = 4,
        }

        public enum LocationType
        {
            Event = 1,
            InventoryStorage = 2,
        }

        public enum PersonType
        {
            Vendor = 1,
        }

    }
}
