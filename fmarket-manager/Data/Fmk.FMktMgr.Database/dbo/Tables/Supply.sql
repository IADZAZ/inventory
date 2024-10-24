CREATE TABLE [dbo].[Supply] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [SupplyTypeId]    INT                NOT NULL,
    [Code]            NVARCHAR (25)      NOT NULL,
    [Name]            NVARCHAR (50)      NOT NULL,
    [Description]     NVARCHAR (255)     NULL,
    [FromCompanyId]   INT                NULL,
    [Cost]            DECIMAL (18, 3)    NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboSupply_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboSupply_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboSupply] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [U_dboSupply_Code] UNIQUE NONCLUSTERED ([Code] ASC),
    CONSTRAINT [U_dboSupply_Name] UNIQUE NONCLUSTERED ([Name] ASC),
    CONSTRAINT [FK_REF_dboSupply_FromCompanyId_dboCompany_Id] FOREIGN KEY ([FromCompanyId]) REFERENCES [dbo].[Company] ([Id]),
    CONSTRAINT [FK_REF_dboSupply_SupplyTypeId_dboSupplyType_Id] FOREIGN KEY ([SupplyTypeId]) REFERENCES [dbo].[SupplyType] ([Id])
);

