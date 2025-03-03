@isTest
private class PostInstallTest {
  private class MockPermissionSetLocator implements PostInstall.PermissionSetLocator {
    private PermissionSet mockPermSet;
    
    public MockPermissionSetLocator(PermissionSet mockPermSet) {
      this.mockPermSet = mockPermSet;
    }
    
    public PermissionSet getDataCloudPermissionSet() {
      return mockPermSet;
    }
  }
  
  @IsTest
  private static void testPostInstallWithPermissionSet() {
    // Create a test permission set
    PermissionSet testPermSet = new PermissionSet(
      Name = 'Test_Perm_Set',
      Label = 'Test Permission Set'
    );
    insert testPermSet;
    
    // Create the PostInstall with our mock locator
    PostInstall postInstall = new PostInstall(
      new MockPermissionSetLocator(testPermSet)
    );
    
    // Run the test
    Test.startTest();
    postInstall.onInstall(null);
    Test.stopTest();
    
    // Verify permissions were added to our test permission set
    List<ObjectPermissions> objPerms = [
      SELECT Id
      FROM ObjectPermissions
      WHERE ParentId = :testPermSet.Id AND SObjectType = 'mvpbo2__Appliance__c'
    ];
    System.assertEquals(1, objPerms.size());
  }
  
  @IsTest
  private static void testPostInstallWithoutPermissionSet() {
    // Create the PostInstall with a mock locator that returns null
    PostInstall postInstall = new PostInstall(
      new MockPermissionSetLocator(null)
    );
    
    // Run the test
    Test.startTest();
    postInstall.onInstall(null);
    Test.stopTest();
    
    // Verify no errors were thrown and execution continued
    // This will be a bit harder to verify, but you could add a status log to the PostInstall class
  }

  @IsTest
  private static void testPostInstall() {
    try {
        // Create a test permission set
        PermissionSet testPermSet = new PermissionSet(
            Name = 'Test_Data_Extract',
            Label = 'Test Data Extract Permission Set'
        );
        insert testPermSet;
        
        // Create a PostInstall instance with our mock locator
        PostInstall postInstall = new PostInstall(
            new MockPermissionSetLocator(testPermSet)
        );
        
        // Run the test
        Test.startTest();
        postInstall.onInstall(null);
        Test.stopTest();
        
        // Verify that the ObjectPermissions object was created
        List<ObjectPermissions> objPerms = [
            SELECT Id
            FROM ObjectPermissions
            WHERE ParentId = :testPermSet.Id AND SObjectType = 'mvpbo2__Appliance__c'
        ];
        System.assertEquals(1, objPerms.size());
        
        // Verify that the FieldPermissions object was created
        List<FieldPermissions> fieldPerms = [
            SELECT Id, SObjectType, Field
            FROM FieldPermissions
            WHERE ParentId = :testPermSet.Id AND (SObjectType = 'mvpbo2__Appliance__c' OR SObjectType = 'mvpbo2__Unit__c' OR SObjectType = 'Case')
        ];
        
        // Assert on the expected number of field permissions
        // This number should match what your PostInstall class is expected to create
        System.assertNotEquals(0, fieldPerms.size(), 'Should create field permissions');
        
        // Get count where SObjectType = mvpbo2__Appliance__c
        Integer applianceFieldPermsCount = 0;
        for (FieldPermissions fp : fieldPerms) {
            if (fp.SObjectType == 'mvpbo2__Appliance__c') {
                applianceFieldPermsCount++;
            }
        }
        
        // This should match the number of fields you expect to have permissions added for
        System.assertNotEquals(0, applianceFieldPermsCount, 'Should create appliance field permissions');
    } catch (Exception e) {
        System.assert(false, 'Test failed with exception: ' + e.getMessage());
    }
  }
}
