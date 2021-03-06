package body Viper.UTF8 with SPARK_Mode is
   function Shift_Left (Value : Rune; Amount : Natural) return Rune;
   pragma Import (Intrinsic, Shift_Left);

   -- function Shift_Right (Value : Rune; Amount : Natural) return Rune;
   -- pragma Import (Intrinsic, Shift_Right);

   subtype Byte_Position is Integer range 1 .. 4;

   function To_Byte (S : in Str; O : in Byte_Position) return Rune
      with Pre =>
         S'Length >= O and
         S'First <= Integer'Last - (O - 1);

   function To_Byte (S : in Str; O : in Byte_Position) return Rune is
   begin
      return Character'Pos (S (S'First + (O - 1)));
   end To_Byte;

   procedure Bad (C : out Rune; L : out Integer);
   procedure Bad (C : out Rune; L : out Integer) is
   begin
      C := Badchr;
      L := 1;
   end Bad;

   procedure Ret (C : in out Rune);
   procedure Ret (C : in out Rune) is
   begin
      if C >= 16#D800# and C <= 16#DFFF# then
         C := Badchr;
      end if;
   end Ret;

   procedure Get (S : in Str; C : out Rune; L : out Natural) is

      subtype R80_BF is Viper.Rune range 16#80# .. 16#BF#;
      subtype RA0_BF is Viper.Rune range 16#A0# .. 16#BF#;
      subtype R80_9F is Viper.Rune range 16#80# .. 16#9F#;
      subtype R90_BF is Viper.Rune range 16#90# .. 16#BF#;
      subtype R80_8F is Viper.Rune range 16#80# .. 16#8F#;

      AA : Rune;
      AB : Rune;
      AC : Rune;
   begin
      if S'Length < 1 then
         Bad (C, L);
         return;
      end if;

      C := To_Byte (S, 1);
      if C < 16#80# then
         L := 1;
         return;
      end if;

      if (C and 16#E0#) = 16#C0# then
         if S'Length < 2 then
            Bad (C, L);
            return;
         end if;

         AA := To_Byte (S, 2);

         case C is
            when 16#C2# .. 16#DF# =>
               if AA not in R80_BF then
                  Bad (C, L);
                  return;
               end if;
            when 16#E0# =>
               if AA not in RA0_BF then
                  Bad (C, L);
                  return;
               end if;
            when 16#E1# .. 16#EC# =>
               if AA not in R80_BF then
                  Bad (C, L);
                  return;
               end if;
            when 16#ED# =>
               if AA not in R80_9F then
                  Bad (C, L);
                  return;
               end if;
            when 16#EE# .. 16#EF# =>
               if AA not in R80_BF then
                  Bad (C, L);
                  return;
               end if;
            when 16#F0# =>
               if AA not in R90_BF then
                  Bad (C, L);
                  return;
               end if;
            when 16#F1# .. 16#F3# =>
               if AA not in R80_BF then
                  Bad (C, L);
                  return;
               end if;
            when 16#F4# =>
               if AA not in R80_8F then
                  Bad (C, L);
                  return;
               end if;
            when others =>
               Bad (C, L);
               return;
         end case;

         C := (C and 16#1F#);
         C := Shift_Left (C, 6);

         AA := AA and 16#3F#;
         AA := Shift_Left (AA, 0);

         C := C or AA;
         L := 2;
         Ret (C);
         return;
      end if;

      if (C and 16#F0#) = 16#E0# then
         if S'Length < 3 then
            Bad (C, L);
            return;
         end if;

         C := (C and 16#0F#);
         C := Shift_Left (C, 12);

         AA := To_Byte (S, 2);
         AA := AA and 16#3F#;
         AA := Shift_Left (AA, 6);

         AB := To_Byte (S, 3);
         if AB not in R80_BF then
            Bad (C, L);
            return;
         end if;
         AB := AB and 16#3F#;
         AB := Shift_Left (AB, 0);

         C := C or AA or AB;
         L := 3;
         Ret (C);
         return;
      end if;

      if (C and 16#F8#) = 16#F0# and C <= 16#F4# then
         if S'Length < 4 then
            Bad (C, L);
            return;
         end if;

         C := C and 16#07#;
         C := Shift_Left (C, 18);

         AA := To_Byte (S, 2);
         AA := AA and 16#3F#;
         AA := Shift_Left (AA, 12);

         AB := To_Byte (S, 3);
         if AB not in R80_BF then
            Bad (C, L);
            return;
         end if;
         AB := AB and 16#3F#;
         AB := Shift_Left (AB, 6);

         AC := To_Byte (S, 4);
         if AC not in R80_BF then
            Bad (C, L);
            return;
         end if;
         AC := AC and 16#3F#;
         AC := Shift_Left (AC, 0);

         C := C or AA or AB or AC;
         L := 4;
         Ret (C);
         return;
      end if;

      Bad (C, L);
      return;
   end Get;
end Viper.UTF8;
