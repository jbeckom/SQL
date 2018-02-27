USE [adminsys]
GO
/****** Object:  StoredProcedure [dbo].[usp_documentServiceIdCards_get]    Script Date: 2/8/2018 7:37:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE	[dbo].[usp_documentServiceIdCards_get] (
	@cert			CHAR(13)
	,@partyIDlist	VARCHAR(MAX)
)
AS
/*******************************************************************************
Object:  

Arguments:

Description: 
International Medical Group

Revision History:

Date        Project		Author          Comments
2018/02/05	93696		Josh Beckom		Create - to optimize/replace v_DocumentService_IdCard
*******************************************************************************/

SET NOCOUNT ON;

DECLARE	 @insuredData	[udt_docSvcsIdCard_insuredData_tbl]
		,@certData		[udt_docSvcsIdCard_certData_tbl]
		,@partyIDs		[udt_docSvcsIdCard_partyIDs_tbl]
;

/***	RETRIEVE PARTY ID FOR CERT, IF PARAMETER NOT PASSED (HELPS PERFORMANCE IMMENSELY)	***/
IF	@partyIDlist IS NULL
	INSERT INTO	@partyIDs (partyID)
		SELECT	pid.PartyID
		FROM	dbo.policy_insured_detail	AS [pid]
		WHERE	pid.pol_insrd_dtl_cert_nbr	= @cert

ELSE
	INSERT INTO @partyIDs (partyID)
		SELECT	val
		FROM	dbo.tfn_splitCSLtoInt_tbl(@partyIDlist)
;

