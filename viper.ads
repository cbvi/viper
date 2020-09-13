pragma Restrictions (No_Exception_Propagation);

package Viper is
   pragma Pure;

   type Chr is mod 2 ** 32;
   subtype Str is String;
end Viper;
