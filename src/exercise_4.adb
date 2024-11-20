--Protected types: Ada lab part 4

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure exercise_4 is
    Message: constant String := "Protected Object";
	type Int is range -1 .. 10000;
	subtype Producer_Range_Type is Int range 0 .. 20;
	subtype Buffer_Range_Type is Int range 0 .. 11;
	type Int_Array is array (Buffer_Range_Type) of Int;
    --  type BufferArray is array (0 .. 9) of Integer;
	
	protected Buffer is
        entry Push (Val : Producer_Range_Type);
		entry Pop (Val : out Producer_Range_Type);
		--  procedure Stop;
	private
        Arr : Int_Array := (others => -1);
		Count : Buffer_Range_Type := Buffer_Range_Type'First;
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
			   delay Duration(Random_Int.Random(G) / 10);
            else
                exit;
         end if;
		end loop Main_Cycle;
		Producer.Stop;
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
				delay Duration(Random_Int.Random(G) / 10);
				Value := Random_Int.Random(G);
				Buffer.Push(Value);
				Put ("Pushing: " & Int'Image (Value));
				New_Line;
            or
                accept Stop;
				exit;
            end select;
		end loop;
		Put_Line("producer stopped");
	end Producer;

	protected body Buffer is 
        entry Push (Val : Producer_Range_Type)
        when Count < Buffer_Range_Type'Last is
      	begin
         	Arr(Count) := Val;
			Count := Count + 1;
      	end Push;

		entry Pop (Val : out Producer_Range_Type)
        when Count > Buffer_Range_Type'First is
      	begin
         	Val := Arr(Buffer_Range_Type'First);
			for I in Buffer_Range_Type loop
				if I /= Buffer_Range_Type'Last then
					Arr(I) := Arr(I + 1);
				end if;
			end loop;
			Count := Count - 1;
      	end Pop;
	end Buffer;

begin
	Put_Line(Message);
end exercise_4;