INSERT INTO	@insuredData 
	SELECT 	 pid.PartyID							AS [PartyID]
			,pid.pol_insrd_dtl_cert_nbr				AS [CertificateNumber]
			,pid.pol_insrd_dtl_seq_nbr				AS [SequenceNumber]
			,pid.pol_insrd_dtl_ext_id				AS [ExternalId_Only]
			,pid.pol_insrd_dtl_insrd_id				AS [InsuredID]
			,'I'									AS [InsuredType]
			,gm.grp_mst_name						AS [GroupName]
			,NULL									AS [MasterInsuredID]
			,im.insrd_mst_name						AS [Name]
			,im.insrd_mst_dob						AS [DateOfBirth]
			,IIF((p.prod_type = 'GLOBAL'),COALESCE(pd.pol_dtl_orig_dt,pid.pol_insrd_dtl_computed_effect_dt),pid.pol_insrd_dtl_computed_effect_dt)	AS [EffectiveDate]
			,pid.pol_insrd_dtl_computed_expire_dt	AS [ExpireDate]
			,pid.pol_insrd_dtl_id_card_ind			AS [IDCardIndicator]


	FROM	dbo.policy_master					AS [pm]
		INNER JOIN dbo.policy_detail			AS [pd]
		ON	pm.pol_mst_cert_nbr	= pd.pol_dtl_cert_nbr
		AND	pm.pol_mst_seq_nbr	= pd.pol_dtl_seq_nbr

		INNER JOIN	dbo.policy_insured_detail	AS [pid]
		ON	pid.pol_insrd_dtl_cert_nbr	= pm.pol_mst_cert_nbr
		AND	pd.pol_dtl_seq_nbr			= pm.pol_mst_seq_nbr

		INNER JOIN	dbo.insured_master			AS [im]
		ON	im.insrd_mst_id	= pid.pol_insrd_dtl_insrd_id

		INNER JOIN	dbo.product					AS [p]
		ON	p.prod_cd	= pm.pol_mst_prod_cd
		/***	ONLY PRIMARY INSUREDS (FOR GLOBAL CERTS)	***/
		AND	(
			p.prod_type	<> 'GLOBAL'
			OR
			(p.prod_type	= 'GLOBAL'	AND pd.pol_dtl_mst_cert_nbr	= pd.pol_dtl_cert_nbr)
		)

		LEFT JOIN	dbo.group_master			AS [gm]
		ON	pm.pol_mst_grp_id	= gm.grp_mst_id

	WHERE	pid.pol_insrd_dtl_cert_nbr	= @cert
		AND	pid.PartyID IN (SELECT partyID FROM @partyIDs)
	
	UNION 

	/***	GROUP/TRAVEL DEPENDANTS	***/
	SELECT	pdd.PartyID							AS [InsuredPartyID]
			,pdd.pol_dpd_dtl_cert_nbr			AS [CertificateNumber]
			,pdd.pol_dpd_dtl_seq_nbr			AS [SequenceNumber]
			,pdd.pol_dpd_dtl_ext_id				AS [ExternalId_Only]
			,pdd.pol_dpd_dtl_dpd_insrd_id		AS [InsuredID]
			,'D'								AS [InsuredType]
			,gm.grp_mst_name					AS [GroupName]
			,pdd.pol_dpd_dtl_mst_insrd_id		AS [MasterInsuredID]
			,im.insrd_mst_name					AS [Name]
			,im.insrd_mst_dob					AS [DateOfBirth]
			,pdd.pol_dpd_dtl_computed_effect_dt	AS [EffectiveDate]
			,pdd.pol_dpd_dtl_computed_expire_dt	AS [ExpireDate]
			,pdd.pol_dpd_dtl_id_card_ind		AS [IDCardIndicator]

	FROM	dbo.policy_master					AS [pm]
		INNER JOIN	dbo.policy_detail			AS [pd]
		ON	pd.pol_dtl_cert_nbr	= pm.pol_mst_cert_nbr
		AND	pd.pol_dtl_seq_nbr	= pm.pol_mst_seq_nbr

		INNER JOIN	dbo.policy_dependant_detail	AS [pdd]
		ON	pdd.pol_dpd_dtl_cert_nbr	= pm.pol_mst_cert_nbr
		AND	pdd.pol_dpd_dtl_seq_nbr		= pm.pol_mst_seq_nbr

		INNER JOIN	dbo.insured_master			AS [im]
		ON	im.insrd_mst_id	= pdd.pol_dpd_dtl_dpd_insrd_id

		INNER JOIN	dbo.product					AS [p]
		ON	p.prod_cd	= pm.pol_mst_prod_cd

		LEFT JOIN	dbo.group_master			AS [gm]
		ON	pm.pol_mst_grp_id	= gm.grp_mst_id

	WHERE	pdd.pol_dpd_dtl_cert_nbr	= @cert
		AND	pdd.PartyID IN (SELECT partyID FROM @partyIDs)
	
	UNION 

	/***	GLOBAL DEPENDANTS	***/
	SELECT	pid.PartyID								AS [PartyID]
			,pid.pol_insrd_dtl_cert_nbr				AS [CertificateNumber]
			,pid.pol_insrd_dtl_seq_nbr				AS [SequenceNumber]
			,pid.pol_insrd_dtl_ext_id				AS [ExternalId_Only]
			,pid.pol_insrd_dtl_insrd_id				AS [InsuredID]
			,'D'									AS [InsuredType]
			,NULL									AS [GroupName]
			,masters.MasterInsuredID				AS [MasterInsuredID]
			,im.insrd_mst_name						AS [Name]
			,im.insrd_mst_dob						AS [DateOfBirth]
			,IIF((p.prod_type = 'GLOBAL'),COALESCE(pd.pol_dtl_orig_dt,pid.pol_insrd_dtl_computed_effect_dt),pid.pol_insrd_dtl_computed_effect_dt)	AS [EffectiveDate]
			,pid.pol_insrd_dtl_computed_expire_dt	AS [ExpireDate]
			,pid.pol_insrd_dtl_id_card_ind			AS [IDCardIndicator]

	FROM	dbo.policy_master					AS [pm]
		INNER JOIN	dbo.policy_detail			AS [pd]
		ON	pd.pol_dtl_cert_nbr	= pm.pol_mst_cert_nbr
		AND	pd.pol_dtl_seq_nbr	= pm.pol_mst_seq_nbr

		INNER JOIN	dbo.policy_insured_detail	AS [pid]
		ON	pid.pol_insrd_dtl_cert_nbr	= pm.pol_mst_cert_nbr
		AND	pid.pol_insrd_dtl_seq_nbr	= pm.pol_mst_seq_nbr

		INNER JOIN	dbo.insured_master			AS [im]
		ON	im.insrd_mst_id	= pid.pol_insrd_dtl_insrd_id

		INNER JOIN	dbo.product					AS [p]
		ON	p.prod_cd	= pm.pol_mst_prod_cd
		AND	p.prod_type	= 'GLOBAL'
		/***	ONLY DEPENDANTS	***/
		AND	pd.pol_dtl_mst_cert_nbr	<> pd.pol_dtl_cert_nbr

		INNER JOIN	(
			SELECT	pid_master.pol_insrd_dtl_insrd_id	AS [MasterInsuredID]
					,pd_sub.pol_dtl_cert_nbr				AS [CertificateNumber]
					,pd_sub.pol_dtl_seq_nbr				AS [SequenceNumber]
			
			FROM	dbo.policy_detail					AS [pd_sub]
				INNER JOIN	dbo.policy_insured_detail	AS [pid_master]
				ON	pid_master.pol_insrd_dtl_cert_nbr	= pd_sub.pol_dtl_mst_cert_nbr
				AND	pid_master.pol_insrd_dtl_seq_nbr	=	(
					SELECT	MAX(pm_master.pol_mst_seq_nbr)
					FROM	dbo.policy_master	AS [pm_master]
					WHERE	pd_sub.pol_dtl_mst_cert_nbr	= pm_master.pol_mst_cert_nbr
				)
		)										AS [masters]
		ON	masters.CertificateNumber	= pm.pol_mst_cert_nbr
		AND	masters.SequenceNumber		= pm.pol_mst_seq_nbr

	WHERE	pid.pol_insrd_dtl_cert_nbr	= @cert
		AND	pid.PartyID IN (SELECT partyID FROM @partyIDs)
