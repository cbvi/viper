pragma SPARK_Mode (On);

with Viper;

package Viper.UTF8 is
   pragma Pure;

   Badchr : constant Rune := Rune'Last;

   procedure Get (S : in Str; C : out Rune; L : out Natural);
end Viper.UTF8;
