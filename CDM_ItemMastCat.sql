USE [HEMM]
GO

/****** Object:  StoredProcedure [dbo].[CDM_ItemMastCat]    Script Date: 6/6/2017 10:49:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CDM_ItemMastCat]
	@p_corp_id varchar(max),  --[1]  = '(1000)'
	@p_hide_price char(5),	  --[5]  = 'N'
	@p_pat_chrg char(5),	  --[7]  = '%'
	@p_item_stat varchar(50), --[10] ='(1,2)'
	@p_dbid int				  --[14] = 0   

AS
BEGIN
if object_id('#PACK') is not null
begin
  drop table #PACK
end

if object_id('#FINAL') is not null
begin
  drop table #FINAL
end


declare
	@string  varchar(max),   -- Used to store sql statement for dynamic execution
	@string1 varchar(max),   -- Used to store conditional clauses 
	@c_DB_ID     int,         -- Holds the DB_ID    
	@c_DB_ID_char char(6)      --Holds the DB_ID converted to char

create table #PACK
	(	ITEM_ID 		int 		null,
		ITEM_IDB 		int 		null,
		ITEM_NO 		varchar(15) 	null,
		ITEM_DESCR		varchar(255) 	null,
		ITEM_VEND_ID 	int 		null,
		ITEM_VEND_IDB 	int 		null,
		CORP_ID 		int 		null,
		CORP_IDB 		int	 	null,
		CORP_NAME		varchar(40)	null,
		CORP_ACCT_NO	varchar(40)	null,
		UM_CD 		varchar(16)	null,
		NAME 			varchar(40) 	null,
		VEND_ID 		int 		null,
		VEND_IDB 		int 		null,
		VEND_GRP_NAME 	varchar(40) 	null,
		VEND_CTLG_NO  	varchar(20) 	null,
		MFR_CTLG_NO		varchar(20)	null,
		COMDTY_CD		varchar(16)	null,
		HARZD_CD		varchar(16)	null,
		HZ_TBLE_NAME	varchar(40)	null,
		CM_TBLE_NAME	varchar(40)	null,
		MFR_NAME		varchar(40)	null,
		MFR_ID			int		null,
		MFR_IDB		int		null,
		PRICE			money		null,
		ORDER_UM_CD	varchar(16)	null,
		ITEM_STAT		smallint		null,
		CONT_NO		char(30)		null,
		PAT_CHRG_NO		char(20)		null,
		LATEX_IND		char(1)		null,
		NDC 			char(11)		null,
		GENERIC_CD 		char(16)		null,
		THERAPEUTIC_CD 	char(16)		null,
		GENERIC_STAT 	int		null,
		PAT_CHRG_PRICE	float		null
)

--[1]ITEM_NO	[2]ITEM_DESCR	[3]NAME	[4]VEND_ID	[5]VEND_CTLG_NO	[6]MFR_CTLG_NO	[7]MFR_NAME	
--[8]MFR_ID	[9]ORDER_UM_CD	[10]UM_CD1	[11]TO_QTY1	[12]UM_CD2	[13]TO_QTY2	[14]UM_CD3
create table #FINAL
(		ITEM_ID 		int 		null,
		ITEM_IDB 		int 		null,
		ITEM_NO 		varchar(15) 	null,--[1]
		ITEM_DESCR		varchar(255)	null,--[2]
		LATEX_IND		char(1)		null,
		ITEM_VEND_ID 	int 		null,
		ITEM_VEND_IDB 	int 		null,
		CORP_ID 		int 		null,
		CORP_IDB 		int	 	null,
		CORP_NAME		varchar(40)	null,
		CORP_ACCT_NO	varchar(40)	null,
		NAME 			varchar(40) 	null,--[3]
		VEND_ID 		int 		null,--[4]
		VEND_IDB 		int 		null,
		VEND_GRP_NAME 	varchar(40) 	null,
		VEND_CTLG_NO  	varchar(20) 	null,--[5]
		MFR_CTLG_NO		varchar(20)	null,--[6]
		COMDTY_CD		varchar(16)	null,
		HARZD_CD		varchar(16)	null,
		HZ_TBLE_NAME	varchar(40)	null,
		CM_TBLE_NAME	varchar(40)	null,
		MFR_NAME		varchar(40)	null,--[7]
		MFR_ID			int		null,--[8]
		MFR_IDB		int		null,
		ORDER_UM_CD	varchar(16)	null,--[9]
		ITEM_STAT		smallint		null,
		CONT_NO		char(30)		null,
		PAT_CHRG_NO		char(20)		null,
		NDC 			char(11)		null,
		GENERIC_CD 		char(16)		null,
		THERAPEUTIC_CD  	char(16)		null,
		GENERIC_STAT 	int		null,
		PAT_CHRG_PRICE	float		null,
		UM_CD1		varchar(16)	null,--[10]
		TO_QTY1		float		null,--[11]
		UM_CD2		varchar(16)	null,--[12]
		TO_QTY2 		float		null,--[13]
		UM_CD3		varchar(16)	null,--[14]
		)
set nocount on

if @p_dbid = 0 or @p_dbid is null
    begin
	set ROWCOUNT 1
	select @c_DB_ID = DB_ID
	from DB_ID
        where DB_ID is not null and
        DB_ID <> 0
       set ROWCOUNT 0
    end
else
    select @c_DB_ID = @p_dbid
	select @c_DB_ID_char = convert(char(6),@c_DB_ID)
	
select @string = 
'INSERT INTO #PACK select
		ITEM.ITEM_ID,
		ITEM.ITEM_IDB,
		ITEM.ITEM_NO,
		ITEM.DESCR,
		ITEM_VEND.ITEM_VEND_ID,
		ITEM_VEND.ITEM_VEND_IDB,
		CORP.CORP_ID,
		CORP.CORP_IDB,
		CORP.NAME,
		CORP.ACCT_NO,
		IVP.UM_CD,
		VEND.NAME,
		VEND.VEND_ID,
		VEND.VEND_IDB,
		VEND_GRP.NAME,
		IVP.CTLG_NO,
		ITEM.CTLG_NO,
		ITEM.COMDTY_CD,
		ITEM.HAZARD_CD,
		CODE_TABLE.NAME,
		CODE_TABLE2.NAME,
		MFR.NAME,
		MFR.MFR_ID,
		MFR.MFR_IDB,
		IVP.PRICE,
		ITEM_VEND.ORDER_UM_CD,
		ITEM.STAT,
		CONTRACT.CONTRACT_NO,
		ITEM_CORP_ACCT.PAT_CHRG_NO,
		ITEM.LATEX_IND,
		ITEM.NDC,
		ITEM.GENERIC_CD,
		ITEM.THERAPEUTIC_CD,
		ITEM.GENERIC_STAT,
		ITEM_CORP_ACCT.PAT_CHRG_PRICE
	from
		ITEM
		join ITEM_VEND on
		ITEM.ITEM_ID 	= ITEM_VEND.ITEM_ID  and
		ITEM.ITEM_IDB = ITEM_VEND.ITEM_IDB and
		ITEM.IMPORT_STATUS = 0

		join VEND on
		VEND.VEND_ID 	= ITEM_VEND.VEND_ID and
		VEND.VEND_IDB 	= ITEM_VEND.VEND_IDB and
		ITEM_VEND.SEQ_NO 	= 1 

		join CORP on
		CORP.CORP_ID 	= ITEM_VEND.CORP_ID and
		CORP.CORP_IDB	= ITEM_VEND.CORP_IDB 

		join ITEM_VEND_PKG AS IVP on
		IVP.ITEM_VEND_ID 	= ITEM_VEND.ITEM_VEND_ID and
		IVP.ITEM_VEND_IDB 	= ITEM_VEND.ITEM_VEND_IDB 

		join ITEM_CORP_ACCT on
		ITEM.ITEM_ID		= ITEM_CORP_ACCT.ITEM_ID  and
		ITEM.ITEM_IDB		= ITEM_CORP_ACCT.ITEM_IDB and
		CORP.CORP_ID	= ITEM_CORP_ACCT.CORP_ID  and
		CORP.CORP_IDB	= ITEM_CORP_ACCT.CORP_IDB 

		join MFR on
		ITEM.MFR_ID 		= MFR.MFR_ID and
		ITEM.MFR_IDB 		= MFR.MFR_IDB

		left outer join CODE_TABLE on
		ITEM.HAZARD_CD 	= CODE_TABLE.TYPE_CD 

		left outer join CODE_TABLE as CODE_TABLE2 on
		ITEM.COMDTY_CD	= CODE_TABLE2.TYPE_CD 

		left outer join CONTRACT on
		ITEM_VEND.CONTRACT_ID    = CONTRACT.CONTRACT_ID and
		ITEM_VEND.CONTRACT_IDB   = CONTRACT.CONTRACT_IDB 

		left outer join VEND_GRP on
		VEND.VEND_GRP_ID  = VEND_GRP.VEND_GRP_ID and
		VEND.VEND_GRP_IDB = VEND_GRP.VEND_GRP_IDB 
	where 1=1 ' 
	
	print @string
	
 if @p_corp_id <> '' and @p_corp_id is not null
	select @string1 =  ' and CORP.CORP_ID in ' + @p_corp_id + ' and CORP.CORP_IDB = ' + @c_DB_ID_char
 if @p_item_stat <> '' and @p_item_stat is not null
	 select @string1 = @string1 + ' and ITEM.STAT in ' + @p_item_stat	
if @p_pat_chrg = 'Y'
select @string1 = @string1 + ' and ITEM_CORP_ACCT.PAT_CHRG_NO is not null and ITEM_CORP_ACCT.PAT_CHRG_NO <> '''''
if @p_pat_chrg = 'N'
select @string1 = @string1 + ' and (ITEM_CORP_ACCT.PAT_CHRG_NO is null or ITEM_CORP_ACCT.PAT_CHRG_NO ='''')'	 

select @string = @string + isnull (@string1,'')
exec(@string)


insert #FINAL
select distinct
A.ITEM_ID, A.ITEM_IDB, A.ITEM_NO, A.ITEM_DESCR, A.LATEX_IND, A.ITEM_VEND_ID,A.ITEM_VEND_IDB, A.CORP_ID,
A.CORP_IDB, A.CORP_NAME, A.CORP_ACCT_NO, A.NAME, A.VEND_ID,A.VEND_IDB, A.VEND_GRP_NAME, A.VEND_CTLG_NO,
A.MFR_CTLG_NO,A.COMDTY_CD, A.HARZD_CD,A.HZ_TBLE_NAME,A.CM_TBLE_NAME, A.MFR_NAME, A.MFR_ID, A.MFR_IDB,
A.ORDER_UM_CD,A.ITEM_STAT, A.CONT_NO, A.PAT_CHRG_NO, A.NDC, A.GENERIC_CD,A.THERAPEUTIC_CD,A.GENERIC_STAT, A.PAT_CHRG_PRICE,
B.UM_CD, C.TO_QTY ,C.UM_CD,  D.TO_QTY,
D.UM_CD

	from  #PACK A join ITEM_VEND_PKG_FACTOR B on
	           (A.ITEM_VEND_ID = B.ITEM_VEND_ID
 		and A.ITEM_VEND_IDB = B.ITEM_VEND_IDB
	        and A.UM_CD = B.UM_CD
       		and B.TO_UM_CD = B.UM_CD
		and NOT EXISTS (select 1 from ITEM_VEND_PKG_FACTOR f
			where B.ITEM_VEND_ID = f.ITEM_VEND_ID
        		and B.ITEM_VEND_IDB = f.ITEM_VEND_IDB
			and B.UM_CD = f.TO_UM_CD
			and f.TO_QTY < 1))
	     left outer join ITEM_VEND_PKG_FACTOR C on
	           (B.ITEM_VEND_ID = C.ITEM_VEND_ID
 	        and B.ITEM_VEND_IDB = C.ITEM_VEND_IDB
 	        and B.UM_CD = C.TO_UM_CD
 		and C.UM_CD <> C.TO_UM_CD
	        and C.TO_QTY > 1
	        and C.TO_QTY = (select MIN(k.TO_QTY) from ITEM_VEND_PKG_FACTOR k
                                where B.ITEM_VEND_ID = k.ITEM_VEND_ID
                                and B.ITEM_VEND_IDB = k.ITEM_VEND_IDB
                                and B.UM_CD = k.TO_UM_CD
	                        and k.UM_CD <> k.TO_UM_CD
                                and k.TO_QTY > 1))
             left outer join ITEM_VEND_PKG_FACTOR D on
                   (C.ITEM_VEND_ID = D.ITEM_VEND_ID
                and C.ITEM_VEND_IDB = D.ITEM_VEND_IDB
                and C.UM_CD = D.TO_UM_CD
	        and D.UM_CD <> D.TO_UM_CD
                and D.TO_QTY > 1
	        and D.TO_QTY = (select MIN(m.TO_QTY) from ITEM_VEND_PKG_FACTOR m
                                where C.ITEM_VEND_ID = m.ITEM_VEND_ID
                                and C.ITEM_VEND_IDB = m.ITEM_VEND_IDB
                                and C.UM_CD = m.TO_UM_CD
	                        and m.UM_CD <> m.TO_UM_CD
                                and m.TO_QTY > 1))

if @p_hide_price = 'Y'
begin
select #FINAL.*,  NULL P1, A.CTLG_NO CTLG1, NULL P2,B.CTLG_NO CTLG2, NULL P3, C.CTLG_NO CTLG3 from #FINAL
left outer join ITEM_VEND_PKG A
on (#FINAL.ITEM_VEND_ID = A.ITEM_VEND_ID and
   #FINAL.UM_CD1	=A.UM_CD )
left outer join ITEM_VEND_PKG B
on (#FINAL.ITEM_VEND_ID = B.ITEM_VEND_ID and
   #FINAL.UM_CD2	=B.UM_CD )
left outer join ITEM_VEND_PKG C
on (#FINAL.ITEM_VEND_ID = C.ITEM_VEND_ID and
   #FINAL.UM_CD3	=C.UM_CD )
end

else if @p_hide_price = 'N'
begin
----Create final select

select DISTINCT ITEM_NO,ITEM_DESCR,	NAME,VEND_ID,VEND_CTLG_NO,MFR_CTLG_NO,MFR_NAME,	
		MFR_ID,	ORDER_UM_CD,UM_CD1,	TO_QTY1,UM_CD2,	TO_QTY2,UM_CD3 from #FINAL

end

set nocount off	 	

drop table #PACK
drop table #FINAL
END


GO


