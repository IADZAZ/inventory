CREATE TABLE [dbo].[jnEventComment] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [EventId]       INT                NOT NULL,
    [CommentId]       INT                NOT NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbojnEventComment_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbojnEventComment_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbojnEventComment] PRIMARY KEY CLUSTERED ([EventId] ASC, [CommentId] ASC),
    CONSTRAINT [FK_PAR_dbojnEventComment_CommentId_dboComment_Id] FOREIGN KEY ([CommentId]) REFERENCES [dbo].[Comment] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAR_dbojnEventComment_EventId_dboEvent_Id] FOREIGN KEY ([EventId]) REFERENCES [dbo].[Event] ([Id]) ON DELETE CASCADE
);