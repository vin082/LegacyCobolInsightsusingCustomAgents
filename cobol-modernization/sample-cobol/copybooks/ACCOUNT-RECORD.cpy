       05 ACCT-ID           PIC 9(10).
       05 ACCT-CUST-ID      PIC 9(8).
       05 ACCT-TYPE         PIC X(3).
          88 ACCT-CURRENT   VALUE 'CUR'.
          88 ACCT-SAVINGS   VALUE 'SAV'.
          88 ACCT-LOAN      VALUE 'LON'.
       05 ACCT-STATUS       PIC X VALUE 'A'.
          88 ACCT-ACTIVE    VALUE 'A'.
          88 ACCT-INACTIVE  VALUE 'I'.
          88 ACCT-CLOSED    VALUE 'C'.
       05 ACCT-BALANCE      PIC S9(11)V99 COMP-3.
       05 ACCT-LIMIT        PIC S9(9)V99 COMP-3.
       05 ACCT-OPEN-DATE    PIC 9(8).
