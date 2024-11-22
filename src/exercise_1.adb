with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;


procedure cyclic is
    Start_Time: Time := Clock;  --Capture the start time of the procedure
    s: Integer := 0;            -- Counter to track loop iterations
    D: Duration := 0.5;         -- Base duration between tasks in a cycle
    F3d: Duration := 2.0;       --Duration between consecutive executions of f3
    Next_F3_Time: Time := Start_Time + D; -- First execution time for f3
  

    procedure f1 is
        Message: constant String := "F1 executing, time is now:";
    begin
        Put(Message);
        Put_Line(Duration'Image(Clock - Start_Time));
    end f1;

    procedure f2 is
        Message: constant String := "F2 executing, time is now:";
    begin
        Put(Message);
        Put_Line(Duration'Image(Clock - Start_Time));
    end f2;

    procedure f3 is
        Message: constant String := "F3 executing, time is now:";
    begin
        Put(Message);
        Put_Line(Duration'Image(Clock - Start_Time));
    end f3;

begin
    loop
        f1;
        f2;
        --Execute f3 every second iteration (based on counter s)
        if s mod 2 = 0 then
            delay until Next_F3_Time; -- Wait until the next scheduled time for f3
            f3;
            Next_F3_Time := Next_F3_Time + F3d; -- Update the next scheduled time for f3
        end if;
        s := s + 1;
        -- Delay for the next cycle to maintain the time interval between cycles
        delay until Start_Time + Duration(s) ;
    end loop;
end cyclic;
