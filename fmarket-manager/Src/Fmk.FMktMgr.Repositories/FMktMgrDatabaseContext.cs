//#nullable disable
//using System;
//using System.Collections.Generic;
//using System.Diagnostics;
//using System.Diagnostics.Metrics;
//using System.Net;
//using System.Reflection.Emit;
//using System.Text.RegularExpressions;
//using System.Xml.Linq;
//using Microsoft.EntityFrameworkCore;
//using Microsoft.EntityFrameworkCore.Metadata.Conventions;
//using Fmk.FMktMgr.Core.Entities;
//using static Fmk.FMktMgr.Core.Entities.DboDataEntities;

//namespace Fmk.FMktMgr.Repositories;

//public partial class FMktMgrDatabaseContext : DbContext
//{
//    private readonly string _connectionString;
//    private readonly string _userName;

//    public FMktMgrDatabaseContext(AppExecutionContext appExecContext, IAdminContextService adminContextService)
//    {
//        var aesContext = adminContextService.GetUniqueAdminContext(appExecContext.ClientKey, appExecContext.ProductType, appExecContext.ProductVersionOverride, T21DbType.MES);
//        _connectionString = adminContextService.GetConnectionString(aesContext);
//        _userName = appExecContext.UserName;
//    }

//    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
//    {
//        configurationBuilder.Conventions.Remove(typeof(TableNameFromDbSetConvention)); //remove pluralization convention
//    }

//    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
//    {
//        //LogContext.PushProperty("DataSource", context.ContextKey); -- This does not work here

//        base.OnConfiguring(optionsBuilder
//            .UseSqlServer(_connectionString)
//            .AddInterceptors(new SoftDeleteInterceptor())
//            .LogTo(msg => Debug.WriteLine(msg), Microsoft.Extensions.Logging.LogLevel.Information));
//    }

//    public override int SaveChanges()
//    {
//        var timestamp = DateTimeOffset.Now;
//        foreach (var entry in ChangeTracker.Entries()
//            .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified || e.State == EntityState.Deleted))
//        {
//            if (!entry.Metadata.Name.StartsWith("jn"))
//            {
//                entry.Property("LastUpdateBy").CurrentValue = _userName;
//                if (entry.State == EntityState.Added && !entry.Metadata.ClrType.Name.StartsWith("lk"))
//                {
//                    entry.Property("DateCreated").CurrentValue = timestamp;
//                }
//            }
//        }

//        return base.SaveChanges();
//    }

//    public bool IgnoreDateDeactivated { get; set; } = false;

//    #region *** DBSet Declarations ***

//    public virtual DbSet<Address> AddressSet { get; set; }
//    public virtual DbSet<Comment> CommentSet { get; set; }
//    public virtual DbSet<Company> CompanySet { get; set; }
//    public virtual DbSet<ContactItem> ContactItemSet { get; set; }
//    public virtual DbSet<Event> EventSet { get; set; }
//    public virtual DbSet<EventDefinition> EventDefinitionSet { get; set; }
//    public virtual DbSet<EventDefinitionProduct> EventDefinitionProductSet { get; set; }
//    public virtual DbSet<EventProduct> EventProductSet { get; set; }
//    public virtual DbSet<Inventory> InventorySet { get; set; }
//    public virtual DbSet<InventoryLocation> InventoryLocationSet { get; set; }
//    public virtual DbSet<InventoryTransaction> InventoryTransactionSet { get; set; }
//    public virtual DbSet<Location> LocationSet { get; set; }
//    public virtual DbSet<Person> PersonSet { get; set; }
//    public virtual DbSet<Product> ProductSet { get; set; }
//    public virtual DbSet<Supply> SupplySet { get; set; }
//    public virtual DbSet<SupplyChildSupply> SupplyChildSupplySet { get; set; }
//    public virtual DbSet<SupplyType> SupplyTypeSet { get; set; }
//    public virtual DbSet<Variation> VariationSet { get; set; }
//    public virtual DbSet<VariationType> VariationTypeSet { get; set; }

//    #endregion *** DBSet Declarations ***

//    protected override void OnModelCreating(ModelBuilder modelBuilder)
//    {


