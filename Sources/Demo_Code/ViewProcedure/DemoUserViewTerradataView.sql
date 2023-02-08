 CREATE VIEW ViewDemoUsers
      (FirstName, LastName, PhoneNumber, Email, RegistrationDate) AS
       SELECT FirstName, LastName, PhoneNumber, Email, RegistrationDate
       FROM ViewDemoUsers
       WHERE RegistrationDate <= CURRENT_DATE
       WITH CHECK OPTION;
