using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Fmk.FMktMgr.Core.Enums.CoreEnums;

namespace Fmk.FMktMgr.Core.Entities
{
    public class DboDataEntities
    {

        public class Address : FlexDataEntityBase
        {
           // public short AddressTypeId { get; set; }
            public AddressType AddressType { get; set; }
            public string Address1 { get; set; } //(255)
            public string? Address2 { get; set; } //(255)
            public string City { get; set; } //(255)
            public string State { get; set; } //(2)
            public string Country { get; set; } //(2)
            public string PostalCode { get; set; } //(20)
            public string? Memo { get; set; } //(500)
        }


        public class Comment : FlexDataEntityBase
        {
            //public short CommentTypeId { get; set; }
            public CommentType CommentType { get; set; }
            public string Text { get; set; } //(4000)
        }


        public class Company : FlexDataEntityBase
        {
            public string Code { get; set; } //(10)
            public string Name { get; set; } //(50)
            public string? Description { get; set; } //(255)
            //public short CompanyTypeId { get; set; }
            public CompanyType CompanyType { get; set; }
            public bool IsApproved { get; set; }

            public IList<Address> AddressList { get; set; } = [];   // Relationship via jnCompanyAddress
            public IList<ContactItem> ContactItemList { get; set; } = [];   // Relationship via jnCompanyContactItem
        }


        public class ContactItem : FlexDataEntityBase
        {
            //public short ContactItemTypeId { get; set; }
            public ContactItemType ContactItemType { get; set; }
            public string Value { get; set; } //(255)
            public string? Memo { get; set; } //(500)
        }


        public class Event : FlexDataEntityBase
        {
            //public int EventDefinitionId { get; set; }
            public EventDefinition EventDefinition { get; set; }
            public DateTimeOffset EventDate { get; set; }
            //public int VendorPersonId { get; set; }
            public Person VendorPerson { get; set; }
            public DateTimeOffset? ArivalTime { get; set; }
            public DateTimeOffset? DepartureTime { get; set; }
            public string? BoothSpace { get; set; } //(255)
            public decimal? PettyCash { get; set; }
            public decimal? RentPaid { get; set; }

            public IList<EventProduct> EventProductList { get; set; } = new List<EventProduct>(); // Relationship via "EventId" field on EventProduct
            public IList<Comment> CommentList { get; set; } = [];   // Relationship via jnEventComment
        }


        public class EventDefinition : FlexDataEntityBase
        {
            public string Code { get; set; } //(10)
            public string Name { get; set; } //(50)
            public string? Description { get; set; } //(255)
            //public short EventTypeId { get; set; }
            public EventType EventType { get; set; }
            //public int ManagementCompanyId { get; set; }
            public Company ManagementCompany { get; set; }
            public int LocationId { get; set; }
            public DateTimeOffset ScheduledStartTime { get; set; }
            public DateTimeOffset ScheduledEndTime { get; set; }
            //public short EventRentTypeId { get; set; }
            public EventRentType EventRentType { get; set; }
            public string? DefaultBoothSpace { get; set; } //(255)
            public decimal? DefaultPettyCash { get; set; }

            public IList<EventDefinitionProduct> EventDefinitionProductList { get; set; } = new List<EventDefinitionProduct>(); // Relationship via "EventDefinitionId" field on EventDefinitionProduct
        }


        public class EventDefinitionProduct : FlexDataEntityBase
        {
            //public int EventDefinitionId { get; set; }
            public EventDefinition EventDefinition { get; set; }
            //public int ProductId { get; set; }
            public Product Product { get; set; }
            public int Quantity { get; set; }
        }


        public class EventProduct : FlexDataEntityBase
        {
            //public int EventId { get; set; }
            public Event Event { get; set; }
            //public int ProductId { get; set; }
            public Product Product { get; set; }
            public int TargetQuantity { get; set; }
            public int StartQuantity { get; set; }
            public int? SoldQuantity { get; set; }
            public int? EndQuantity { get; set; }
            public decimal DiscountAmount { get; set; }
        }