//        // public virtual DbSet<Address> AddressSet { get; set; }
//        modelBuilder.Entity<Address>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboAddress");
//            entity.ToTable("Address");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.AddressTypeId, "IX_dboAddress_AddressTypeId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboAddress_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Address1).IsRequired().HasMaxLength(255);
//            entity.Property(e => e.Address2).HasMaxLength(255);
//            entity.Property(e => e.City).IsRequired().HasMaxLength(255);
//            entity.Property(e => e.State).IsRequired().HasMaxLength(2).IsFixedLength();
//            entity.Property(e => e.Country).IsRequired().HasMaxLength(2).HasDefaultValueSql("'US'").IsFixedLength();
//            entity.Property(e => e.PostalCode).IsRequired().HasMaxLength(20);
//            entity.Property(e => e.Memo).HasMaxLength(500);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<Comment> CommentSet { get; set; }
//        modelBuilder.Entity<Comment>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboComment");
//            entity.ToTable("Comment");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.CommentTypeId, "IX_dboComment_CommentTypeId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboComment_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Text).IsRequired().HasMaxLength(4000);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<Company> CompanySet { get; set; }
//        modelBuilder.Entity<Company>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboCompany");
//            entity.ToTable("Company");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.Name, "U_dboCompany_Name").IsUnique();
//            entity.HasIndex(e => e.Code, "U_dboCompany_Code").IsUnique();
//            entity.HasIndex(e => e.CompanyTypeId, "IX_dboCompany_CompanyTypeId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboCompany_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Code).IsRequired().HasMaxLength(10);
//            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.Description).HasMaxLength(255);
//            entity.Property(e => e.IsApproved).IsRequired().HasDefaultValueSql("(0)");
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<Company>()
//        .HasMany<EventDefinition>() //(reference-to)
//        .WithOne(p => p.ManagementCompany)
//        .HasForeignKey("ManagementCompanyId")
//        .IsRequired();
//        modelBuilder.Entity<Company>()
//        .HasMany<InventoryTransaction>() //(reference-to)
//        .WithOne(p => p.SupplyCompany)
//        .HasForeignKey("SupplyCompanyId")
//        .IsRequired();
//        modelBuilder.Entity<Company>()
//        .HasMany<Supply>() //(reference-to)
//        .WithOne(p => p.FromCompany)
//        .HasForeignKey("FromCompanyId")
//        .IsRequired();
//        modelBuilder.Entity<Company>()
//        .HasMany(e => e.AddressList)
//        .WithMany()
//        .UsingEntity("jnCompanyAddress", j =>
//        {
//            j.Property(nameof(Company) + "Id").HasColumnName(nameof(Company) + "Id");
//            j.Property(nameof(Company.AddressList) + "Id").HasColumnName(nameof(Address) + "Id");
//        });
//        modelBuilder.Entity<Company>()
//        .HasMany(e => e.ContactItemList)
//        .WithMany()
//        .UsingEntity("jnCompanyContactItem", j =>
//        {
//            j.Property(nameof(Company) + "Id").HasColumnName(nameof(Company) + "Id");
//            j.Property(nameof(Company.ContactItemList) + "Id").HasColumnName(nameof(ContactItem) + "Id");
//        });


//        // public virtual DbSet<ContactItem> ContactItemSet { get; set; }
//        modelBuilder.Entity<ContactItem>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboContactItem");
//            entity.ToTable("ContactItem");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.ContactItemTypeId, "IX_dboContactItem_ContactItemTypeId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboContactItem_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Value).IsRequired().HasMaxLength(255);
//            entity.Property(e => e.Memo).HasMaxLength(500);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<Event> EventSet { get; set; }
//        modelBuilder.Entity<Event>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboEvent");
//            entity.ToTable("Event");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.EventDefinitionId, "IX_dboEvent_EventDefinitionId");
//            entity.HasIndex(e => e.VendorPersonId, "IX_dboEvent_VendorPersonId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboEvent_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.EventDate).IsRequired();
//            entity.Property(e => e.ArivalTime);
//            entity.Property(e => e.DepartureTime);
//            entity.Property(e => e.BoothSpace).HasMaxLength(255);
//            entity.Property(e => e.PettyCash);
//            entity.Property(e => e.RentPaid);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<Event>()
//        .HasMany(c => c.EventProductList) //(child-list)
//        .WithOne(p => p.Event)
//        .HasForeignKey("EventId")
//        .IsRequired();
//        modelBuilder.Entity<Event>()
//        .HasMany(e => e.CommentList)
//        .WithMany()
//        .UsingEntity("jnEventComment", j =>
//        {
//            j.Property(nameof(Event) + "Id").HasColumnName(nameof(Event) + "Id");
//            j.Property(nameof(Event.CommentList) + "Id").HasColumnName(nameof(Comment) + "Id");
//        });


