CREATE TABLE [dbo].[Event] (
    [Id]                INT                IDENTITY (1, 1) NOT NULL,
    [EventDefinitionId] INT                NOT NULL,
    [EventDate]         DATETIMEOFFSET (7) NOT NULL,
    [VendorPersonId]    INT                NOT NULL,
    [ArivalTime]        DATETIMEOFFSET (7) NULL,
    [DepartureTime]     DATETIMEOFFSET (7) NULL,
    [BoothSpace]        NVARCHAR (255)     NULL,
    [PettyCash]         DECIMAL (18, 2)    NULL,
    [RentPaid]          DECIMAL (18, 2)    NULL,
    [FlexData]          NVARCHAR (MAX)     NULL,
    [DateCreated]       DATETIMEOFFSET (7) CONSTRAINT [DF_dboEvent_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]      NVARCHAR (255)     CONSTRAINT [DF_dboEvent_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated]   DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboEvent] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboEvent_EventDefinitionId_dboEventDefinition_Id] FOREIGN KEY ([EventDefinitionId]) REFERENCES [dbo].[EventDefinition] ([Id]),
    CONSTRAINT [FK_REF_dboEvent_VendorPersonId_dboPerson_Id] FOREIGN KEY ([VendorPersonId]) REFERENCES [dbo].[Person] ([Id])
);

