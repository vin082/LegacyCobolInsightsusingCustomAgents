# COBOL Procedure Division Verbs — Complete Reference

## Data Manipulation Verbs

### MOVE
Assigns values between data items:
```cobol
MOVE source TO dest1 dest2 ...
MOVE CORRESPONDING source-group TO dest-group   ← matches fields by name
MOVE SPACES TO WS-WORK-AREA                     ← figurative constants
MOVE ZEROES TO WS-COUNTERS
MOVE HIGH-VALUES TO WS-SEARCH-KEY
MOVE LOW-VALUES TO WS-EOF-KEY
```

### ADD / SUBTRACT / MULTIPLY / DIVIDE
```cobol
ADD 1 TO WS-COUNTER
ADD WS-AMT1 WS-AMT2 TO WS-TOTAL
ADD WS-AMT1 TO WS-AMT2 GIVING WS-RESULT
SUBTRACT 1 FROM WS-COUNTER
MULTIPLY RATE BY AMOUNT GIVING RESULT ROUNDED
DIVIDE DIVISOR INTO DIVIDEND GIVING QUOTIENT REMAINDER REMAIN
```

### COMPUTE
Full arithmetic expressions:
```cobol
COMPUTE WS-RESULT = (WS-A + WS-B) * WS-C / WS-D
COMPUTE WS-INTEREST ROUNDED = WS-PRINCIPAL * WS-RATE / 100
```

### STRING / UNSTRING
```cobol
STRING WS-FIRST DELIMITED BY SPACE
       ' '
       WS-LAST DELIMITED BY SIZE
       INTO WS-FULL-NAME

UNSTRING WS-INPUT DELIMITED BY ',' OR '|'
         INTO WS-FIELD1 WS-FIELD2 WS-FIELD3
         TALLYING IN WS-COUNT
```

### INSPECT
```cobol
INSPECT WS-STRING TALLYING WS-COUNT FOR ALL 'X'
INSPECT WS-STRING REPLACING ALL SPACES BY ZEROES
INSPECT WS-STRING CONVERTING 'abc' TO 'ABC'
```

## Control Flow Verbs

### PERFORM
```cobol
PERFORM para-name                              ← Simple call
PERFORM para-name THRU end-para               ← Range
PERFORM para-name N TIMES                     ← Fixed repeat
PERFORM para-name UNTIL condition             ← While loop
PERFORM para-name WITH TEST AFTER UNTIL cond  ← Do-while loop
PERFORM para-name
    VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 10    ← For loop
PERFORM UNTIL WS-EOF                          ← Inline perform
    READ CUSTOMER-FILE AT END MOVE 'Y' TO WS-EOF
    NOT AT END PERFORM PROCESS-CUSTOMER
    END-READ
END-PERFORM
```

### IF / ELSE / END-IF
```cobol
IF condition
    statements
ELSE IF other-condition
    statements
ELSE
    statements
END-IF

IF WS-AMOUNT > 1000
   AND WS-STATUS = 'A'
    PERFORM HIGH-VALUE-PROCESS
END-IF
```

### EVALUATE (Switch/Case)
```cobol
EVALUATE WS-STATUS
    WHEN 'A' PERFORM ACTIVE-PROCESS
    WHEN 'I' PERFORM INACTIVE-PROCESS
    WHEN 'C' PERFORM CLOSED-PROCESS
    WHEN OTHER PERFORM ERROR-PROCESS
END-EVALUATE

EVALUATE TRUE
    WHEN WS-AMT < 0     PERFORM NEGATIVE-HANDLER
    WHEN WS-AMT = 0     PERFORM ZERO-HANDLER
    WHEN WS-AMT > 10000 PERFORM LARGE-AMOUNT
    WHEN OTHER          PERFORM STANDARD-PROCESS
END-EVALUATE

EVALUATE WS-TYPE ALSO WS-STATUS
    WHEN 'D' ALSO 'A'  PERFORM DEBIT-ACTIVE
    WHEN 'C' ALSO 'A'  PERFORM CREDIT-ACTIVE
    WHEN ANY  ALSO 'I'  PERFORM INACTIVE-HANDLER
END-EVALUATE
```

