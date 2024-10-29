CREATE TABLE [dbo].[Company] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [Code]            NVARCHAR (25)      NOT NULL,
    [Name]            NVARCHAR (50)      NOT NULL,
    [Description]     NVARCHAR (255)     NULL,
    [CompanyTypeId]   SMALLINT           NOT NULL,
    [IsApproved]      BIT                CONSTRAINT [DF_dboCompany_IsApproved] DEFAULT ((0)) NOT NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboCompany_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboCompany_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboCompany] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboCompany_CompanyTypeId_dbolkCompanyType_Id] FOREIGN KEY ([CompanyTypeId]) REFERENCES [dbo].[lkCompanyType] ([Id]),
    CONSTRAINT [U_dboCompany_Code] UNIQUE NONCLUSTERED ([Code] ASC),
    CONSTRAINT [U_dboCompany_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