//        // public virtual DbSet<EventDefinition> EventDefinitionSet { get; set; }
//        modelBuilder.Entity<EventDefinition>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboEventDefinition");
//            entity.ToTable("EventDefinition");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.Name, "U_dboEventDefinition_Name").IsUnique();
//            entity.HasIndex(e => e.Code, "U_dboEventDefinition_Code").IsUnique();
//            entity.HasIndex(e => e.EventTypeId, "IX_dboEventDefinition_EventTypeId");
//            entity.HasIndex(e => e.ManagementCompanyId, "IX_dboEventDefinition_ManagementCompanyId");
//            entity.HasIndex(e => e.EventRentTypeId, "IX_dboEventDefinition_EventRentTypeId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboEventDefinition_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Code).IsRequired().HasMaxLength(10);
//            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.Description).HasMaxLength(255);
//            entity.Property(e => e.Location).IsRequired();
//            entity.Property(e => e.ScheduledStartTime).IsRequired();
//            entity.Property(e => e.ScheduledEndTime).IsRequired();
//            entity.Property(e => e.DefaultBoothSpace).HasMaxLength(255);
//            entity.Property(e => e.DefaultPettyCash);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<EventDefinition>()
//        .HasMany<Event>() //(reference-to)
//        .WithOne(p => p.EventDefinition)
//        .HasForeignKey("EventDefinitionId")
//        .IsRequired();
//        modelBuilder.Entity<EventDefinition>()
//        .HasMany(c => c.EventDefinitionProductList) //(child-list)
//        .WithOne(p => p.EventDefinition)
//        .HasForeignKey("EventDefinitionId")
//        .IsRequired();


//        // public virtual DbSet<EventDefinitionProduct> EventDefinitionProductSet { get; set; }
//        modelBuilder.Entity<EventDefinitionProduct>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboEventDefinitionProduct");
//            entity.ToTable("EventDefinitionProduct");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.EventDefinitionId, "IX_dboEventDefinitionProduct_EventDefinitionId");
//            entity.HasIndex(e => e.ProductId, "IX_dboEventDefinitionProduct_ProductId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboEventDefinitionProduct_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Quantity).IsRequired();
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<EventProduct> EventProductSet { get; set; }
//        modelBuilder.Entity<EventProduct>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboEventProduct");
//            entity.ToTable("EventProduct");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.EventId, "IX_dboEventProduct_EventId");
//            entity.HasIndex(e => e.ProductId, "IX_dboEventProduct_ProductId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboEventProduct_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.TargetQuantity).IsRequired();
//            entity.Property(e => e.StartQuantity).IsRequired();
//            entity.Property(e => e.SoldQuantity);
//            entity.Property(e => e.EndQuantity);
//            entity.Property(e => e.DiscountAmount).IsRequired();
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<Inventory> InventorySet { get; set; }
//        modelBuilder.Entity<Inventory>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboInventory");
//            entity.ToTable("Inventory");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.SupplyId, "IX_dboInventory_SupplyId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboInventory_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Quantity).IsRequired();
//            entity.Property(e => e.LastCost).IsRequired();
//            entity.Property(e => e.OverrideCost);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<InventoryLocation> InventoryLocationSet { get; set; }
//        modelBuilder.Entity<InventoryLocation>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboInventoryLocation");
//            entity.ToTable("InventoryLocation");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.SupplyId, "IX_dboInventoryLocation_SupplyId");
//            entity.HasIndex(e => e.LocationId, "IX_dboInventoryLocation_LocationId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboInventoryLocation_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Quantity).IsRequired();
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<InventoryTransaction> InventoryTransactionSet { get; set; }
//        modelBuilder.Entity<InventoryTransaction>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboInventoryTransaction");
//            entity.ToTable("InventoryTransaction");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.InventoryTransactionTypeId, "IX_dboInventoryTransaction_InventoryTransactionTypeId");
//            entity.HasIndex(e => e.SupplyId, "IX_dboInventoryTransaction_SupplyId");
//            entity.HasIndex(e => e.SupplyCompanyId, "IX_dboInventoryTransaction_SupplyCompanyId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboInventoryTransaction_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Quantity).IsRequired();
//            entity.Property(e => e.Cost);
//            entity.Property(e => e.Description).HasMaxLength(500);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<Location> LocationSet { get; set; }
//        modelBuilder.Entity<Location>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboLocation");
//            entity.ToTable("Location");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.Name, "U_dboLocation_Name").IsUnique();
//            entity.HasIndex(e => e.Code, "U_dboLocation_Code").IsUnique();
//            entity.HasIndex(e => e.LocationTypeId, "IX_dboLocation_LocationTypeId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboLocation_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Code).IsRequired().HasMaxLength(25);
//            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.Description).HasMaxLength(255);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<Location>()
//        .HasMany<InventoryLocation>() //(reference-to)
//        .WithOne(p => p.Location)
//        .HasForeignKey("LocationId")
//        .IsRequired();
//        modelBuilder.Entity<Location>()
//        .HasMany(e => e.AddressList)
//        .WithMany()
//        .UsingEntity("jnLocationAddress", j =>
//        {
//            j.Property(nameof(Location) + "Id").HasColumnName(nameof(Location) + "Id");
//            j.Property(nameof(Location.AddressList) + "Id").HasColumnName(nameof(Address) + "Id");
//        });


