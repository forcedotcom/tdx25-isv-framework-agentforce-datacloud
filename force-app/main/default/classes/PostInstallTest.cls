@isTest
private class PostInstallTest {
  @IsTest
  private static void testPostInstall() {

    test.startTest();
    PermissionSet permSet = [
      SELECT Id, Label
      FROM PermissionSet
      WHERE Name = 'sfdc_a360_sfcrm_data_extract'
      LIMIT 1
    ];
    // Create a test version of the PostInstall class
    PostInstall postInstall = new PostInstall();
    postInstall.onInstall(null);
    test.stopTest();

    // Verify that the ObjectPermissions object was created
    List<ObjectPermissions> objPerms = [
      SELECT Id
      FROM ObjectPermissions
      WHERE ParentId = :permSet.Id AND SObjectType = 'mvpbo2__Appliance__c'
    ];
    System.assertEquals(1, objPerms.size());

    // Verify that the FieldPermissions object was created
    List<FieldPermissions> fieldPerms = [
      SELECT Id, SObjectType, Field
      FROM FieldPermissions
      WHERE ParentId = :permSet.Id AND (SObjectType = 'mvpbo2__Appliance__c' OR SObjectType = 'mvpbo2__Unit__c' OR SObjectType = 'Case')
    ];

    System.assertEquals(14, fieldPerms.size());
    // get count where sobjecttype = mvpbo2__appliance__c
    Integer applianceFieldPermsCount = 0;
    for (FieldPermissions fp : fieldPerms) {
        if (fp.SObjectType == 'mvpbo2__Appliance__c') {
            applianceFieldPermsCount++;
        }
    }
    System.assertEquals(7, applianceFieldPermsCount);
  }
}
