pragma Restrictions (No_Exception_Propagation);

package Viper is
   pragma Pure;

   type Rune is mod 2 ** 32;
   subtype Str is String;
end Viper;
