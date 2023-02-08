CREATE PROCEDURE InsertDemoUser ( 
   IN in_FirstName VARCHAR(100), 
   IN in_LastName VARCHAR(79), 
   IN in_PhoneNumber INTEGER, 
   IN in_Email VARCHAR(100),
   IN in_RegistrationDate DATE
) 
BEGIN 
   INSERT INTO DemoUsers ( 
     FirstName, 
	  LastName, 
	  PhoneNumber, 
	  Email, 
	  RegistrationDate
   ) 
   VALUES ( 
	 :in_FirstName, 
	 :in_LastName, 
    :in_PhoneNumber, 
    :in_Email,
    :in_RegistrationDate
   ); 
END;