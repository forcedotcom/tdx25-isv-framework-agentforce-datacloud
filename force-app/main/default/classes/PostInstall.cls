global class PostInstall implements InstallHandler {
  @TestVisible
  private PermissionSetLocator permSetLocator;
  
  public PostInstall() {
    this.permSetLocator = new DefaultPermissionSetLocator();
  }
  
  @TestVisible
  public PostInstall(PermissionSetLocator locator) {
    this.permSetLocator = locator;
  }
  
  global void onInstall(InstallContext context) {
    PermissionSet permSet = permSetLocator.getDataCloudPermissionSet();
    
    if (permSet == null) {
      System.debug('No Data Cloud permission set found. Skipping permission updates.');
      return;
    }

    // create list of sObject names in your app
    List<String> sObjectTypeNames = new List<String>{
      'mvpbo2__Appliance__c',
      'mvpbo2__Unit__c',
      'Case'
    };

    List<ObjectPermissions> objectPermList = new List<ObjectPermissions>();
    List<FieldPermissions> fieldPermsList = new List<FieldPermissions>();

    for (String sObjectTypeName : sObjectTypeNames) {
      // Create a new ObjectPermissions object for DC Connector Perm
      ObjectPermissions objPerm = new ObjectPermissions();

      // Set the necessary fields on the ObjectPermissions object
      objPerm.ParentId = permSet.Id; // Set the parent permission set ID
      objPerm.SObjectType = sObjectTypeName; // Set the object type
      objPerm.PermissionsCreate = false;
      objPerm.PermissionsRead = true;
      objPerm.PermissionsEdit = false;
      objPerm.PermissionsDelete = false;
      objPerm.PermissionsViewAllRecords = true;
      objPerm.PermissionsModifyAllRecords = false;
      objectPermList.add(objPerm);

      Schema.SObjectType sObjectType = Schema.getGlobalDescribe()
        .get(sObjectTypeName);
      Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
      Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();

      for (String fieldName : fieldMap.keySet()) {
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName)
          .getDescribe();
          
        // Modified condition to handle both custom objects and Case with mvpbo2__ prefix
        Boolean includeField = false;
        
        if (sObjectTypeName.endsWith('__c')) {
          // For custom objects, include all custom fields
          includeField = fieldName.endsWith('__c') ;
        } else {
          // For standard objects like Case, only include fields with mvpbo2__ prefix
          includeField = fieldName.startsWith('mvpbo2__') ;
        }
        
        if (includeField) {
          FieldPermissions fieldPerm = new FieldPermissions();
          fieldPerm.ParentId = permSet.Id; // Set the parent permission set ID
          fieldPerm.SObjectType = sObjectTypeName; // Set the object type
          fieldPerm.Field = sObjectTypeName + '.' + fieldName; // Set the field API name
          fieldPerm.PermissionsRead = true;
          fieldPerm.PermissionsEdit = false;
          fieldPermsList.add(fieldPerm);
        }
      }
    }
    
    // Insert the ObjectPermissions object
    try {
      Database.UpsertResult[] objPermResults = Database.upsert(
        objectPermList,
        false
      );
      for (Database.UpsertResult result : objPermResults) {
        if (!result.isSuccess()) {
          for (Database.Error error : result.getErrors()) {
            System.debug(
              'Error upserting ObjectPermissions: ' + error.getMessage()
            );
          }
        }
      }
      System.debug('Object permission added successfully.');
    } catch (DmlException e) {
      System.debug('An error occurred: ' + e.getMessage());
    }

    // Upsert the list of field permissions
    try {
      Database.UpsertResult[] fieldPermResults = Database.upsert(
        fieldPermsList,
        false
      );
      for (Database.UpsertResult result : fieldPermResults) {
        if (!result.isSuccess()) {
          for (Database.Error error : result.getErrors()) {
            System.debug(
              'Error upserting FieldPermissions: ' + error.getMessage()
            );
          }
        }
      }
      
      System.debug('Field permissions added successfully. Added ' + fieldPermsList.size());
    } catch (DmlException e) {
      System.debug(
        'An error occurred while adding field permissions: ' + e.getMessage()
      );
    }
  }

  public interface PermissionSetLocator {
    PermissionSet getDataCloudPermissionSet();
  }
  
  private class DefaultPermissionSetLocator implements PermissionSetLocator {
    public PermissionSet getDataCloudPermissionSet() {
      try {
        return [
          SELECT Id
          FROM PermissionSet
          WHERE Name = 'sfdc_a360_sfcrm_data_extract' OR Name = 'sfdc_c360a_sfdctrust_permSet'
          LIMIT 1
        ];
      } catch (QueryException e) {
        return null;
      }
    }
  }
}