;

INSERT INTO	@certData 
	SELECT	RTRIM(pm.pol_mst_cert_nbr)							AS [CertificateNumber]
			,pm.pol_mst_seq_nbr									AS [SequenceNumber]
			,pm.pol_mst_effect_dt								AS [EffectiveDate]
			,pm.pol_mst_expire_dt								AS [ExpireDate]
			,pd.pol_dtl_network_effect_dt						AS [PlanEffectiveDate]
			,pm.pol_mst_prod_cd									AS [ProductCode]
			,pm.pol_mst_app_type								AS [ProductAppType]
			,pm.pol_mst_curr_cd									AS [CurrencyCode]
			,COALESCE(pm.pol_mst_sold_dt,pm.pol_mst_create_dt)	AS [SoldDate]
			,pd.pol_dtl_deduct									AS [Deductible]
			,pm.pol_mst_agent_id								AS [AgentID]
			,p.prod_type										AS [CertificateType]
			,pd.pol_dtl_pay_freq_cd								AS [InvoiceFrequency]

	FROM	dbo.policy_master			AS [pm]
		INNER JOIN	dbo.policy_detail	AS [pd]
		ON	pd.pol_dtl_cert_nbr	= pm.pol_mst_cert_nbr
		AND	pd.pol_dtl_seq_nbr	= pm.pol_mst_seq_nbr

		INNER JOIN	dbo.Product			AS [p]
		ON	p.prod_cd	= pm.pol_mst_prod_cd

	WHERE	(pm.pol_mst_cert_nbr	= @cert	OR @cert IS NULL)
;

