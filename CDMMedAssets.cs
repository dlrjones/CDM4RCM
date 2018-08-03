using System;
using System.Data;
using System.IO;
using OleDBDataManager;

namespace CDMReportClass
{
    class CDMMedAssets : CDMMaster
    {
        public void InitReport()
        {
            Init();
            LoadDataSet();
        }
        private void LoadDataSet()
        {
            int rowCount = 0;
            int indx = 0;
            int rowTotal = 0;
            
            string catalog = "";//added 11/12/13 to remove errant \r\t in the catalog number            


            ODMRequest Request = new ODMRequest();
            Request.ConnectString = dbConnectString;
            Request.CommandType = CommandType.StoredProcedure;
            Request.Command = "dbo.CDM_REPORT";
            string itemNmbr = "";
            try
            {
                currentFileName += GetDate();
                currentFileName += ".txt";
                dsAlloc = ODMDataSetFactory.ExecuteDataSetBuild(ref Request);

                if (dsAlloc.Tables[0].Rows.Count > 0)
                {
                    rowTotal = dsAlloc.Tables[0].Rows.Count;
                    export =
                        "Charge Code \t Department Number\tItem Number\tItem Description\tHCPCS\tUB/RevenueCode\t" +
                        "Subsystem Number\tFacility Name\tVendor Name\tVendor Code\tVendor Catalog Number\tManufacturer Code\t";
                    export += "Manufacturer Catalog Number\tPurchasing Unit of Measure\tPackaging String\t\t\t\t\tIssue Unit\tIssue Unit Cost\tPrice";
                    export += Environment.NewLine;

                    /*
                     * SELECT #LIMC.PAT_CHRG_NO,  #LIMC.PAT_CHRG_NO,  #LIMC.ITEM_NO,  #LIMC.ITEM_DESC,  #LIMC.PAT_CHRG_NO, xxUB/Revxx,  
                     *        xxSubSysNmbrxx, xxFacNamexx, #LIMC.VEND_NAME, #CDM_VEND.VEND_CODE, #LIMC.VEND_CTLG_NO, #IMC.MFR_NO, #IMC.MFR_NAME
                     *        #IMC.MFR_CTLG_NO, #IMC.ORDER_UM_CD, #IMC.UM_CD3, #IMC.TO_QTY2, #IMC.UM_CD2, #IMC.TO_QTY1, 
                     *        #IMC.UM_CD1, #LIMC.UM_CD, #LIMC.PRICE, #LIMC.PAT_CHRG_PRICE

                     * 
                     * Charge Code	Department Number	Item Number	  Item Description	HCPCS	UB/RevenueCode	
                     * Subsystem Number	  Facility Name 	VEND_NAME	VEND_CODE	VEND_CTLG_NO	MFR_NO	
                     * MFR_CTLG_NO	Vendor Catalog Number	Manufacturer Code	Manufacturer Catalog Number

                     * */
                    File.WriteAllText(backupPath + currentFileName, export);
                    File.AppendAllText(backupPath + @"\" + logFile, DateTime.Now.ToString() + TAB + "Begin " + rowTotal + " records" + Environment.NewLine);
                    export = "";
                    while (rowCount < rowTotal)
                    {
                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB; //Charge Code
                        export += GetDeptNo((dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim()) + TAB; //Dept #

                        itemNmbr = (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;   //Item #  
                        export += itemNmbr;
                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB; // Item Desc
                        export += TrimHCPCS((dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString())).Trim() + TAB; //HCPCS
                        export += TAB;  //UB/Rev
                        export += TAB;  //SubSysNmbr
                        export += "HMC" + TAB; //Facility Name  --  8/27/13:  changed from|   export += "HMC,"   |(no TAB) --rj

                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;//VendName                        
                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;//VendCode  

                        catalog = (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim();
                        if (catalog.Contains(CRLF)) //added 11/12/13 to remove errant \r\t in the catalog number 
                            catalog = RemoveCRLF(catalog);
                        export += catalog + TAB; //VendCat# -- needed " ' " for excel

                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;//Mfr Code                        
                        ////////////if (locName) //added 12/6/13 to provide Location Name to June Tate
                        ////////////    export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;//Mfr Name
                        ////////////else
                        indx++;//Mfr Name

                        catalog = (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim();
                        if (catalog.Contains(CRLF)) //added 11/12/13 to remove errant \r\t in the catalog number        
                            catalog = RemoveCRLF(catalog);
                        export += catalog + TAB;  //Mfr Cat # -- needed " ' " for excel

                        export += TrimUOM((dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim()) + TAB;//order UM
                        export += TrimUOM((dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim()) + TAB;//UM cd3  ----|
                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;//qty2 ----|  
                        export += TrimUOM((dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim()) + TAB;//UM cd2  ----|------> Packaging String
                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;//qty1 ----|  
                        export += TrimUOM((dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim()) + TAB;//UM cd1  ----|
                        export += TrimUOM((dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim()) + TAB;//UM cd
                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim() + TAB;//price //
                        export += (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim();//pat chrg $ //
                        ////////////if (locName)    //added 11/7/13 to provide Location Name to June Tate
                        ////////////    export += TAB + (dsAlloc.Tables[0].Rows[rowCount].ItemArray[indx++].ToString()).Trim();//Location
                        export += Environment.NewLine;
                        indx = 0;
                        rowCount++;
                        if (rowCount % 1000 == 0)
                        {
                            File.AppendAllText(backupPath + currentFileName, export);
                            export = "";

                        }
                    }                    
                    File.AppendAllText(backupPath + currentFileName, export);
                }
                else
                {
                    EmptyDataSet();
                }
                CopyExportFile(currentFileName);
                //Create the '.DONE' file
                AppendText(rowCount,true); 
                CopyExportFile(currentFileName + ".DONE");                
                done = true;
            }
            catch (Exception dbx)
            {
                File.AppendAllText(backupPath + @"\" + logFile, "ERROR: LoadDataSet() " + DateTime.Now + "INDEX: " + indx + "Count: " + rowCount + "   " + dbx.Message + Environment.NewLine);
            }
        }
    
        //added this on 1/5/16 when Doug Forbes gave permission to write a file to a directory he controls. 
        //We don't have to manually email them anymore. The changes here are to create a backup of the files
        //we create for him and then call this method to copy the file over to his directory.
        private void CopyExportFile(string fName)
        {
            File.Copy(backupPath + fName, xportPath + fName); 
        }

    }
}
