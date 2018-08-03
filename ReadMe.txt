// Email Password
/*
The password for the SendMail portion of this app is stored in the file [backup_path]\CDMKey.txt (find backup_path in the config file).
The referenced library KeyMaster is used to decrypt the password at run time. There is another app called EncryptAndHash 
(found in \\Lapis\h_purchasing$\Purchasing\PMM IS data\HEMM Apps\Executables\ ) that you can use to change the password when that becomes necessary. The key is pmmhelp.
*/


/*
The application I wrote for this invokes CDM_REPORT.sql
CDM_REPORT uses CDM_LocItemMastCat.sql and CDM_ItemMastCat.sql to create the data set.
These last two sql files were derived from the McKesson stored proc up_rpt_SupplyLocItemMastCat.
*/


//license for SpreadSheetLight
/*
 * Copyright (c) 2011 Vincent Tan Wai Lip

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */