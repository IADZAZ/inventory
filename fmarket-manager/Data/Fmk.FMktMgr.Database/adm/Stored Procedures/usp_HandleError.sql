
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-01-18
-- Description:	Handle errors.  Called from 'CATCH' blocks.
-- =============================================
CREATE PROCEDURE [adm].[usp_HandleError]
	
	@CallingProcId bigint,
	@ErrorInfoStr nvarchar(max) OUTPUT

AS
BEGIN

	-- Store the error.
	INSERT INTO [adm].[DbErrorInfo] (	[Number], [Severity], [State], [CallingProcudure], [ErrorProcedure], [Line], [Message], [XactState], [ContextInfo])
		SELECT							ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), OBJECT_NAME(@CallingProcId), ERROR_PROCEDURE(), 
										ERROR_LINE(), ERROR_MESSAGE(), XACT_STATE(), CONTEXT_INFO();
		
	-- Write error message.
	SET @ErrorInfoStr = CONCAT(	ERROR_MESSAGE(), ' ErrorId=', @@IDENTITY, ';proc=', ERROR_PROCEDURE(), ';line=', ERROR_LINE(), ';num=', ERROR_NUMBER(), 
								';sev=', ERROR_SEVERITY(), ';state=', ERROR_STATE(), ';tstate=', XACT_STATE())	 
		
END