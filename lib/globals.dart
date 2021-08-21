//library globals;

String log = "";
bool reset = false;
bool stopCodeNow = false;
String publicCodeTime;
bool ignoreCurrentLog = false;

int weightIndex;
DateTime codeStart;
String doctor;
String chest;
String survey = "";
String patientName;
String mrn;
String clientName;
String sex;
String dob;
String breed;
double weightKG;
List<String> info = [
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
];
//Event data, Doctor, Patient name, mrn, client name, sex, DOB, weight, chest, breed