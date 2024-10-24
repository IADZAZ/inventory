-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-06-07
-- Description:	This is really just a script to generate some flushed out UML.
-- =============================================
CREATE PROCEDURE [adm].[usp_CreateFullPlantUmls]

AS
BEGIN
SET NOCOUNT ON;

	-- Equipment UML:
	PRINT '@startuml';
	EXEC [adm].[usp_GetPlantUml] 'dbo', 'Equipment', 0;
	EXEC [adm].[usp_GetPlantUml] 'dbo', 'EquipmentModel', 0;
	EXEC [adm].[usp_GetPlantUml] 'dbo', 'ActivityPlan', 0;
	EXEC [adm].[usp_GetPlantUml] 'dbo', 'Activity', 0;
	EXEC [adm].[usp_GetPlantUml] 'dbo', 'Company', 0;
	PRINT '@enduml';

END