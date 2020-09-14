with Viper;

package Viper.UTF8 is
   pragma Pure;

   Badchr : constant Chr := Chr'Last;

   procedure Get (S : in Str; C : out Chr; L : out Natural);
end Viper.UTF8;
