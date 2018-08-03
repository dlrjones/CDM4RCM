using System;
using System.Collections;
using System.Data;
using System.Net.Mail;
using OleDBDataManager;
using SpreadsheetLight;
using System.Text.RegularExpressions;
namespace CDMReportClass
{
    internal class CDMRevCycle : CDMMaster
    {
        private Hashtable colHeaders = new Hashtable();

        public void InitReport()
        {
            Init();
            LoadDataSet();
            if (ExportFile())
            {
                SendMail();
            }
            else
            {
                EmptyDataSet();
            }
        }

        private bool ExportFile()
        {
            SLDocument sld = new SLDocument();
            string mssg = "There's Nothing to Export";
            string catalog = ""; //added to remove errant \r\t in the catalog number 
            string re = @"[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u10000-\u10FFFF]";
            int dataColNo = 0;
            int colNo = 1;
            int rowNo = 1;
            bool goodToGo = false;

            try
            {
                LoadColHeaders();

                for (int i = 1; i <= MAX_COLS; i++)
                    sld.SetCellValue(rowNo, i, colHeaders[i].ToString());
     
                foreach (DataRow dr in dsAlloc.Tables[0].Rows)
                {                               
                    dataColNo = 0;
                    colNo = 1;
                    rowNo++;                    
                    foreach (object colData in dr.ItemArray)
                    {
                        //this is intended to trap invalid XML 1.0 chars  - &#x1F in particular (although it's valid in XML 1.1)
                        export = Regex.Replace(colData.ToString().Trim(), re, "");

                        if (dataColNo == 6) //Manufacturer Catalog Number 
                        {
                            if (export.Contains(CRLF))             //remove errant \r\t in the catalog number        
                                export = RemoveCRLF(export);
                        }

                        if (dataColNo == 7) //Issue Unit 
                        {
                            export = TrimUOM(export);
                        }

                        sld.SetCellValue(rowNo, colNo++, export);
                        dataColNo++;                        
                    }
                }
                sld.SaveAs(backupPath + currentFileName);
                goodToGo = true;
            }
            //Charge Code 	Item Number	  Item Description	 Vendor Name	  Vendor Catalog Number	  Manufacturer Name	
            //Manufacturer Catalog Number	Issue Unit	Issue Unit Cost	  Price	  Location
            catch (IndexOutOfRangeException ex)
            {
                AppendText("ExportFile - Index OOR: " + ex.Message);
            }
            catch (Exception ex)
            {
                AppendText("ExportFile: " + ex.Message);
            }
            return goodToGo;
        }

        private void LoadDataSet()
        {
            int rowCount = 0;
            int indx = 0;
            int rowTotal = 0;
            string catalog = ""; //added 11/12/13 to remove errant \r\t in the catalog number 
          
            //June Tate's col's
            //Charge Code 	Item Number	  Item Description	 Vendor Name	  Vendor Catalog Number	  Manufacturer Name	
            //Manufacturer Catalog Number	Issue Unit	Issue Unit Cost	  Price	  Location

            ODMRequest Request = new ODMRequest();
            Request.ConnectString = dbConnectString;
            Request.CommandType = CommandType.Text;
            Request.Command = BuildCDMReport();  //"uwm_BIAdmin.dbo.sp_hmcmm_CDM_REPORT";
            string itemNmbr = "";
            try
            {
                currentFileName += GetDate();
                if (locName) //added 11/7/13 to provide Location Name to June Tate
                    currentFileName += "_HRCM";
                currentFileName += ".xlsx";
                dsAlloc = ODMDataSetFactory.ExecuteDataSetBuild(ref Request);
                rowCount = dsAlloc.Tables[0].Rows.Count;
                AppendText(rowCount, false);
                done = true;
            }
            catch (Exception dbx)
            {
                AppendText("ERROR: LoadDataSet() " + "INDEX: " + indx + " Count: " + rowCount + "   " +
                    dbx.Message);
            }

        }

        private void SendMail()
        {
            string[] mailList = emailList.Split(";".ToCharArray());
            string[] ccList = emailCopyTo.Split(";".ToCharArray());
            try
            {
                foreach (string recipient in mailList)
                {
                    if (recipient.Trim().Length > 0)
                    {                      
                        MailMessage mail = new MailMessage();
                        SmtpClient SmtpServer = new SmtpClient("smtp.uw.edu");
                        mail.To.Add(recipient);
                        mail.From = new MailAddress("pmmhelp@uw.edu");
                        if (emailCopyTo.Length > 0)
                        {
                            foreach (string cc in ccList)
                            {
                                mail.CC.Add(cc);
                            }
                        }                      
                        mail.Subject = "CDM Report for " + GetMonthName(-1);
                        mail.Body = (firstName.Length > 0
                            ? firstName + "," + Environment.NewLine + Environment.NewLine
                            : "") +
                                    "Here's the latest CDM RPT for " + GetMonthName(-1) +
                                    Environment.NewLine +
                                    Environment.NewLine +
                                    Environment.NewLine +
                                    Environment.NewLine +
                                    Environment.NewLine +
                                    "PMMHelp" + Environment.NewLine +
                                    "UW Medicine Harborview Medical Center" + Environment.NewLine +
                                    "Supply Chain Management Informatics" + Environment.NewLine +
                                    "206-598-0044" + Environment.NewLine +
                                    "pmmhelp@uw.edu";
                        mail.ReplyToList.Add(emailReplyTo);

                        Attachment attachment;
                        attachment =
                            new System.Net.Mail.Attachment(backupPath + currentFileName);

                        mail.Attachments.Add(attachment);

                        SmtpServer.Port = 587;
                        SmtpServer.Credentials = new System.Net.NetworkCredential("pmmhelp", GetKey());
                        SmtpServer.EnableSsl = true;
                        SmtpServer.Send(mail);
                        AppendText("Process/SendMail:  " + recipient);
                        if (emailCopyTo.Length > 0)
                            AppendText("Process/Send_Mail/CC:  " + emailCopyTo);
                    }
                }
            }
            catch (Exception ex)
            {
                string mssg = ex.Message;
                AppendText("Process/SendMail_:  " + mssg);
            }
        } 