        public class Inventory : FlexDataEntityBase
        {
            //public int SupplyId { get; set; }
            public Supply Supply { get; set; }
            public int Quantity { get; set; }
            public decimal LastCost { get; set; }
            public decimal? OverrideCost { get; set; }
        }


        public class InventoryLocation : FlexDataEntityBase
        {
            //public int SupplyId { get; set; }
            public Supply Supply { get; set; }
            public int Quantity { get; set; }
            //public int LocationId { get; set; }
            public Location Location { get; set; }
        }


        public class InventoryTransaction : FlexDataEntityBase
        {
            //public short InventoryTransactionTypeId { get; set; }
            public InventoryTransactionType InventoryTransactionType { get; set; }
            public int SupplyId { get; set; }
            //public Supply Supply { get; set; }
            public int? SupplyCompanyId { get; set; }
            //public Company? SupplyCompany { get; set; }
            public int Quantity { get; set; }
            public decimal? Cost { get; set; }
            public string? Description { get; set; } //(500)
        }


        public class Location : FlexDataEntityBase
        {
            //public short LocationTypeId { get; set; }
            public LocationType LocationType { get; set; }
            public string Code { get; set; } //(25)
            public string Name { get; set; } //(50)
            public string? Description { get; set; } //(255)

            public IList<Address> AddressList { get; set; } = [];   // Relationship via jnLocationAddress
        }


        public class Person : FlexDataEntityBase
        {
            //public short PersonTypeId { get; set; }
            public PersonType PersonType { get; set; }
            public string FirstName { get; set; } //(50)
            public string? FirstNamePref { get; set; } //(50)
            public string LastName { get; set; } //(50)
            public string? LastNamePref { get; set; } //(50)
            //public short GenderId { get; set; }
            public Gender Gender { get; set; }
            //public short? GenderPrefId { get; set; }
            public Gender? GenderPref { get; set; }
            public DateTime DateOfBirth { get; set; }
            public string? CountryOfBirth { get; set; } //(50)
            public string? TaxIdNumber { get; set; } //(50)

            public IList<Address> AddressList { get; set; } = [];   // Relationship via jnPersonAddress
            public IList<ContactItem> ContactItemList { get; set; } = [];   // Relationship via jnPersonContactItem
        }


        public class Product : FlexDataEntityBase
        {
            //public int SupplyId { get; set; }
            public Supply Supply { get; set; }
            public decimal Price { get; set; }
        }


        public class Supply : FlexDataEntityBase
        {
            //public int SupplyTypeId { get; set; }
            public SupplyType SupplyType { get; set; }
            public string Code { get; set; } //(25)
            public string Name { get; set; } //(50)
            public string? Description { get; set; } //(255)
            public int? FromCompanyId { get; set; }
            //public Company? FromCompany { get; set; }
            public decimal? Cost { get; set; }

            public IList<Supply> ChildSupplyList { get; set; } = new List<Supply>(); // Relationship via "SupplyId" field on SupplyChildSupply
            public IList<Variation> VariationList { get; set; } = [];   // Relationship via jnSupplyVariation
        }


        public class SupplyChildSupply : TerminatableDataEntityBase
        {
            public int SupplyId { get; set; }
            //public Supply Supply { get; set; }
            public int ChildSupplyId { get; set; }
            //public Supply ChildSupply { get; set; }
            public int ChildSupplyQuantity { get; set; }
        }


        public class SupplyType : FlexDataEntityBase
        {
            public int? OrganizationId { get; set; }
            public string Code { get; set; } //(25)
            public string Name { get; set; } //(50)
            public string? Description { get; set; } //(255)
        }


        public class Variation : FlexDataEntityBase
        {
            //public int VariationTypeId { get; set; }
            public VariationType VariationType { get; set; }
            public string Code { get; set; } //(25)
            public string Name { get; set; } //(50)
            public string? Description { get; set; } //(255)
        }


        public class VariationType : FlexDataEntityBase
        {
            public int? OrganizationId { get; set; }
            public string Code { get; set; } //(25)
            public string Name { get; set; } //(50)
            public string? Description { get; set; } //(255)
        }

    }
}
