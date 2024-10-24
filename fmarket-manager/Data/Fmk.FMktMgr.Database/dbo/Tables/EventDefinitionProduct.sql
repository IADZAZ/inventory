CREATE TABLE [dbo].[EventDefinitionProduct] (
    [Id]					INT					IDENTITY (1, 1) NOT NULL,
    [EventDefinitionId]		INT					NOT NULL,
    [ProductId]				INT					NOT NULL,
	[Quantity]				INT					NOT NULL,
    [FlexData]				NVARCHAR (MAX)     NULL,
    [DateCreated]			DATETIMEOFFSET (7) CONSTRAINT [DF_dboEventDefinitionProduct_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]			NVARCHAR (255)     CONSTRAINT [DF_dboEventDefinitionProduct_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated]		DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboEventDefinitionProduct] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PAR_dboEventDefinitionProduct_EventDefinitionId_dboEventDefinition_Id] FOREIGN KEY ([EventDefinitionId]) REFERENCES [dbo].[EventDefinition] ([Id]),
	CONSTRAINT [FK_REF_dboEventDefinitionProduct_ProductId_dboProduct_Id] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id])
);