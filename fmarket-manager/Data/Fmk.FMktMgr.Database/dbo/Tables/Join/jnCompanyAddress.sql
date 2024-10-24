CREATE TABLE [dbo].[jnCompanyAddress] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [CompanyId]       INT                NOT NULL,
    [AddressId]       INT                NOT NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbojnCompanyAddress_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbojnCompanyAddress_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbojnCompanyAddress] PRIMARY KEY CLUSTERED ([CompanyId] ASC, [AddressId] ASC),
    CONSTRAINT [FK_PAR_dbojnCompanyAddress_AddressId_dboAddress_Id] FOREIGN KEY ([AddressId]) REFERENCES [dbo].[Address] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAR_dbojnCompanyAddress_CompanyId_dboCompany_Id] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([Id]) ON DELETE CASCADE
);