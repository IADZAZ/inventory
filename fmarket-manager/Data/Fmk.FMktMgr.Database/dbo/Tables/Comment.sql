CREATE TABLE [dbo].[Comment] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [CommentTypeId]   SMALLINT           NOT NULL,
    [Text]            NVARCHAR (4000)    NOT NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboComment_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboComment_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboComment] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboComment_CommentTypeId_dbolkCommentType_Id] FOREIGN KEY ([CommentTypeId]) REFERENCES [dbo].[lkCommentType] ([Id])
);