//        // public virtual DbSet<Person> PersonSet { get; set; }
//        modelBuilder.Entity<Person>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboPerson");
//            entity.ToTable("Person");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.PersonTypeId, "IX_dboPerson_PersonTypeId");
//            entity.HasIndex(e => e.GenderId, "IX_dboPerson_GenderId");
//            entity.HasIndex(e => e.GenderPrefId, "IX_dboPerson_GenderPrefId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboPerson_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.FirstNamePref).HasMaxLength(50);
//            entity.Property(e => e.LastName).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.LastNamePref).HasMaxLength(50);
//            entity.Property(e => e.DateOfBirth).IsRequired();
//            entity.Property(e => e.CountryOfBirth).HasMaxLength(50);
//            entity.Property(e => e.TaxIdNumber).HasMaxLength(50);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<Person>()
//        .HasMany<Event>() //(reference-to)
//        .WithOne(p => p.VendorPerson)
//        .HasForeignKey("VendorPersonId")
//        .IsRequired();
//        modelBuilder.Entity<Person>()
//        .HasMany(e => e.AddressList)
//        .WithMany()
//        .UsingEntity("jnPersonAddress", j =>
//        {
//            j.Property(nameof(Person) + "Id").HasColumnName(nameof(Person) + "Id");
//            j.Property(nameof(Person.AddressList) + "Id").HasColumnName(nameof(Address) + "Id");
//        });
//        modelBuilder.Entity<Person>()
//        .HasMany(e => e.ContactItemList)
//        .WithMany()
//        .UsingEntity("jnPersonContactItem", j =>
//        {
//            j.Property(nameof(Person) + "Id").HasColumnName(nameof(Person) + "Id");
//            j.Property(nameof(Person.ContactItemList) + "Id").HasColumnName(nameof(ContactItem) + "Id");
//        });


//        // public virtual DbSet<Product> ProductSet { get; set; }
//        modelBuilder.Entity<Product>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboProduct");
//            entity.ToTable("Product");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.SupplyId, "IX_dboProduct_SupplyId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboProduct_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Price).IsRequired();
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<Product>()
//        .HasMany<EventDefinitionProduct>() //(reference-to)
//        .WithOne(p => p.Product)
//        .HasForeignKey("ProductId")
//        .IsRequired();
//        modelBuilder.Entity<Product>()
//        .HasMany<EventProduct>() //(reference-to)
//        .WithOne(p => p.Product)
//        .HasForeignKey("ProductId")
//        .IsRequired();