SELECT	DISTINCT
	vi.PartyID																									AS [InsuredPartyID]
	,COALESCE(vi.ExternalId_Only,CONVERT(VARCHAR(100),vi.InsuredID))											AS [InsuredID]
	,vc.CertificateNumber																						AS [CertificateNumber]
	,vc.SequenceNumber																							AS [CertificateSequence]
	,vc.ProductCode																								AS [ProductCode]
	,dbo.fn_property_prod_app_type_string_select(66,vc.ProductCode,vc.ProductAppType,vc.SoldDate)				AS [Plan]
	,AreaOfCover.aoc																							AS [AreaOfCover]
	,vc.ProductAppType																							AS [AppType]
	,vi.InsuredType																								AS [InsuredType]
	,UPPER(REPLACE(CONVERT(VARCHAR, vc.EffectiveDate	, 106), ' ', '-'))										AS [CertificateEffectiveDate]
	,UPPER(REPLACE(CONVERT(VARCHAR, vc.[ExpireDate]	, 106), ' ', '-'))											AS [CertificateExpireDate]
	,UPPER(REPLACE(CONVERT(VARCHAR, vc.PlanEffectiveDate	, 106), ' ', '-'))									AS [PlanEffectiveDate]
	/***	NETWORK EFFECTIVE DATE = LATER OF INSURED EFFECT DATE OR GROUP EFFECT DATE W/ NETWORK, PER UHI REQS	***/
	,CASE
		WHEN vc.PlanEffectiveDate	IS NULL					THEN UPPER(REPLACE(CONVERT(VARCHAR, vi.EffectiveDate, 106),' ','-'))
		WHEN vi.EffectiveDate		> vc.PlanEffectiveDate	THEN UPPER(REPLACE(CONVERT(VARCHAR, vi.EffectiveDate, 106),' ','-'))
		ELSE UPPER(REPLACE(CONVERT(VARCHAR, vc.PlanEffectiveDate, 106),' ','-'))
	END																											AS [NetworkEffectiveDate]
	,vc.ProductCode																								AS [CertificateProductCode]
	,IIF((p.prod_type	= 'GLOBAL'), '99990565',pd.pol_dtl_URX_group_id)										AS [CertificateGroupId]
	,vc.CurrencyCode																							AS [CertificateCurrency]
	,vc.Deductible																								AS [CertificateDeductible]
	,vi.GroupName																								AS [InsuredGroupName]
	,CASE 
		WHEN mpd.pol_insrd_dtl_ext_id IS NOT NULL THEN mpd.pol_insrd_dtl_ext_id  --69840
		WHEN vi.MasterInsuredId IS NOT NULL THEN CONVERT(VARCHAR(100), vi.MasterInsuredId)  --69840
		WHEN vi.ExternalId_Only IS NOT NULL THEN vi.ExternalId_Only  --69840
		ELSE CONVERT(VARCHAR(100), vi.InsuredID)
	END																											AS [PrimaryInsuredId]
	/***	LEFT PAD INSURED ID w/ ZEROS, TOTAL 11 DIGITS (PER UHC REQS)	***/
	,RIGHT(CONCAT(REPLICATE('0',11),COALESCE(vi.MasterInsuredID,vi.InsuredId)),11)								AS [MemberID]
	,vi.[Name]																									AS [InsuredName]
	,vi.DateOfBirth																								AS [InsuredDob]
	,ti.insrd_mst_gender																						AS [InsuredGender]
	,vi.ExternalId_Only																							AS [InsuredExternalId]
	,UPPER(REPLACE(CONVERT(VARCHAR, vi.EffectiveDate, 106), ' ', '-'))											AS [InsuredCertificateEffectiveDate]
	,UPPER(REPLACE(CONVERT(VARCHAR, vi.[ExpireDate], 106), ' ', '-'))											AS [InsuredCertifcateExpirationDate]
	,mi.insrd_mst_name																							AS [PrimaryInsuredName]
	,mpd.pol_insrd_dtl_ext_id																					AS [PrimaryInsuredExternalID]
	,mi.insrd_mst_dob																							AS [PrimaryInsuredDob]
	,mi.insrd_mst_gender																						AS [PrimaryInsuredGender]
	,UPPER(REPLACE(CONVERT(VARCHAR, mpd.pol_insrd_dtl_computed_effect_dt, 105), ' ', '-'))						AS [PrimaryInsuredCertificateEffectiveDate]
	,UPPER(REPLACE(CONVERT(VARCHAR, mpd.pol_insrd_dtl_computed_expire_dt, 105), ' ', '-'))						AS [PrimaryInsuredCertificateExpirationDate]
	,ti.insrd_mst_ssn_passport																					AS [InsuredSsnPassport]
	,COALESCE(a.agent_cntct_name,a.agent_name,'')																AS [AgentName]
	,aa.Line1																									AS [AgentAddressLine1]
	,aa.Line2																									AS [AgentAddressLine2]
	,aa.City																									AS [AgentAddressCity]
	,ast.state_desc																								AS [AgentAddressState]
	,ac.cntry_desc																								AS [AgentAddressCountry]
	,aa.PostalCode																								AS [AgentAddressPostalCode]
	,ap.PhoneNumber																								AS [AgentPhone]
	,af.PhoneNumber																								AS [AgentFax]
	,agentEmail.email																							AS [AgentEmail]
	,agentUrl.[url]																								AS [AgentUrl]
	,ap.Extension																								AS [AgentPhoneExtension]
	,DocumentFileName.doc_filename																				AS [DocumentFilename]
	,[AreaOfCoverDescriptionFull].prop_prod_val_desc															AS [AreaOfCoverDescriptionFull]
	/***	FOR SUBPLANS OTHER THAN GLOBEHOPPER TO BE USED FOR ID CARDS, ADD BELOW	***/
	,CASE (p.ProductFamilyCode)
		WHEN 'GLOBEHOPPER'				THEN 'Single-Trip'
		WHEN 'GLOBEHOPPER_PLATINUM'		THEN 'Platinum'
		WHEN 'GLOBEHOPPER_MULTITRIP'	THEN 'Multi-Trip'
		ELSE ''
	END																											AS [SubPlan]
	,p.UHCICustomerNumber																						AS [GroupNumber]
	,UPPER(REPLACE(CONVERT(VARCHAR, pd.pol_dtl_orig_dt, 106), ' ', '-'))										AS [CertificateOriginalEffectiveDate]
	,CAST(IIF(((vc.CertificateType = 'GROUP') AND (vi.IDCardIndicator = 0) AND (vc.InvoiceFrequency <> 'E')),0,1) as BIT)	AS [CanSendIDCard]

