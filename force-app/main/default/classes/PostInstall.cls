global class PostInstall implements InstallHandler {
    global void onInstall(InstallContext context) {
        // Add your post install script here
        // This script will be executed
    }
    List<String> sObjectTypeNames = new List<String>{'mvpbo3__Volunteer_Event__c', 'mvpbo3__Volunteer_Event_Participant__c'};

// Query the Data Cloud Salesforce Connector, api name changes between Spring and Summer release
PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'sfdc_a360_sfcrm_data_extract' or Name = 'sfdc_c360a_sfdctrust_permSet' LIMIT 1];
// if no permsets are returned, print message and exit
if (permSet == null) {
    System.debug('No permission sets found.');
    return;
}
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

  Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectTypeName);
  Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
  Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();

  for (String fieldName : fieldMap.keySet()) {
    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
      if (fieldName.endsWith('__c') && fieldDescribe.getType() != Schema.DisplayType.REFERENCE) {
          FieldPermissions fieldPerm = new FieldPermissions();
          fieldPerm.ParentId = permSet.Id; // Set the parent permission set ID
          fieldPerm.SObjectType = sObjectTypeName; // Set the object type
          fieldPerm.Field = sObjectTypeName + '.' + fieldMap.get(fieldName); // Set the field API name
          fieldPerm.PermissionsRead = true; 
          fieldPerm.PermissionsEdit = false;
          fieldPermsList.add(fieldPerm);
      }
  }
}
// Insert the ObjectPermissions object
try {
    System.debug(objectPermList);
    Database.UpsertResult[] objPermResults = Database.upsert(objectPermList, false);
    for (Database.UpsertResult result : objPermResults) {
      if (!result.isSuccess()) {
          for (Database.Error error : result.getErrors()) {
              System.debug('Error upserting ObjectPermissions: ' + error.getMessage());
          }
      }
  }
    System.debug('Object permission added successfully.');
} catch (DmlException e) {
    System.debug('An error occurred: ' + e.getMessage());
}

// Upsert the lis of field permissions
try {
    System.debug(fieldPermsList);
    Database.UpsertResult[] fieldPermResults = Database.upsert(fieldPermsList, false);
    for (Database.UpsertResult result : fieldPermResults) {
        if (!result.isSuccess()) {
            for (Database.Error error : result.getErrors()) {
                System.debug('Error upserting FieldPermissions: ' + error.getMessage());
            }
        }
    }
    System.debug('Field permissions added successfully.');
} catch (DmlException e) {
    System.debug('An error occurred while adding field permissions: ' + e.getMessage());
}
}