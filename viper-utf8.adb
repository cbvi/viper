package body Viper.UTF8 is
   function Shift_Left (Value : Chr; Amount : Natural) return Chr;
   pragma Import (Intrinsic, Shift_Left);

   -- function Shift_Right (Value : Chr; Amount : Natural) return Chr;
   -- pragma Import (Intrinsic, Shift_Right);

   procedure Get (S : in Str; C : out Chr; L : out Natural) is

      subtype R80_BF is Viper.Chr range 16#80# .. 16#BF#;
      subtype RA0_BF is Viper.Chr range 16#A0# .. 16#BF#;
      subtype R80_9F is Viper.Chr range 16#80# .. 16#9F#;
      subtype R90_BF is Viper.Chr range 16#90# .. 16#BF#;
      subtype R80_8F is Viper.Chr range 16#80# .. 16#8F#;

      AA : Chr;
      AB : Chr;
      AC : Chr;
   begin
      if S'Last < 1 then
         goto BAD;
      end if;

      begin
         C := Character'Pos (S (S'First));
         if C < 16#80# then
            L := 1;
            return;
         end if;

         if (C and 16#E0#) = 16#C0# then
            if S'Last < 2 then
               goto BAD;
            end if;

            AA := Character'Pos (S (S'First + 1));

            case C is
               when 16#C2# .. 16#DF# =>
                  if AA not in R80_BF then
                     goto BAD;
                  end if;
               when 16#E0# =>
                  if AA not in RA0_BF then
                     goto BAD;
                  end if;
               when 16#E1# .. 16#EC# =>
                  if AA not in R80_BF then
                     goto BAD;
                  end if;
               when 16#ED# =>
                  if AA not in R80_9F then
                     goto BAD;
                  end if;
               when 16#EE# .. 16#EF# =>
                  if AA not in R80_BF then
                     goto BAD;
                  end if;
               when 16#F0# =>
                  if AA not in R90_BF then
                     goto BAD;
                  end if;
               when 16#F1# .. 16#F3# =>
                  if AA not in R80_BF then
                     goto BAD;
                  end if;
               when 16#F4# =>
                  if AA not in R80_8F then
                     goto BAD;
                  end if;
               when others =>
                  goto BAD;
            end case;

            C := (C and 16#1F#);
            C := Shift_Left (C, 12);

            AA := AA and 16#3F#;
            AA := Shift_Left (AA, 0);

            C := C or AA;
            L := 2;
            goto RET;
         end if;

         if (C and 16#F0#) = 16#E0# then
            if S'Last < 3 then
               goto BAD;
            end if;

            C := (C and 16#0F#);
            C := Shift_Left (C, 12);

            AA := Character'Pos (S (S'First + 1));
            AA := AA and 16#3F#;
            AA := Shift_Left (AA, 6);

            AB := Character'Pos (S (S'First + 2));
            if AB not in R80_BF then
               goto BAD;
            end if;
            AB := AB and 16#3F#;
            AB := Shift_Left (AB, 0);

            C := C or AA or AB;
            L := 3;
            goto RET;
         end if;

         if (C and 16#F8#) = 16#F0# and C <= 16#F4# then
            if S'Last < 4 then
               goto BAD;
            end if;

            C := C and 16#07#;
            C := Shift_Left (C, 18);

            AA := Character'Pos (S (S'First + 1));
            AA := AA and 16#3F#;
            AA := Shift_Left (AA, 12);

            AB := Character'Pos (S (S'First + 2));
            if AB not in R80_BF then
               goto BAD;
            end if;
            AB := AB and 16#3F#;
            AB := Shift_Left (AB, 6);

            AC := Character'Pos (S (S'First + 3));
            if AB not in R80_BF then
               goto BAD;
            end if;
            AC := AC and 16#3F#;
            AC := Shift_Left (AB, 0);
            L := 4;
            goto RET;
         end if;

         goto BAD;
      exception
         when Constraint_Error =>
            goto BAD;
      end;

      <<RET>>
      if C >= 16#D800# and C <= 16#DFFF# then
         C := Badchr;
         return;
      end if;

      return;

      <<BAD>>
      C := Badchr;
      L := 1;
      return;
   end Get;
end Viper.UTF8;
