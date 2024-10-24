CREATE TABLE [dbo].[EventProduct] (
    [Id]					INT					IDENTITY (1, 1) NOT NULL,
    [EventId]				INT					NOT NULL,
    [ProductId]				INT					NOT NULL,
	[TargetQuantity]		INT					NOT NULL,
    [StartQuantity]			INT					NOT NULL,
	[SoldQuantity]			INT					NULL,
    [EndQuantity]			INT					NULL,
	[DiscountAmount]		DECIMAL (18, 2)		NOT NULL,
	[FlexData]				NVARCHAR (MAX)		NULL,
    [DateCreated]			DATETIMEOFFSET (7)	CONSTRAINT [DF_dboEventProduct_DateCreated] DEFAULT (sysdatetimeoffset())	NOT NULL,
    [LastUpdateBy]			NVARCHAR (255)		CONSTRAINT [DF_dboEventProduct_LastUpdateBy] DEFAULT ('{system}')			NOT NULL,
    [DateDeactivated]		DATETIMEOFFSET (7)	NULL,
    CONSTRAINT [PK_dboEventProduct] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PAR_dboEventProduct_EventId_dboEvent_Id] FOREIGN KEY ([EventId]) REFERENCES [dbo].[Event] ([Id]),
	CONSTRAINT [FK_REF_dboEventProduct_ProductId_dboProduct_Id] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id])
);