### GOTO (Legacy — avoid)
```cobol
GO TO para-name                          ← Unconditional jump
GO TO para1 para2 para3 DEPENDING ON idx ← Computed GOTO (switch via GOTO)
```

### ALTER (Critical Risk — self-modifying)
```cobol
ALTER para-name TO PROCEED TO other-para
```
Changes the target of a GOTO at runtime. Makes control flow impossible to
statically analyze. No Java equivalent — requires full manual rewrite.

### STOP / EXIT / GOBACK
```cobol
STOP RUN          ← Terminate program and return to OS
EXIT PROGRAM      ← Return to calling program (same as GOBACK in subprograms)
GOBACK            ← Return control to caller (preferred in modern COBOL)
EXIT              ← No-op — marks end of a paragraph (used with GOTO para EXIT)
```

## File I/O Verbs

### OPEN / CLOSE
```cobol
OPEN INPUT file1                    ← Read-only
OPEN OUTPUT file1                   ← Write (overwrite/create)
OPEN I-O file1                      ← Read and write
OPEN EXTEND file1                   ← Append
CLOSE file1 file2
```

### READ
```cobol
READ CUSTOMER-FILE
    AT END MOVE 'Y' TO WS-EOF
    NOT AT END PERFORM PROCESS-RECORD
END-READ

READ CUSTOMER-FILE INTO WS-WORK-RECORD  ← Read into working-storage copy

READ INDEXED-FILE                       ← Keyed read
    KEY IS CUST-KEY
    INVALID KEY PERFORM KEY-ERROR
    NOT INVALID KEY PERFORM FOUND-ROUTINE
END-READ
```

### WRITE / REWRITE / DELETE
```cobol
WRITE CUSTOMER-RECORD                   ← Write to output file
WRITE CUSTOMER-RECORD AFTER ADVANCING 2 LINES  ← Report writer
REWRITE CUSTOMER-RECORD                 ← Update record in I-O file
DELETE CUSTOMER-FILE RECORD             ← Delete current record (INDEXED/RELATIVE)
```

### START (INDEXED/RELATIVE files)
```cobol
MOVE '12345678' TO CUST-KEY
START INDEXED-FILE KEY >= CUST-KEY
    INVALID KEY PERFORM NO-RECORDS
END-START
```

## CALL — External Program Invocation
```cobol
CALL 'PROGRAM-NAME' USING param1 param2
CALL 'PROGRAM-NAME' USING BY REFERENCE param1   ← Default — caller's memory
CALL 'PROGRAM-NAME' USING BY CONTENT param1     ← Copy of value
CALL WS-PROG-NAME USING param1                  ← Dynamic CALL (resolve at runtime)
CALL 'PROGRAM-NAME' ON EXCEPTION PERFORM ERROR-HANDLER
```

Return code checked via `RETURN-CODE` special register or passed parameter.

## Screen / Report Verbs (CICS / Report Writer)
```cobol
EXEC CICS SEND MAP('CUSTMAP') MAPSET('CUSTMAPS') ERASE END-EXEC
EXEC CICS RECEIVE MAP('CUSTMAP') MAPSET('CUSTMAPS') END-EXEC
EXEC CICS RETURN TRANSID('CUST') COMMAREA(WS-COMMAREA) END-EXEC
EXEC CICS READ FILE('CUSTMAST') INTO(WS-RECORD) RIDFLD(CUST-KEY) END-EXEC
```

## SORT / MERGE
```cobol
SORT SORT-FILE ON ASCENDING KEY SORT-KEY
    INPUT PROCEDURE IS LOAD-RECORDS
    OUTPUT PROCEDURE IS WRITE-SORTED

MERGE MERGE-FILE ON ASCENDING KEY SORT-KEY
    USING FILE1 FILE2
    OUTPUT PROCEDURE IS WRITE-MERGED
```
