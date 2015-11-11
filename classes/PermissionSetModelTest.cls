@IsTest
public class PermissionSetModelTest {
	
	public static User standaloneKmUser = null;
	public static User KmAdminUser = null;
	public static PermissionSet permSet = null;

	@IsTest
	public static void TestFindPermissionSet() {
		createData();
		
		PermissionSet permSet1 = PermissionSetModel.findPermissionSet('TestPermissionSet');
		System.AssertNotEquals(null, permSet1);
		
		PermissionSet permSet2 = PermissionSetModel.findPermissionSet('DoesNotExists');
		System.AssertEquals(null, permSet2);
	}

	@IsTest
	public static void UnitTest() {
		createData();
		
		Test.startTest();
		
		PermissionSetModel.hasStandaloneKnowledgePermissionSet();
		PermissionSetModel.hasKnowledgeAdminPermissionSet();
		
		Test.stopTest();
	}

	
	public static void createData() {
		
		if ( permSet == null) {
			permSet = new PermissionSet();
			permSet.name = 'TestPermissionSet';
			permSet.label = 'Unit Test Perm Set';
			insert permSet;
		}
		
		
		
		
	}
}