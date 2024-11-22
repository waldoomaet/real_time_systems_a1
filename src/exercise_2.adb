with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;

procedure cyclic_wd is
    -- Constant and Variable Declarations
    Start_Time : Time := Clock;     --Capture the start time of the procedure
    S : Integer := 0;               -- Counter to track loop iterations
    D : Duration := 0.5;            -- Base duration between tasks in a cycle
    F3d : Duration := 2.0;          --Interval between consecutive executions of f3
    Next_F3_Time : Time := Start_Time + D;         -- Initial execution time for f3
    Task_Deadline : constant Duration := 0.5;      -- Deadline for f3's execution
    F3_Done : Boolean := False;                    -- Flag to indicate if f3 has completed

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
        Gen : Generator;      -- Random number generator
        X : Float;            -- Random delay duration for f3
        Message : constant String := "f3 executing, time is now";
    begin
        Reset(Gen);
        X := 0.5 + Random(Gen);     -- Generate a random delay between 0.5 and 1.5 seconds
        delay Duration(X);
        Put(Message);
        Put_Line(Duration'Image(Clock - Start_Time));
        F3_Done := True;
    end f3;

    -- Watchdog Task
    task Watchdog is
        entry Start_Watch;    -- Entry to start the watchdog
        entry Stop_Watch;     -- Entry to stop the watchdog
    end Watchdog;

    task body Watchdog is
        Watch_Start : Time;      -- Record the start time for monitoring f3
    begin
        loop
            select
                accept Start_Watch do
                    Watch_Start := Clock;
                    F3_Done := False;
                end Start_Watch;

                 -- Monitor task f3 for deadline violations
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
        -- Execute f3 every second iteration (based on counter S)
        if S mod 2 = 0 then
            Watchdog.Start_Watch;
            delay until Next_F3_Time;
            f3;
            Watchdog.Stop_Watch;

            -- Check if f3 exceeded its deadline
            if Clock - Next_F3_Time > Task_Deadline then
                -- Re-synchronize to start at whole seconds
                Start_Time := Clock;
                S := 0; -- Reset the counter
                Next_F3_Time := Start_Time + D;
            else
                Next_F3_Time := Next_F3_Time + F3d;  -- Schedule the next execution of f3
            end if;
        end if;
        S := S + 1;     -- Increment the iteration counter
        delay until Start_Time + Duration(S);
    end loop;
end cyclic_wd;