        private string BuildCDMReport()
        {
            string cdm = "";

            cdm =
                "create table #LIMC(ITEM_NO varchar(255),ITEM_DESC varchar(255),UM_CD varchar(255),MFR_NAME varchar(255)," +
                "PRICE varchar(255),SLOC_STAT varchar(255),VEND_NAME varchar(255),VEND_CTLG_NO varchar(255)," +
                "PAT_CHRG_NO varchar(255),PAT_CHRG_PRICE varchar(255),LOC_NAME varchar(255)) " +
                "INSERT INTO #LIMC  EXEC CDM_LocItemMastCat '(1000)','(2366,2365,1002,1001,2254,2150,2001)','Y','(''1'',''2'')',0  ";
            cdm+=
                "create table #IMC(ITEM_NO varchar(255),ITEM_DESCR varchar(255),NAME varchar(255),VEND_ID varchar(255)," +
                "VEND_CTLG_NO varchar(255),MFR_CTLG_NO varchar(255),MFR_NAME varchar(255),MFR_ID varchar(255)," +
                "ORDER_UM_CD varchar(255),UM_CD1 varchar(255),TO_QTY1 varchar(255),UM_CD2 varchar(255),TO_QTY2 varchar(255)," +
                "UM_CD3 varchar(255)) " +
                "INSERT INTO #IMC EXEC CDM_ItemMastCat '(1000)','N','%','(1,2)',0 ";
            cdm +=
                "CREATE TABLE #CDM_MFR (MFR_ID INT,MFR_NAME VARCHAR(40), MFR_NO VARCHAR(8)) " +
                "INSERT INTO #CDM_MFR " +
                "SELECT MFR_ID,NAME, MFR_NO FROM dbo.MFR ORDER BY MFR_ID " +
                "CREATE TABLE #CDM_VEND (VEND_ID INT,VEND_CODE VARCHAR(20),NAME VARCHAR(40)) " +
                "INSERT INTO #CDM_VEND SELECT VEND_ID, VEND_CODE, NAME FROM dbo.VEND ORDER BY VEND_ID ";
            cdm +=
                "SELECT #LIMC.PAT_CHRG_NO,#LIMC.ITEM_NO,#LIMC.ITEM_DESC,#LIMC.VEND_NAME, #LIMC.VEND_CTLG_NO," +
                "#CDM_MFR.MFR_NAME,#IMC.MFR_CTLG_NO, #LIMC.UM_CD, #LIMC.PRICE, #LIMC.PAT_CHRG_PRICE,#LIMC.LOC_NAME " +
                "FROM (#LIMC LEFT JOIN #IMC ON #LIMC.ITEM_NO = #IMC.ITEM_NO) INNER JOIN #CDM_MFR ON #LIMC.MFR_NAME = #CDM_MFR.MFR_NAME " +
                "INNER JOIN #CDM_VEND ON #LIMC.VEND_NAME = #CDM_VEND.NAME; " +
                "drop table #LIMC " +
                "drop table #IMC " +
                "drop table #CDM_MFR " +
                "drop table #CDM_VEND";

            return cdm;
        }

        private void LoadColHeaders()
        {
            for (int i = 1; i <= MAX_COLS; i++)
            {
                switch (i)
                {
                    case 1:
                    colHeaders.Add(i,"Charge Code");
                    break;
                    case 2:
                    colHeaders.Add(i,"Item Number");
                    break;
                    case 3:
                    colHeaders.Add(i,"Item Description");
                    break;
                    case 4:
                    colHeaders.Add(i,"Vendor Name");
                    break;
                    case 5:
                    colHeaders.Add(i,"Vendor Catalog Number");
                    break;
                    case 6:
                    colHeaders.Add(i,"Manufacturer Name");
                    break;
                    case 7:
                    colHeaders.Add(i,"Manufacturer Catalog Number");
                    break;
                    case 8:
                    colHeaders.Add(i,"Issue Unit");
                    break;
                    case 9:
                    colHeaders.Add(i,"Issue Unit Cost");
                    break;
                    case 10:
                    colHeaders.Add(i,"Price");
                    break;
                    case 11:
                    colHeaders.Add(i,"Location");
                    break;
                }
            }
        }
    }
}
