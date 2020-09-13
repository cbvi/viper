with Viper;

package Viper.UTF8 is
   pragma Pure;

   Badchr : constant Chr := 16#FFFD#;

   procedure Get (S : in Str; C : out Chr; L : out Natural);
end Viper.UTF8;
