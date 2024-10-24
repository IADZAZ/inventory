CREATE TABLE [dbo].[Address] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [AddressTypeId]   SMALLINT           NOT NULL,
    [Address1]        NVARCHAR (255)     NOT NULL,
    [Address2]        NVARCHAR (255)     NULL,
    [City]            NVARCHAR (255)     NOT NULL,
    [State]           NCHAR (2)          NOT NULL,
    [Country]         NCHAR (2)          CONSTRAINT [DF_dboAddress_Country] DEFAULT ('US') NOT NULL,
    [PostalCode]      NVARCHAR (20)      NOT NULL,
    [Memo]            NVARCHAR (500)     NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboAddress_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboAddress_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboAddress] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboAddress_AddressTypeId_dbolkAddressType_Id] FOREIGN KEY ([AddressTypeId]) REFERENCES [dbo].[lkAddressType] ([Id])
);

