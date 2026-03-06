       05 CUST-ID           PIC 9(8).
       05 CUST-NAME         PIC X(40).
       05 CUST-STATUS       PIC X VALUE 'A'.
          88 CUST-ACTIVE    VALUE 'A'.
          88 CUST-INACTIVE  VALUE 'I'.
          88 CUST-CLOSED    VALUE 'C'.
       05 CUST-BALANCE      PIC S9(9)V99.
       05 CUST-OPEN-DATE    PIC 9(8).
