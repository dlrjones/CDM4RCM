using System;
using System.Collections.Specialized;
using System.Configuration;
using System.IO;
using CDMReportClass;
using LogDefault;

namespace CDM_Report
{
    class Program
    {
        #region class variables
        private static LogManager lm = LogManager.GetInstance();
        private static CDMMedAssets _cdma; //MedAssets (Doug Forbes - UWMC RCM)
        private static CDMRevCycle _cdmrcm; //Harborview Revenue Cycle Management  
        private static NameValueCollection ConfigSettings = null;
        private static string backupPath = "";
        private static string logFile = "";
        private static string logFilePath = "";
        #endregion
        /*
Trigger for CDMRevCycle:
Monthly <Select All Months>
Day 1 
Start Date <set a start date>
Start Time 12:30 PM
         */
        public static void Main(string[] args)
        {
            try
            {
                ConfigSettings = (NameValueCollection)ConfigurationSettings.GetConfig("appSettings");
                backupPath = ConfigSettings.Get("backup_path");
                lm.LogFile = ConfigSettings.Get("logFile");
                lm.LogFilePath = ConfigSettings.Get("logFilePath");
                if (args.Length > 0)     //0 or null = MedAssets report... 1 = RevCycle report
                {
                    if (args[0] == "1")
                    {
                        _cdmrcm = new CDMRevCycle();
                        _cdmrcm.ReportType = 1;
                        _cdmrcm.InitReport();
                    }                        
                }else
                {
                    //_cdma = new CDMMedAssets();
                    //_cdma.ReportType = 0;
                    //_cdma.InitReport();
                }             
                
            }catch(Exception e)
            {
                lm.Write("ERROR: LoadDataSet() " + e.Message);
            }
        }          
    }
}


