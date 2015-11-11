@IsTest
public class RecordTypeModelTest {


	@IsTest
	public static void Test() {
		
		System.assertNotEquals(null, RecordTypeModel.FinancialAccountRetailRecType);
		System.assertNotEquals(null, RecordTypeModel.FinancialAccountRetailRecTypeId);
		System.assertNotEquals(null, RecordTypeModel.FinancialAccountLeaseRecType);
		System.assertNotEquals(null, RecordTypeModel.FinancialAccountLeaseRecTypeId);
		
		System.assertNotEquals(null, RecordTypeModel.PersonAccountCustomerRecType);
		System.assertNotEquals(null, RecordTypeModel.PersonAccountCustomerRecTypeId);
		System.assertNotEquals(null, RecordTypeModel.ContactWebLoginRecType);
		System.assertNotEquals(null, RecordTypeModel.ContactWebLoginRecTypeId);
		System.assertEquals('Weblogin', RecordTypeModel.ContactWebLoginRecType.DeveloperName);
		System.assertEquals('Contact', RecordTypeModel.ContactWebLoginRecType.SobjectType);
		
		
		Id CustomerRecTypeId = RecordTypeModel.ContactWebLoginRecTypeId;
		System.assertNotEquals(null, RecordTypeModel.RecordTypeMapById.get(CustomerRecTypeId));
		System.assertNotEquals(null, RecordTypeModel.findRecordTypeNameById(CustomerRecTypeId));
		System.assertNotEquals(null, RecordTypeModel.findRecordTypeNameById(null));
		System.assertEquals(null, RecordTypeModel.LookupRecordType('Contact','DoesNotExist'));
		System.assertEquals(null, RecordTypeModel.LookupRecordTypeId('Contact','DoesNotExist'));
	}
}