FROM	@insuredData		AS [vi]
	INNER JOIN @certData	AS [vc]
	ON	vc.CertificateNumber	= vi.CertificateNumber
	AND	vc.SequenceNumber		= vi.SequenceNumber

	LEFT JOIN	dbo.policy_detail			AS [pd]
	ON	pd.pol_dtl_cert_nbr	= vc.CertificateNumber
	AND	pd.pol_dtl_seq_nbr	= vc.SequenceNumber

	/***	PRIMARY INSURED INFO, IF INSURED IS NOT PRIMARY	***/
	LEFT JOIN	dbo.insured_master			AS [mi]
	ON	vi.MasterInsuredID	= mi.insrd_mst_id
	
	/***	MASTER POLICY DETAIL RECORDS	***/
	LEFT JOIN	dbo.policy_insured_detail	AS [mpd]
	ON	mpd.pol_insrd_dtl_insrd_id	= mi.insrd_mst_id
	AND	mpd.pol_insrd_dtl_cert_nbr	= vi.CertificateNumber
	AND	mpd.pol_insrd_dtl_seq_nbr	= vi.SequenceNumber

	/***	INSURED INFO	***/
	LEFT JOIN	dbo.insured_master			AS [ti]
	ON	vi.InsuredID	= ti.insrd_mst_id

	LEFT JOIN	dbo.agent					AS [a]
	ON	vc.AgentID	= a.agent_id

	LEFT JOIN	dbo.PostalAddress			AS [aa]
	ON	aa.PartyID					= a.PartyID
	AND	aa.PostalAddressUsageCode	= 'MKTG'

	LEFT JOIN	dbo.[State]					AS [ast]
	ON	aa.StateCode	= ast.state_cd

	LEFT JOIN	dbo.country					AS [ac]
	ON	aa.CountryID	= ac.cntry_id

	LEFT JOIN	dbo.TelephoneNumber			AS [ap]
	ON	ap.PartyID						= a.PartyID
	AND	ap.TelephoneNumberTypeCode	= 'PHONE'
	AND	ap.TelephoneNumberUsageCode	= 'BIZNIS'
	AND	ap.ActiveIndicator			= 1
	AND	ap.PrimaryIndicator			= 1

	LEFT JOIN	dbo.TelephoneNumber			AS [af]
	ON	af.PartyID					= a.PartyID
	AND	af.TelephoneNumberTypeCode	= 'FAX'
	AND	af.TelephoneNumberUsageCode	= 'BIZNIS'
	AND	af.ActiveIndicator			= 1
	AND	af.PrimaryIndicator			= 1

	LEFT JOIN	dbo.product					AS [p]
	ON	vc.ProductCode	= p.prod_cd

	OUTER APPLY (
		SELECT	TOP(1) ppv.prop_prod_val_value	AS aoc
		FROM	dbo.property_product_value	AS [ppv]
		WHERE	ppv.prop_prod_val_prop_id	= 2
			AND	ppv.prop_prod_val_prod_cd	= vc.productCode
			AND	(
				ppv.prop_prod_val_effect_dt	<= vc.SoldDate
				OR
				ppv.prop_prod_val_expire_dt	IS NULL
			)
			
	)										AS [AreaOfCover]

	OUTER APPLY (
		SELECT	TOP (1)	EContact	AS [email]
		FROM	dbo.EContact
		WHERE	EContactTypeCode	= 'EMAIL'
			AND	EContactUsageCode	= 'BIZNIS'
			AND	PartyID				= a.PartyID
		ORDER BY PrimaryIndicator
	)										AS [agentEmail]

	OUTER APPLY (
		SELECT TOP (1) EContact		AS [url]
		FROM	dbo.EContact
		WHERE	EContactTypeCode	= 'URL'
			AND	EContactUsageCode	= 'BIZNIS'
			AND PartyID				= a.PartyID
			AND ActiveIndicator		= 1
		ORDER BY PrimaryIndicator
	)										AS [AgentUrl]

	OUTER APPLY (
		SELECT	TOP (1)	d.doc_filename
		FROM	dbo.document								AS [d]
			INNER JOIN	dbo.document_version				AS [dv]
			ON	dv.doc_ver_id			= d.doc_id
			AND	dv.doc_ver_type_cd_id	= 506

			INNER JOIN	dbo.certificate_document_version	AS [cdv]
			ON	cdv.cert_doc_ver_doc_ver_id	= dv.doc_ver_id
			AND	cdv.cert_doc_ver_cert_nbr	= vc.CertificateNumber
			AND	cdv.cert_doc_ver_seq_nbr	= vc.SequenceNumber
	)										AS [DocumentFileName]

	OUTER APPLY (
		SELECT	TOP(1)	prop_prod_val_desc
		FROM	dbo.property_product_value
		WHERE	prop_prod_val_prop_id		= 2
			AND	prop_prod_val_prod_cd		= vc.ProductCode
			AND	(
				prop_prod_val_effect_dt	<= vc.SoldDate
				OR
				prop_prod_val_effect_dt	IS NULL
			)
			AND (
				prop_prod_val_expire_dt > vc.SoldDate
				OR
				prop_prod_val_expire_dt	IS NULL
			)
		ORDER BY prop_prod_val_id
	)										AS [AreaOfCoverDescriptionFull]
;
GO

GRANT EXECUTE
	ON	dbo.usp_documentServiceIdCards_get
	TO	db_documentserviceimguser
;
GO