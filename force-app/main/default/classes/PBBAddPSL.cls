public with sharing class PBBAddPSL {

	@InvocableMethod(label='Add Permission Set License to User')
	public static void AddPSL(list<AddPSLRequest> requests) {

		list<string> output = new list<string>();

		list<PermissionSetLicenseAssign> PSLAs = new list<PermissionSetLicenseAssign>();

		for (AddPSLRequest request:dedupe(requests)){
			//future methods can only accept primitives, so we serialize to a list of string
			// output.add(JSON.serialize(request));
			PermissionSetLicenseAssign PSLA = new PermissionSetLicenseAssign();
			PSLA.AssigneeId = request.UserId;
			PSLA.PermissionSetLicenseId = request.PermissionSetLicenseId;
			PSLAs.add(PSLA);
		}

		insert PSLAs;

	}

	//what Process Builder/Flow Builder can reference for the input variables
	public class AddPSLRequest {
		@InvocableVariable(required=true label='Permission Set License Id')
		public Id PermissionSetLicenseId;

		@InvocableVariable(required=true label='User Id')
		public Id UserId;
	}

	public static list<AddPSLRequest> dedupe(list<AddPSLRequest> input){
		set<AddPSLRequest> temp = new set<AddPSLRequest>(input);
		return new list<AddPSLRequest>(temp);
	}

	//has to be handled as an @future transaction because the mixed DML issue!
	@future
	public static void AddPermsLater (list<string> requests){
		list<PermissionSetLicenseAssign> PSLAs = new list<PermissionSetLicenseAssign>();

		for (string request:requests){
			//turn it back into the request object per Quinton Wall
			//https://developer.salesforce.com/blogs/developer-relations/2013/06/passing-objects-to-future-annotated-methods.html
			AddPSLRequest APSLR = (AddPSLRequest)JSON.deserialize(request, AddPSLRequest.class);

			PermissionSetLicenseAssign PSLA = new PermissionSetLicenseAssign();
			PSLA.AssigneeId = APSLR.UserId;
			PSLA.PermissionSetLicenseId = APSLR.PermissionSetLicenseId;

			PSLAs.add(PSLA);
		}

		insert PSLAs;
	}

}