with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;


procedure cyclic is
    Start_Time: Time := Clock;
    s: Integer := 0; -- Counter to track loop iterations
    d: Duration := 0.5; 
    f3d: Duration := 2.0;
    Next_F3_Time: Time := Start_Time + d; -- First execution time for f3
  

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
        delay until Next_F3_Time;
        f3;
        Next_F3_Time := Next_F3_Time + f3d;
     
        -- Increment `s` for each loop cycle
        s := s + 1;
        -- Delay for the next cycle to maintain the time interval between cycles
        delay until Start_Time + Duration(s) * (d + d);
       
    end loop;
end cyclic;
