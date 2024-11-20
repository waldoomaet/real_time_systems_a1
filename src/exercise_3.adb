--Process commnication: Ada lab part 3

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure Exercise_3_1 is
    Message: constant String := "Process communication";
	type Int is range -1 .. 10000;
	subtype Producer_Range_Type is Int range 0 .. 20;
	subtype Buffer_Range_Type is Int range 0 .. 11;

	task Buffer is
		entry Push (Val : Producer_Range_Type);
		entry Pop (Val : out Producer_Range_Type);
		entry Print;
		entry Stop;
	end Buffer;

	task Producer is
		entry Stop;
	end Producer;

	task Consumer;

	task body Consumer is 
		Message: constant String := "consumer executing";
		package Random_Int is new Ada.Numerics.Discrete_Random(Producer_Range_Type);
		G : Random_Int.Generator;
		Value: Producer_Range_Type;
		Sum: Int := 0;
	begin
		Put_Line(Message);
		Random_Int.Reset(G);
		Main_Cycle:
		loop
            Buffer.Pop(Value);
			Sum := Sum + Value;
			Put ("Poping: " & Int'Image (Value) & ". Sum: " & Int'Image (Sum));
			New_Line;
			Value := 0;
			if Sum < 100 then
			   delay Duration(Random_Int.Random(G) / 2);
            else
                exit;
         end if;
		end loop Main_Cycle;
		Producer.Stop;
		Buffer.Stop;     
		exception
			  when TASKING_ERROR =>
				  Put_Line("Buffer finished before producer");
		Put_Line("Ending the consumer");
	end Consumer;

	task body Producer is 
		Message: constant String := "producer executing";
		package Random_Int is new Ada.Numerics.Discrete_Random(Producer_Range_Type);
		G : Random_Int.Generator;
		Value: Producer_Range_Type;
	begin
		Put_Line(Message);
		Random_Int.Reset(G);
		loop
			select
				delay Duration(Random_Int.Random(G) / 20);
				Value := Random_Int.Random(G);
				Buffer.Push(Value);
				Put ("Pushing: " & Int'Image (Value));
				New_Line;
				Buffer.Print;
            or
                accept Stop;
				exit;
            end select;
		end loop;
		Put_Line("producer stopped");
	end Producer;

	task body Buffer is 
		Message: constant String := "buffer executing";
		type Int_Array is array (Buffer_Range_Type) of Int;

		Arr : Int_Array := (others => -1);
		Count : Buffer_Range_Type := Buffer_Range_Type'First;
	begin
		Put_Line(Message);
		loop
			select
                when Count < Buffer_Range_Type'Last =>
                    accept Push (Val : Producer_Range_Type) do
                        Arr(Count) := Val;
                        Count := Count + 1;
                    end;
			or
                when Count > Buffer_Range_Type'First =>
                    accept Pop (Val : out Producer_Range_Type) do
                        Val := Arr(Buffer_Range_Type'First);
                        for I in Buffer_Range_Type loop
                            if I /= Buffer_Range_Type'Last then
                                Arr(I) := Arr(I + 1);
                            end if;
                        end loop;
                        Count := Count - 1;
                    end;
			or
				accept Print do
					for I in Buffer_Range_Type loop
						Put (Int'Image (Arr (I)) & " ");
					end loop;
					New_Line;
				end Print;
			or
				accept Stop;
				exit;
			end select;
   	end loop;
	Put_Line("buffer stopped");
	end Buffer;
begin

	Put_Line(Message);

end Exercise_3_1;
