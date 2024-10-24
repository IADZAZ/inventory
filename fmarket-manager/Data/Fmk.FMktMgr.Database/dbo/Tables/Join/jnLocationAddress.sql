CREATE TABLE [dbo].[jnLocationAddress] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [LocationId]      INT                NOT NULL,
    [AddressId]       INT                NOT NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbojnLocationAddress_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbojnLocationAddress_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbojnLocationAddress] PRIMARY KEY CLUSTERED ([LocationId] ASC, [AddressId] ASC),
    CONSTRAINT [FK_PAR_dbojnLocationAddress_AddressId_dboAddress_Id] FOREIGN KEY ([AddressId]) REFERENCES [dbo].[Address] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAR_dbojnLocationAddress_LocationId_dboLocation_Id] FOREIGN KEY ([LocationId]) REFERENCES [dbo].[Location] ([Id]) ON DELETE CASCADE
);