public with sharing class TFSC_TestUtils {
    
    
    
    
    public static User generateTestUser(String profileName, Boolean insertUser) {
        
        String randomString = generateRandomString(6);
        
        //'Collections'
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName]; 
        User usr = new User(Alias = 'stst123', 
                            Coll_Racf_Id__c = 'XXX123',
                            Lan_Id__c = 'LANID', 
                            Email='usr' + randomString + '@toyotaDevish.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='usr' + randomString + '@toyotaDevish.com');
        
        if(insertUser) {
            insert usr;
        }
        
        return usr;
    }
    
    
    public static String generateRandomString(Integer charLength) {
        String randomString = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,charLength);
        return randomString;
    }
    
    
    
    public static Account setupAndReturnNewAccount() {
        String randString = generateRandomString(5);
        Account acct = new Account(name = 'testAcct' + randString);
        insert acct;
        
        return acct;
    }
    
    
    public static Financial_Account__c setupAndReturnNewFinancialAccount(Account acct, String randString) {
        Collateral__c ast = new Collateral__c( name = 'testAsset' + randString );
        insert ast;
        
        Financial_Account__c financialAccount = new Financial_Account__c();
        financialAccount.Financial_Account_Number__c = randString;
        financialAccount.Collateral__c = ast.Id;
        insert financialAccount;
        
        return financialAccount;
    }
    public static Financial_Account__c setupAndReturnNewFinancialAccount(Account acct) {
        String randString = generateRandomString(8);
        return setupAndReturnNewFinancialAccount(acct, randString);
    }
    
    
    /**
    *   @borrowerPosition = 'Co-X' or 'Primary'
    */
    public static Financial_Account_Customer__c setupAndReturnFAC(Financial_Account__c fa, Account acct, String borrowerPosition) {
        Financial_Account_Customer__c fac = new Financial_Account_Customer__c();
        fac.Borrower_Position__c = borrowerPosition;
        fac.Borrower_Status__c = 'Active';
        fac.Financial_Account__c = fa.Id;
        fac.Account__c = acct.Id;
        fac.Home_Phone_Garage__c = '4063775023';
        fac.Mobile_Phone__c = '4063775024';
        fac.Work_Phone_Garage__c = '4063775025';
        fac.Borrower_Status__c = 'Active';
        fac.Customer_Role_Type__c = 'test';
        fac.FA_Role_Status__c = 'test';
        fac.Financial_Account_Customer__c = 'test2' + TFSC_TestUtils.generateRandomString(4);
        insert fac;
        
        return fac;
    }
    
    public static FAQ_A__kav setupAndReturnArticle() {
        
        FAQ_A__kav artcl = new FAQ_A__kav(Title = 'Test Article',
                                          Summary = 'Test article type created by Apex',
                                          Answer__c = 'test',
                                          URLName = 'test'
                                         );
        
        insert artcl;
        //retrieve master article Id created on FAQ_A__kav record insertion
        //in order to get the KnowledgeArticleId
        artcl = [SELECT KnowledgeArticleId FROM FAQ_A__kav WHERE Id = :artcl.Id];
        
        //publish it
        KbManagement.PublishingService.publishArticle(artcl.KnowledgeArticleId, true);

        return artcl;
    }
    
    
}