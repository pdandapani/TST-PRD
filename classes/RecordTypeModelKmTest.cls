/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  RecordTypeModelKmTest - unit test for RecordTypeModelKm
**/
@IsTest
public class RecordTypeModelKmTest {
	@IsTest
	public static void Test() {
		System.assertNotEquals(null, RecordTypeModelKm.BinderPrint1RecType);
		System.assertNotEquals(null, RecordTypeModelKm.BinderPrint1RecTypeId);
		System.assertNotEquals(null, RecordTypeModelKm.BinderPrint2RecType);
		System.assertNotEquals(null, RecordTypeModelKm.BinderPrint2RecTypeId);
	}
}