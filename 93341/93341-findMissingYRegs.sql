SELECT	 ',('''+CAST(cs.case_tag AS VARCHAR(20))+''','''+CAST(Y_Reg_Number.pak_value AS VARCHAR(20))+''')'
FROM dbo.ct_case				[cs]
	INNER JOIN dbo.e_pstor		[Client_Code]			/* Code: Client Code */
		ON [Client_Code].source_id						= cs.ct_id
			AND [Client_Code].ptype_id					= '{6E0ACB70-BF03-4BD3-9B2E-4DCAE9EC55C4}'
	
	INNER JOIN dbo.e_pstor		[Product]				/* Code: Product */
		ON [Product].source_id							= cs.ct_id
			AND [Product].ptype_id						= '{8BBC43BE-7CD1-4FD5-A128-92003BE8FFE0}'
	
	INNER JOIN dbo.e_pstor		[Appointment_Type]		/* Code: Appointment Type */
		ON [Appointment_Type].source_id					= cs.ct_id
			AND [Appointment_Type].ptype_id				= '{b87fce85-db1b-4e69-b66c-08c67406f20c}'
	
	INNER JOIN dbo.e_pstor		[Y_Reg_Number]			/* Code: Y-Reg Number */
		ON [Y_Reg_Number].source_id						= cs.ct_id
			AND [Y_Reg_Number].ptype_id					= '{e3d4c7a1-7dfd-4273-94be-3510e1371683}'
	
	INNER JOIN dbo.e_pstor		[Date_of_Appointment]	/* Code: Date of Appointment */
		ON [Date_of_Appointment].source_id				= cs.ct_id
			AND [Date_of_Appointment].ptype_id			= '{403E7C6A-05B6-4DF7-84E0-115DBF615F2D}'
	
	INNER JOIN dbo.ct_rstor		[rstor_Insured]			/* Relation: Insured */
		ON [rstor_Insured].source_id					= cs.ct_id
			AND [rstor_Insured].rtype_id				= '{F73FEE77-1D81-4176-8F16-4A606C6F324E}'

	LEFT JOIN dbo.e_pstor		[ApptLoc]				/* Code: Appointment Location */
		ON ApptLoc.source_id							= cs.ct_id
			AND ApptLoc.ptype_id						= '{da487791-d8c6-4766-9cfd-e70c3c374c53}'

	LEFT JOIN dbo.ct_entit		[Insured]				/* Entity: Insured */
		ON [rstor_Insured].[entity_id]					= [Insured].ct_id

	LEFT JOIN dbo.ct_pstor		[Inmate_Number]			/* Code: Inmate Number */
		ON [Inmate_Number].source_id					= [Insured].ct_id
			AND [Inmate_Number].ptype_id				= '{697822c8-6df3-4ba9-b1a8-af00114b5d2f}'

	LEFT JOIN dbo.ct_pstor		[DOB]					/* Code: DOB */
		ON [DOB].source_id								= [Insured].ct_id
			AND [DOB].ptype_id							= '{CD2AABE3-7527-4327-AF65-32B067F0B39C}'

	LEFT JOIN dbo.ct_pstor		[Gender]				/* Code: Gender */
		ON [Gender].source_id							= [Insured].ct_id
			AND [Gender].ptype_id						= '{63EBA8D1-EA73-40E2-99A5-51F1C7DFFE0A}'

	LEFT JOIN dbo.ct_pstor		[effectiveDates]
		ON effectiveDates.source_id						= insured.ct_id
			AND effectiveDates.ptype_id					= '{62E2E16D-13F5-4676-A95E-8A376E761AFA}'

	LEFT JOIN ct_rstor			[rstor_Facility]		/* Relation: Facility */
		ON [rstor_Facility].source_id					= cs.ct_id
			AND [rstor_Facility].rtype_id				= '{4DC51AF2-6907-4B07-AF22-4C07A2FAB4A4}'  

	LEFT JOIN ct_entit			[Facility]				/* Entity: Facility */
		ON [rstor_Facility].[entity_id]					= [Facility].ct_id

	LEFT JOIN ct_rstor			[rstor_Physician]		/* Relation: Physician */
		ON rstor_Physician.source_id					= cs.ct_id
			AND rstor_Physician.rtype_id				= '{7ABA28CD-63CA-4D58-821A-B2CCAFD29181}'

	LEFT JOIN ct_entit			[Physician]				/* Entity: Physician */
		ON rstor_Physician.[entity_id]					= Physician.ct_id

WHERE cs.ctype_id = '{4009007a-d25b-472c-9d6f-11b338573697}'
	AND	[Client_Code].pak_value = 'FBOP'
	--AND	NULLIF(CAST(Date_of_Appointment.pak_value AS DATE),'') > (GETDATE()-90)
	AND	NULLIF(CAST(Y_Reg_Number.pak_value AS VARCHAR(20)),'')	IS NOT NULL
	AND	cs.case_tag	IN (
		'0HONO302932S'
		,'0HONO302956S'
		,'0HONO302955S'
		,'0HONO302960S'
		,'0HONO302943S'
		,'0HONO302961S'
		,'0HONO302935S'
		,'0HONO302904S'
		,'0HONO302947S'
		,'0HONO302953S'
		,'0HONO302950S'
		,'0HONO302959S'
		,'0HONO302924S'
		,'0HONO302931S'
		,'0HONO302945S'
		,'0HONO302942S'
		,'0HONO302939S'
		,'0HONO302922S'
		,'0HONO302958S'
		,'0HONO302936S'
		,'0HONO302377S'
		,'0OTIS306175S'
		,'0OTIS306182S'
		,'0OTIS306179S'
		,'0OTIS306185S'
		,'0OTIS306189S'
		,'0OTIS306193S'
		,'0OTIS306173S'
		,'0OTIS306191S'
		,'0OTIS306148S'
		,'0OTIS303988S'
		,'0OTIS306650S'
		,'0OTIS307085S'
		,'0OTIS307082S'
		,'0OTIS307068S'
		,'0OTIS306147S'
		,'0OTIS307360S'
		,'0OTIS306923S'
		,'0OTIS307913S'
		,'0OTIS307974S'
		,'0OTIS308273S'
		,'0HONO308506S'
		,'0HONO307747S'
		,'0HONO305237S'
		,'0HONO308517S'
		,'0OTIS308703S'
		,'0OTIS308707S'
		,'0OTIS308728S'
		,'0OTIS308695S'
		,'0OTIS309400S'
		,'0OTIS309336S'
		,'0OTIS309355S'
		,'0OTIS309373S'
		,'0OTIS309369S'
		,'0OTIS309398S'
		,'0OTIS308697S'
		,'0OTIS309346S'
		,'0OTIS309477S'
		,'0OTIS309559S'
		,'0OTIS309345S'
		,'0OTIS310212S'
		,'0OTIS310206S'
		,'0HONO305239S'
		,'0OTIS309949S'
		,'0HONO307047S'
		,'0HONO303409S'
		,'0OTIS309405S'
		,'0OTIS310500S'
		,'0OTIS308693S'
		,'0OTIS309360S'
		,'0OTIS309366S'
		,'0HONO307039S'
		,'0OTIS310761S'
		,'0OTIS310763S'
		,'0HONO304548S'
		,'0OTIS308698S'
		,'0OTIS309558S'
		,'0HONO306075S'
		,'0OTIS312394S'
		,'0HONO312660S'
		,'0OTIS313353S'
		,'0HONO313593S'
		,'0HONO314079S'
		,'0OTIS313443S'
		,'0OTIS314843S'
	)
;