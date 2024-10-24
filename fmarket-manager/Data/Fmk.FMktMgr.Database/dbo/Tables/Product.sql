CREATE TABLE [dbo].[Product] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [SupplyId]        INT                NOT NULL,
    [Price]           DECIMAL (18, 2)    NOT NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboProduct_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboProduct_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboProduct] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboProduct_SupplyId_dboSupply_Id] FOREIGN KEY ([SupplyId]) REFERENCES [dbo].[Supply] ([Id])
);

