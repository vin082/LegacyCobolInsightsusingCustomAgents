       05 PAY-TRANS-ID      PIC 9(12).
       05 PAY-CUST-ID       PIC 9(8).
       05 PAY-ACCT-ID       PIC 9(10).
       05 PAY-AMOUNT        PIC S9(9)V99 COMP-3.
       05 PAY-TYPE          PIC X(10).
          88 PAY-REGULAR    VALUE 'REGULAR   '.
          88 PAY-REFUND     VALUE 'REFUND    '.
          88 PAY-REVERSAL   VALUE 'REVERSAL  '.
       05 PAY-STATUS        PIC X(10).
          88 PAY-APPROVED   VALUE 'APPROVED  '.
          88 PAY-PENDING    VALUE 'PENDING   '.
          88 PAY-REVERSED   VALUE 'REVERSED  '.
          88 PAY-REJECTED   VALUE 'REJECTED  '.
       05 PAY-TIMESTAMP     PIC X(26).
