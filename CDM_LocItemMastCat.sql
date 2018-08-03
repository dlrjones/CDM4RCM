USE [HEMM]
GO

/****** Object:  StoredProcedure [dbo].[CDM_LocItemMastCat]    Script Date: 6/6/2017 10:40:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CDM_LocItemMastCat]
	@p_corp_id          varchar(max),--[1]  = '(1000)'
	@p_loc_id           varchar(max),--[2]  = '(2366,2365,1002,1001,2254,2150,2001)'
	@p_print_pat_price  char(1),	 --[8]  ='Y'
    @p_slit_stat        varchar(255),--[15] ='(''1'',''2'')'
	@p_dbid             int			 --[16] =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	create table #LOCCTLG
(
	ITEM_ID		int null,
	ITEM_IDB 	int null,
	ITEM_NO 	char(15) null,
	ITEM_DESC 	varchar(255) null,
	CORP_ID 	int null,
	CORP_IDB 	int null,
	CORP_NAME char(40) null,
	CORP_ACCT_NO 	char(40) null, 
	LOC_ID 		int null,
	LOC_IDB 	int null,		 
	COMDTY_CD 	char(16) null,
	HAZARD_CD 	char(16) null,
	COMDTY_NAME 	char(40) null,
	HAZARD_NAME 	char(40) null,
	UM_CD 			char (16) null,
	QTY 			float null,
	MFR_NAME 		char(40) null,
	ITEM_CTLG_NO 	char(20) null,
	LOC_NAME 		char(40) null,
	PRICE 			float null,
	BIN_TYPE 		int null,
	BIN_LOCATION_ONE   varchar(80) null,
	BIN_LOCATION_TWO   varchar(80) null,
	BIN_LOCATION_THREE varchar(80) null,
	SLOC_STAT 	smallint null,
	LOC_TYPE 	char(1) null,
	VEND_NAME char(40) null,
	VEND_CTLG_NO	varchar(20) null,
	PAT_CHRG_NO	char(20) null,
	PAT_CHRG_PRICE float null,
	LATEX_IND      char(10) null,
	REUSABLE       char(1) null,
	CONSIGNMENT    char(1) null,
	GL_NO          varchar(80) null,
	NDC 			char(11) null,
	GENERIC_CD 	char(16) null,
	THERAPEUTIC_CD char(16) null,
	GENERIC_STAT 	int	null 
)

set nocount on

   declare 

	
	@string  varchar(max),   -- Used to store sql statement for dynamic execution
	@string1 varchar(max),   -- Used to store conditional clauses 
	@string2 varchar(max),   -- Used to store conditional clauses 
	@c_DB_ID     int,         -- Holds the DB_ID    
	@c_DB_ID_char char(6)      --Holds the DB_ID converted to char
	

-- Snippet to handle Database ID extract
If @p_dbid = 0 or @p_dbid is null
    Begin
	Set ROWCOUNT 1
	Select @c_DB_ID = DB_ID
	from DB_ID
        where DB_ID is not null and
        DB_ID <> 0
       Set ROWCOUNT 0
    end
else
    Select @c_DB_ID = @p_dbid
	Select @c_DB_ID_char = convert(char(6),@c_DB_ID)
	
	if @p_corp_id <> '' and @p_corp_id is not null
Select @string1 =  ' and CORP.CORP_ID in ' + @p_corp_id + ' and CORP.CORP_IDB = ' + @c_DB_ID_char

if @p_loc_id <> '' and @p_loc_id is not null
Select @string1 = @string1 + ' and LOC.LOC_ID in ' + @p_loc_id + ' and LOC.LOC_IDB = ' + @c_DB_ID_char 

if @p_slit_stat <> '' and @p_slit_stat is not null
Select @string1 = @string1 + ' and SLOC_ITEM.STAT in ' + @p_slit_stat


Select @string = '
insert into #LOCCTLG
select	ITEM.ITEM_ID,
		ITEM.ITEM_IDB,
		ITEM.ITEM_NO,
          ITEM.DESCR,
		CORP.CORP_ID,
		CORP.CORP_IDB,
		CORP.NAME,
         	CORP.ACCT_NO,
		SLOC_ITEM.LOC_ID,
		SLOC_ITEM.LOC_IDB,
		ITEM.COMDTY_CD,
		ITEM.HAZARD_CD,
		comdty.NAME,
		hazard.NAME,
		SLOC_ITEM.UM_CD,
		SLOC_ITEM.QTY,
		MFR.NAME,
		ITEM.CTLG_NO,
		LOC.NAME,
		dbo.uf_LayerPrice(SLOC_ITEM.LOC_ID,ITEM.ITEM_ID),
		null,
		null,
		null,
		null,
		SLOC_ITEM.STAT,
		LOC.LOC_TYPE,
          VEND.NAME,
          IVP.CTLG_NO,
          SLOC_ITEM.PAT_CHRG_NO,
          SLOC_ITEM.PAT_CHRG_PRICE,
          ITEM.LATEX_IND,
          SLOC_ITEM.REUSE_IND,
          SLOC_ITEM.CONSIGN_IND,
          SUB_ACCT.ACCT_FMT,
		ITEM.NDC,
		ITEM.GENERIC_CD,
		ITEM.THERAPEUTIC_CD,
		ITEM.GENERIC_STAT
from SLOC_ITEM
join ITEM on
(ITEM.ITEM_ID = SLOC_ITEM.ITEM_ID and
 ITEM.ITEM_IDB = SLOC_ITEM.ITEM_IDB) and
 (ITEM.IMPORT_STATUS = 0 or ITEM.IMPORT_STATUS is null)

join LOC on
(LOC.LOC_ID = SLOC_ITEM.LOC_ID and
 LOC.LOC_IDB = SLOC_ITEM.LOC_IDB)

join ITEM_VEND on
(SLOC_ITEM.ITEM_ID  = ITEM_VEND.ITEM_ID and
 SLOC_ITEM.ITEM_IDB = ITEM_VEND.ITEM_IDB) and
(SLOC_ITEM.ITEM_VEND_ID =  ITEM_VEND.ITEM_VEND_ID and
 SLOC_ITEM.ITEM_VEND_IDB = ITEM_VEND.ITEM_VEND_IDB)

join VEND on
(ITEM_VEND.VEND_ID = VEND.VEND_ID and
 ITEM_VEND.VEND_IDB = VEND.VEND_IDB)

join MFR on
(MFR.MFR_ID = ITEM.MFR_ID and
 MFR.MFR_IDB = ITEM.MFR_IDB)

join ITEM_VEND_PKG IVP on
(IVP.ITEM_VEND_ID = ITEM_VEND.ITEM_VEND_ID and
 IVP.ITEM_VEND_IDB = ITEM_VEND.ITEM_VEND_IDB) and
 (IVP.UM_CD = SLOC_ITEM.UM_CD) and 
 (ITEM_VEND.SEQ_NO = 1)

join SUB_ACCT on
(SLOC_ITEM.SUB_ACCT_ID = SUB_ACCT.SUB_ACCT_ID and
 SLOC_ITEM.SUB_ACCT_IDB = SUB_ACCT.SUB_ACCT_IDB)

join CORP on
(LOC.CORP_ID = CORP.CORP_ID and
 LOC.CORP_IDB = CORP.CORP_IDB) and
(ITEM_VEND.CORP_ID = CORP.CORP_ID and
ITEM_VEND.CORP_IDB = CORP.CORP_IDB)

left join CODE_TABLE comdty on
(ITEM.COMDTY_CD = comdty.TYPE_CD and comdty.TYPE_CD like ''CMDY10%'')

left join CODE_TABLE hazard on
(ITEM.HAZARD_CD = hazard.TYPE_CD and hazard.TYPE_CD like ''HZRD10%'')

Where (SLOC_ITEM.STAT =1 or (SLOC_ITEM.STAT =2  and SLOC_ITEM.ITEM_VEND_ID is not null)) ' 

Select @string2 =  '
 union ALL
select	ITEM.ITEM_ID,
		ITEM.ITEM_IDB,
		ITEM.ITEM_NO,
          ITEM.DESCR,
		CORP.CORP_ID,
		CORP.CORP_IDB,
		CORP.NAME,
         	CORP.ACCT_NO,
		SLOC_ITEM.LOC_ID,
		SLOC_ITEM.LOC_IDB,
		COMDTY_CD,
		HAZARD_CD,
		comdty.NAME,
		hazard.NAME,
		SLOC_ITEM.UM_CD,
		SLOC_ITEM.QTY,
		MFR.NAME,
		ITEM.CTLG_NO,
		LOC.NAME,
		0 PRICE,
		null,
		null,
		null,
		null,
		SLOC_ITEM.STAT,
		LOC.LOC_TYPE,
          VEND.NAME,
          null,      ----IVP.CTLG_NO,
          SLOC_ITEM.PAT_CHRG_NO,
          SLOC_ITEM.PAT_CHRG_PRICE,
          ITEM.LATEX_IND,
          SLOC_ITEM.REUSE_IND,
          SLOC_ITEM.CONSIGN_IND,
          SUB_ACCT.ACCT_FMT,
		ITEM.NDC,
		ITEM.GENERIC_CD,
		ITEM.THERAPEUTIC_CD,
		ITEM.GENERIC_STAT
from SLOC_ITEM
join ITEM on
(ITEM.ITEM_ID = SLOC_ITEM.ITEM_ID and
 ITEM.ITEM_IDB = SLOC_ITEM.ITEM_IDB)  and 
 (SLOC_ITEM.STAT in (2,3) and  
 SLOC_ITEM.ITEM_VEND_ID is null) and
(ITEM.IMPORT_STATUS = 0 or ITEM.IMPORT_STATUS is null)

join LOC on
(LOC.LOC_ID = SLOC_ITEM.LOC_ID and
 LOC.LOC_IDB = SLOC_ITEM.LOC_IDB)

join ITEM_VEND on
(SLOC_ITEM.ITEM_ID  = ITEM_VEND.ITEM_ID and
 SLOC_ITEM.ITEM_IDB = ITEM_VEND.ITEM_IDB and
 ITEM_VEND.SEQ_NO = 1)

join VEND on
(ITEM_VEND.VEND_ID = VEND.VEND_ID and
 ITEM_VEND.VEND_IDB = VEND.VEND_IDB)

join MFR on
(MFR.MFR_ID = ITEM.MFR_ID and
 MFR.MFR_IDB = ITEM.MFR_IDB)

join SUB_ACCT on
(SLOC_ITEM.SUB_ACCT_ID = SUB_ACCT.SUB_ACCT_ID and
 SLOC_ITEM.SUB_ACCT_IDB = SUB_ACCT.SUB_ACCT_IDB)

join CORP on
(LOC.CORP_ID = CORP.CORP_ID and
 LOC.CORP_IDB = CORP.CORP_IDB) and
(ITEM_VEND.CORP_ID = CORP.CORP_ID and
 ITEM_VEND.CORP_IDB = CORP.CORP_IDB)

left join CODE_TABLE comdty on
(ITEM.COMDTY_CD = comdty.TYPE_CD and comdty.TYPE_CD like ''CMDY10%'')

left join CODE_TABLE hazard on
(ITEM.HAZARD_CD = hazard.TYPE_CD and hazard.TYPE_CD like ''HZRD10%'')

where 1=1 ' 
 --print @string
-- print @string1
 --print @string2
-- print @string1

exec(@string + @string1 + @string2 + @string1)


update 	#LOCCTLG
set 	BIN_LOCATION_ONE = SLOC_ITEM_BIN.BIN_LOC,
	BIN_TYPE = ISNULL(SLOC_ITEM_BIN.BIN_TYPE,0)
from 	SLOC_ITEM_BIN
where
	#LOCCTLG.ITEM_ID = SLOC_ITEM_BIN.ITEM_ID AND
	#LOCCTLG.ITEM_IDB = SLOC_ITEM_BIN.ITEM_IDB AND
	#LOCCTLG.LOC_ID = SLOC_ITEM_BIN.LOC_ID AND
	#LOCCTLG.LOC_IDB = SLOC_ITEM_BIN.LOC_IDB AND
	SLOC_ITEM_BIN.BIN_LOC_NO = 0

update 	#LOCCTLG
set 	BIN_LOCATION_TWO = SLOC_ITEM_BIN.BIN_LOC,
	BIN_TYPE = ISNULL(SLOC_ITEM_BIN.BIN_TYPE,0)
from 	SLOC_ITEM_BIN
where	
	#LOCCTLG.ITEM_ID = SLOC_ITEM_BIN.ITEM_ID AND
	#LOCCTLG.ITEM_IDB = SLOC_ITEM_BIN.ITEM_IDB AND
	#LOCCTLG.LOC_ID = SLOC_ITEM_BIN.LOC_ID AND
	#LOCCTLG.LOC_IDB = SLOC_ITEM_BIN.LOC_IDB AND
	SLOC_ITEM_BIN.BIN_LOC_NO = 1

update 	#LOCCTLG
set 	BIN_LOCATION_THREE = SLOC_ITEM_BIN.BIN_LOC,
	BIN_TYPE = ISNULL(SLOC_ITEM_BIN.BIN_TYPE,0)
from 	SLOC_ITEM_BIN
where	
	#LOCCTLG.ITEM_ID = SLOC_ITEM_BIN.ITEM_ID AND
	#LOCCTLG.ITEM_IDB = SLOC_ITEM_BIN.ITEM_IDB AND
	#LOCCTLG.LOC_ID = SLOC_ITEM_BIN.LOC_ID AND
	#LOCCTLG.LOC_IDB = SLOC_ITEM_BIN.LOC_IDB AND
	SLOC_ITEM_BIN.BIN_LOC_NO = 2

----Final Select Statement
--	[1]ITEM_NO	  [2]ITEM_DESC	 [3]UM_CD  [4]MFR_NAME	 [5]PRICE	[6]SLOC_STAT	
--  [7]VEND_NAME	[8]VEND_CTLG_NO	[9]PAT_CHRG_NO	[10]PAT_CHRG_PRICE	[11]LOC_NAME

select  
	ITEM_NO,--[1]
	ITEM_DESC,--[2]
	UM_CD,--[3]
	MFR_NAME,--[4]
	PRICE,--[5]
	SLOC_STAT,--[6]
	VEND_NAME,--[7]
	VEND_CTLG_NO,--[8]
	PAT_CHRG_NO,--[9]
	PAT_CHRG_PRICE,--[10]
	LOC_NAME--[11]
	
 from #LOCCTLG
 where LEN(PAT_CHRG_NO) > 0

set nocount off

drop table #LOCCTLG
END


GO