//        // public virtual DbSet<Supply> SupplySet { get; set; }
//        modelBuilder.Entity<Supply>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboSupply");
//            entity.ToTable("Supply");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.Name, "U_dboSupply_Name").IsUnique();
//            entity.HasIndex(e => e.Code, "U_dboSupply_Code").IsUnique();
//            entity.HasIndex(e => e.SupplyTypeId, "IX_dboSupply_SupplyTypeId");
//            entity.HasIndex(e => e.FromCompanyId, "IX_dboSupply_FromCompanyId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboSupply_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Code).IsRequired().HasMaxLength(25);
//            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.Description).HasMaxLength(255);
//            entity.Property(e => e.Cost);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<Supply>()
//        .HasMany(c => c.SupplyChildSupplyList) //(child-list)
//        .WithOne(p => p.Supply)
//        .HasForeignKey("SupplyId")
//        .IsRequired();
//        modelBuilder.Entity<Supply>()
//        .HasMany(c => c.SupplyChildSupplyList) //(child-list)
//        .WithOne(p => p.ChildSupply)
//        .HasForeignKey("ChildSupplyId")
//        .IsRequired();
//        modelBuilder.Entity<Supply>()
//        .HasMany<Inventory>() //(reference-to)
//        .WithOne(p => p.Supply)
//        .HasForeignKey("SupplyId")
//        .IsRequired();
//        modelBuilder.Entity<Supply>()
//        .HasMany<InventoryLocation>() //(reference-to)
//        .WithOne(p => p.Supply)
//        .HasForeignKey("SupplyId")
//        .IsRequired();
//        modelBuilder.Entity<Supply>()
//        .HasMany<InventoryTransaction>() //(reference-to)
//        .WithOne(p => p.Supply)
//        .HasForeignKey("SupplyId")
//        .IsRequired();
//        modelBuilder.Entity<Supply>()
//        .HasMany<Product>() //(reference-to)
//        .WithOne(p => p.Supply)
//        .HasForeignKey("SupplyId")
//        .IsRequired();
//        modelBuilder.Entity<Supply>()
//        .HasMany(e => e.VariationList)
//        .WithMany()
//        .UsingEntity("jnSupplyVariation", j =>
//        {
//            j.Property(nameof(Supply) + "Id").HasColumnName(nameof(Supply) + "Id");
//            j.Property(nameof(Supply.VariationList) + "Id").HasColumnName(nameof(Variation) + "Id");
//        });


//        // public virtual DbSet<SupplyChildSupply> SupplyChildSupplySet { get; set; }
//        modelBuilder.Entity<SupplyChildSupply>(entity =>
//        {
//            entity.HasKey(e => e.SupplyId, ChildSupplyId).HasName("PK_dboSupplyChildSupply");
//            entity.ToTable("SupplyChildSupply");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.SupplyId, "IX_dboSupplyChildSupply_SupplyId");
//            entity.HasIndex(e => e.ChildSupplyId, "IX_dboSupplyChildSupply_ChildSupplyId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboSupplyChildSupply_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.ChildSupplyQuantity).IsRequired().HasDefaultValueSql("(1)");
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(50).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<SupplyType> SupplyTypeSet { get; set; }
//        modelBuilder.Entity<SupplyType>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboSupplyType");
//            entity.ToTable("SupplyType");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboSupplyType_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Organization);
//            entity.Property(e => e.Code).IsRequired().HasMaxLength(25);
//            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.Description).HasMaxLength(255);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<SupplyType>()
//        .HasMany<Supply>() //(reference-to)
//        .WithOne(p => p.SupplyType)
//        .HasForeignKey("SupplyTypeId")
//        .IsRequired();


//        // public virtual DbSet<Variation> VariationSet { get; set; }
//        modelBuilder.Entity<Variation>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboVariation");
//            entity.ToTable("Variation");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.VariationTypeId, "IX_dboVariation_VariationTypeId");
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboVariation_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Code).IsRequired().HasMaxLength(25);
//            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.Description).HasMaxLength(255);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });


//        // public virtual DbSet<VariationType> VariationTypeSet { get; set; }
//        modelBuilder.Entity<VariationType>(entity =>
//        {
//            entity.HasKey(e => e.Id).HasName("PK_dboVariationType");
//            entity.ToTable("VariationType");
//            entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default
//            entity.HasIndex(e => e.DateDeactivated, "IX_dboVariationType_DateDeactivated");
//            entity.Property(e => e.Id).IsRequired();
//            entity.Property(e => e.Organization);
//            entity.Property(e => e.Code).IsRequired().HasMaxLength(25);
//            entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
//            entity.Property(e => e.Description).HasMaxLength(255);
//            entity.Property(e => e.FlexData).HasMaxLength(-1);
//            entity.Property(e => e.DateCreated).IsRequired().HasDefaultValueSql("sysdatetimeoffset()");
//            entity.Property(e => e.LastUpdateBy).IsRequired().HasMaxLength(255).HasDefaultValueSql("'{system}'");
//            entity.Property(e => e.DateDeactivated);
//            entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete
//        });
//        modelBuilder.Entity<VariationType>()
//        .HasMany<Variation>() //(reference-to)
//        .WithOne(p => p.VariationType)
//        .HasForeignKey("VariationTypeId")
//        .IsRequired();



//        OnModelCreatingPartial(modelBuilder);
//    }

//    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
//}