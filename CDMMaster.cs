using System;
using System.Collections.Specialized;
using System.Configuration;
using System.Data;
using System.IO;
using KeyMaster;
using LogDefault;

//using DLRUtilityCollection;
using OleDBDataManager;

namespace CDMReportClass
{   
    class CDMMaster
    {
        protected  DataSet dsAlloc = new DataSet();
        protected  ODMDataFactory ODMDataSetFactory = null;
        private  NameValueCollection ConfigSettings = null;
        protected LogManager lm = LogManager.GetInstance();
        protected  string dbConnectString = null; //Connection.GetInstance();
        protected  string xportPath = "";
        protected string backupPath = "";
        protected  string currentFileName = "";
        protected  string export = "";
        protected  string logFile = "";
        protected  string CRLF = "\r\n";
        protected string emailList = "";
        protected string firstName = "";
        protected string emailReplyTo = "";
        protected string emailCopyTo = "";
        protected  char TAB = Convert.ToChar(9);
        protected  bool locName = false;
        protected  bool done = false;
        private int reportType = 0;
        protected const int MAX_COLS = 11;


        public int ReportType
        {
            set { locName = value > 0 ? true : false;
                  reportType = value;
            }
        }

        public void Init()
        {
            ODMDataSetFactory = new ODMDataFactory();
            ConfigSettings = (NameValueCollection)ConfigurationSettings.GetConfig("appSettings");

            AppendText("CDMMaster");
            //ConfigData.CreateInstance();
            dbConnectString = ConfigSettings.Get("connect");
            xportPath = ConfigSettings.Get("xport_path");
            backupPath = ConfigSettings.Get("backup_path"); 
            logFile = ConfigSettings.Get("log_file");
            currentFileName = ConfigSettings.Get("out_file_name");
            emailList = ConfigSettings.Get("email_to_list");
            emailCopyTo = ConfigSettings.Get("email_copy_to");
            emailReplyTo = ConfigSettings.Get("email_reply_to");
            firstName = ConfigSettings.Get("email_to_first_name");
        }
      
        protected void EmptyDataSet()
        {
            export = GetDate() + "\t\tNothing to report" + Environment.NewLine;
            lm.Write(export);           
        }

        protected void AppendText(int rowCount,bool createMetaFile)
        {
            lm.Write("Processed " + rowCount + " records");
            if (createMetaFile)
            {                    
               lm.Write(currentFileName + ".DONE");
            }
        }

        protected void AppendText(string mssg )
        {
            lm.Write(mssg);
        }

        protected string RemoveCRLF(string catalogNo)//added 11/12/13 to remove errant \r\t in the catalog number 
        {
            int index = catalogNo.IndexOf(CRLF);
            catalogNo = catalogNo.Remove(index, catalogNo.Length - index);
            return catalogNo;
        }

        protected string GetDeptNo(string code)
        {
            return code.Length > 5 ? code.Substring(0, 5) : code;
        }

        protected string TrimHCPCS(string patChrgCode)
        {
            //sample patChrgCode - 40526_90000030_C1750
            patChrgCode = patChrgCode.Length > 19 ? patChrgCode.Substring(15, 5) : patChrgCode;
            return patChrgCode;
        }

        protected string TrimUOM(string uom)
        {
            uom = uom.Length > 7 ? uom.Substring(6, 2) : uom;
            return uom;
        }

        protected string GetKey()
        {
            string attachmentPath = backupPath;
            string[] key = File.ReadAllLines(attachmentPath + "CDMKey.txt");
            return StringCipher.Decrypt(key[0],"pmmhelp");   
        }

        protected string GetDate()
        {
            DateTime dt = new DateTime();
            dt = DateTime.Now;
            string date = dt.Year.ToString() + CheckTwoDigit(dt.Month.ToString()) + CheckTwoDigit(dt.Day.ToString());
            return date;
        }

        protected string GetMonthName(int offset)
        {
            string monthName = "";
            DateTime dt = new DateTime();
            dt = DateTime.Now.AddMonths(offset);        
             switch (dt.Month)
            {
                case 1:
                    monthName = "January";
                    break;
                case 2:
                    monthName = "February";
                    break;
                case 3:
                    monthName = "March";
                    break;
                case 4:
                    monthName = "April";
                    break;
                case 5:
                    monthName = "May";
                    break;
                case 6:
                    monthName = "June";
                    break;
                case 7:
                    monthName = "July";
                    break;
                case 8:
                    monthName = "August";
                    break;
                case 9:
                    monthName = "September";
                    break;
                case 10:
                    monthName = "October";
                    break;
                case 11:
                    monthName = "November";
                    break;
                case 12:
                    monthName = "December";
                    break;
            }
            return monthName;
        }

        protected string CheckTwoDigit(string month_day)
        {
            string zero = "";
            if (month_day.Length == 1)
                zero = "0";
            return zero + month_day;
        }
    }
}
