with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;

procedure cyclic_wd is
    -- Constant and Variable Declarations
    Start_Time : Time := Clock;
    S : Integer := 0;
    D : Duration := 0.5;
    F3d : Duration := 2.0;
    Next_F3_Time : Time := Start_Time + D;
    Task_Deadline : constant Duration := 0.5;
    F3_Done : Boolean := False;

    -- Procedures
    procedure f1 is
        Message : constant String := "f1 executing, time is now";
    begin
        Put(Message);
        Put_Line(Duration'Image(Clock - Start_Time));
    end f1;

    procedure f2 is
        Message : constant String := "f2 executing, time is now";
    begin
        Put(Message);
        Put_Line(Duration'Image(Clock - Start_Time));
    end f2;

    procedure f3 is
        Gen : Generator;
        X : Float;
        Message : constant String := "f3 executing, time is now";
    begin
        Reset(Gen);
        X := 0.5 + Random(Gen);
        delay Duration(X);
        Put(Message);
        Put_Line(Duration'Image(Clock - Start_Time));
        F3_Done := True;
    end f3;

    -- Watchdog Task
    task Watchdog is
        entry Start_Watch;
        entry Stop_Watch;
    end Watchdog;

    task body Watchdog is
        Watch_Start : Time;
    begin
        loop
            select
                accept Start_Watch do
                    Watch_Start := Clock;
                    F3_Done := False;
                end Start_Watch;
                loop
                    exit when F3_Done;
                    if Clock - Watch_Start > Task_Deadline then
                        Put_Line("WARNING!!! F3 MISSED ITS DEADLINE");
                        exit;
                    end if;
                    delay 0.01; -- Short delay to prevent busy-waiting
                end loop;
            or
                accept Stop_Watch do
                    null;
                end Stop_Watch;
            end select;
        end loop;
    end Watchdog;

begin
    loop
        f1;
        f2;
        if S mod 2 = 0 then
            Watchdog.Start_Watch;
            delay until Next_F3_Time;
            f3;
            Watchdog.Stop_Watch;
            if Clock - Next_F3_Time > Task_Deadline then
                -- Re-synchronize to start at whole seconds
                Start_Time := Clock;
                S := 0; -- Reset the counter
                Next_F3_Time := Start_Time + D;
            else
                Next_F3_Time := Next_F3_Time + F3d;
            end if;
        end if;
        S := S + 1;
        delay until Start_Time + Duration(S);
    end loop;
end cyclic_wd;
