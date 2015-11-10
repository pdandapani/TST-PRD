public class PermissionSetModel {
	
	public static boolean hasStandaloneKnowledgePermissionSet() {
		return hasStandaloneKnowledgePermissionSet(UserInfo.getUserId());
	}
	
	public static boolean hasStandaloneKnowledgePermissionSet(Id UserId) {
		List<PermissionSetAssignment> permissionSetAssignmentList = [
			SELECT PermissionSetId 
			FROM PermissionSetAssignment 
			WHERE AssigneeId= :UserId 
			AND PermissionSet.Name = 'Standalone_Knowledge'
		];
		
		if (permissionSetAssignmentList.size() > 0) {
			return true;
		} else {
			return false;
		}
	}

	public static boolean hasKnowledgeAdminPermissionSet() {
		return hasKnowledgeAdminPermissionSet(UserInfo.getUserId());
	}
	
	public static boolean hasKnowledgeAdminPermissionSet(Id UserId) {
		List<PermissionSetAssignment> permissionSetAssignmentList = [
			SELECT PermissionSetId 
			FROM PermissionSetAssignment 
			WHERE AssigneeId= :UserId 
			AND PermissionSet.Name = 'Knowledge_Admin'
		];
		
		if (permissionSetAssignmentList.size() > 0) {
			return true;
		} else {
			return false;
		}
	}


	public static PermissionSet findPermissionSet(String permissionSetName) {
		List<PermissionSet> sets = [
			select id,name,label,description,userLicenseId
			from PermissionSet
			where name = :permissionSetName
		];
		
		if ( sets.size() <> 1) {
			return null;
		} else {
			return sets[0];
		}
	}
	
	public static void addPermissionSetToUser(PermissionSet param, Id userId) {
		if ( param == null || userId == null) {
			return;
		}
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = userId;
		psa.PermissionSetId = param.id;
		
		insert psa;
	}

}