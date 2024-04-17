/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations_smoothed]
      ,[rollingPeople_Vaccinatinated]
      ,[Percent_of]
  FROM [Portafolio Proyect].[dbo].[PercentPopulationVaccinated]