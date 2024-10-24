CREATE TABLE [dbo].[jnPersonAddress] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [PersonId]        INT                NOT NULL,
    [AddressId]       INT                NOT NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbojnPersonAddress_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbojnPersonAddress_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbojnPersonAddress] PRIMARY KEY CLUSTERED ([PersonId] ASC, [AddressId] ASC),
    CONSTRAINT [FK_PAR_dbojnPersonAddress_AddressId_dboAddress_Id] FOREIGN KEY ([AddressId]) REFERENCES [dbo].[Address] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAR_dbojnPersonAddress_PersonId_dboPerson_Id] FOREIGN KEY ([PersonId]) REFERENCES [dbo].[Person] ([Id]) ON DELETE CASCADE
);