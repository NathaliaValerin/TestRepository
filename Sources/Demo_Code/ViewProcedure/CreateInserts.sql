/************** WHILE LOOP, DYNAMIC SQL, SYSTEM TABLE QUERIES, UPDATE RESTRUCTURE, IF/THEN *********************/
-----------
REPLACE PROCEDURE ORG_DEV.CREATE_INSERTS
 (
 IN DB_NAME varchar(500), IN TBL_NAME VARCHAR(500)
-- ,OUT SSQQLL VARCHAR(10000)
 )               
	DYNAMIC RESULT SETS 1
	BEGIN
    
		DECLARE COL_NAME, SUFFIX, PREFIX, MIDDLE, PRE_STMT, COL_TYPE, PREV_COL_TYPE VARCHAR(200);
		DECLARE COL_LIST, SQL_STMT CLOB(200000);
		DECLARE SQL_CMD VARCHAR(32000);
		DECLARE COL_COUNT, NUM_COLS, COL_LEN, BIG_OBJ INTEGER;
 		DECLARE RESULTSET CURSOR WITH RETURN ONLY FOR FIRSTSTATEMENT;
	
		DECLARE CUR2 CURSOR FOR SELECT COUNT(COLUMNNAME) FROM DBC.COLUMNS 
		WHERE DATABASENAME = DB_NAME AND TABLENAME = TBL_NAME GROUP BY DATABASENAME, TABLENAME ORDER BY TABLENAME;
		
		DECLARE CUR3 CURSOR FOR SELECT TRIM(UPPER(COLUMNNAME)) FROM DBC.COLUMNS 
		WHERE DATABASENAME = DB_NAME AND TABLENAME = TBL_NAME ORDER BY DATABASENAME, TABLENAME, COLUMNNAME;
		
		DECLARE CUR4 CURSOR FOR SELECT CASE WHEN COLUMNTYPE IN ('I', 'DA') THEN 20 ELSE COLUMNLENGTH END FROM DBC.COLUMNS 
		WHERE DATABASENAME = DB_NAME AND TABLENAME = TBL_NAME ORDER BY DATABASENAME, TABLENAME, COLUMNNAME;

		DECLARE CUR5 CURSOR FOR SELECT COLUMNTYPE FROM DBC.COLUMNS 
		WHERE DATABASENAME = DB_NAME AND TABLENAME = TBL_NAME ORDER BY DATABASENAME, TABLENAME, COLUMNNAME;

		CALL DBC.SYSEXECSQL('UPDATE MOD_TBL FROM PRODUCT.DIMACCOUNT MOD_TBL SET ACCOUNTTYPE = ''Revenue'' WHERE MOD_TBL.ACCOUNTKEY = 61;');
		CALL DBC.SYSEXECSQL('UPDATE MOD_TBL FROM PRODUCT.DIMACCOUNT MOD_TBL SET ACCOUNTTYPE = ''Expenditures'' WHERE MOD_TBL.ACCOUNTKEY = 61;');

		OPEN CUR2;
		OPEN CUR3;
		OPEN CUR4;
		OPEN CUR5;
		
		FETCH CUR2 INTO NUM_COLS;
		FETCH CUR3 INTO COL_NAME;
		FETCH CUR4 INTO COL_LEN;
		FETCH CUR5 INTO COL_TYPE;
		SET COL_COUNT = 2;
		SET COL_LIST = '';
		SET SQL_STMT = '';
		SET BIG_OBJ = 1;
			
		WHILE (BIG_OBJ <> 0) DO
			IF (COL_TYPE = 'BO') THEN
				SET COL_COUNT = COL_COUNT + 1;			
				FETCH CUR3 INTO COL_NAME;
				FETCH CUR4 INTO COL_LEN;
				SET PREV_COL_TYPE = COL_TYPE;
				FETCH CUR5 INTO COL_TYPE;
			ELSE
				SET BIG_OBJ = 0;
			END IF;
		END WHILE;
		
		IF (COL_NAME IN ('CLASS', 'DATE', 'CLASS')) THEN
			SET COL_NAME = '"' || COL_NAME || '"';
		END IF;
		
		SET PREFIX = 'SELECT ''INSERT INTO ' || DB_NAME || '.' || TBL_NAME || '(' || COL_NAME; 
		

		SET PRE_STMT = 'CAST(OREPLACE(TRIM(COALESCE(CAST("' || COL_NAME || '" AS VARCHAR(' || COL_LEN ||')), ' || '''''' || ')), '''''''', '''''''''''') AS VARCHAR(' || COL_LEN+5 || '))';
		
		WHILE (COL_COUNT <= NUM_COLS) DO
			FETCH CUR3 INTO COL_NAME;
			IF (COL_NAME IN ('CLASS', 'DATE', 'CLASS')) THEN
				SET COL_NAME = '"' || COL_NAME || '"';
			END IF;
			FETCH CUR4 INTO COL_LEN;
			SET PREV_COL_TYPE = COL_TYPE;
			FETCH CUR5 INTO COL_TYPE;
			IF (COL_TYPE <> 'BO') THEN
				SET COL_LIST = COL_LIST || ', ' || COL_NAME;
				IF (PREV_COL_TYPE = 'PD') THEN
					SET SQL_STMT = SQL_STMT || ' || '', ';
				ELSE
					SET SQL_STMT = SQL_STMT || ' || '''''', ';
				END IF;
				IF (COL_TYPE = 'PD') THEN
					SET SQL_STMT = SQL_STMT || 'PERIOD (DATE'''''' || CAST(BEGIN(' || COL_NAME || ') AS VARCHAR(10)) || '''''', DATE '''''' || CAST(END(' || COL_NAME || ')AS VARCHAR(10)) || '''''')''';
				ELSE 
					SET SQL_STMT = SQL_STMT || ''''''' || CAST(OREPLACE(TRIM(COALESCE(CAST("' || COL_NAME || '" AS VARCHAR(' || COL_LEN ||')), ' || '''''' || ')), '''''''', '''''''''''') AS VARCHAR(' || COL_LEN+5 || '))' ;
				END IF;
			END IF;
			SET COL_COUNT = COL_COUNT + 1;	
		END WHILE;	

		SET SUFFIX = ' || '''''');'' "--"  FROM ' || DB_NAME || '.' || TBL_NAME || ';';
		SET MIDDLE = ') VALUES('''''' || ';
		SET SQL_CMD = PREFIX || COL_LIST || MIDDLE || PRE_STMT || SQL_STMT || SUFFIX;

--		SET SSQQLL = SQL_CMD;	
		PREPARE FIRSTSTATEMENT FROM SQL_CMD; 
		OPEN RESULTSET; 
	END;


