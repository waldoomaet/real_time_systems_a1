--Cyclic scheduler with a watchdog: 

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;



-- add packages to use randam number generator


procedure cyclic_wd is
    Message: constant String := "Cyclic scheduler with watchdog";
        -- change/add your declarations here
        d: Duration := 1.0;
	Start_Time: Time := Clock;
   s          : Integer := 0; -- Counter to track loop iterations
   d          : Duration := 0.5;
   f3d        : Duration := 2.0;
   Next_F3_Time : Time := Start_Time + d; -- First execution time for f3
   Task_Deadline : constant Duration := 0.5;

    -- A flag to indicate when F3 has finished
    F3_Done : Boolean := False;
        

	procedure f1 is 
		Message: constant String := "f1 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f1;

	procedure f2 is 
		Message: constant String := "f2 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f2;

	procedure f3 is 
      Gen : Generator;
      X : Float;
		Message: constant String := "f3 executing, time is now";
	begin
   -- add a random delay here
      Reset (Gen);
      X := 0.5 + Random(Gen);
      delay Duration(X);
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
      F3_Done := True;
		
	end f3;
	
	task Watchdog is
	       -- add your task entries for communication 	
      entry Start_Watch;
      entry Stop_Watch;
	end Watchdog;

	task body Watchdog is
		begin
		loop
      -- add your task code inside this loop 
         select
               accept Start_Watch do
                  Watch_Start := Clock; -- Record the start time of F3
                  F3_Done := False;
               end Start_Watch;
               if not F3_Done then
                  Put_Line("WARNING!!! F3 MISSED ITS DEADLINE");
               end if;
            or
               accept Stop_Watch do
                    null; 
                end Stop_Watch;
         end select;
                    
		end loop;
	end Watchdog;

	begin

        loop
            -- change/add your code inside this loop     
            f1;
            f2;
            delay until Next_F3_Time;
            f3;
            Next_F3_Time := Next_F3_Time + f3d;
            s := s + 1;
            -- Delay for the next cycle to maintain the time interval between cycles
            delay until Start_Time + Duration(s) * (d + d);    
        end loop;
end cyclic_wd;

