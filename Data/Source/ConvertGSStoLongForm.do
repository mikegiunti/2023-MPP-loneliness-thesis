use C:\Users\jfreese\AppData\Local\Temp\10\ARC954F\gss_panel_w2.R1.dta, clear

** PULL NAMES OF VARIABLE STUBS

foreach x of varlist * {

		local length = length("`x'") 
		local end = substr("`x'", `length', 1)
		if "`end'" == "1" {

			local lengthminus2 = `length' - 2
			local xstub = substr("`x'", 1, `lengthminus2')
			local stubs "`stubs' `xstub'_"

			display "`x' -> `xstub'"
			
		}
				
}

gen idnum = id_1

reshape long `stubs', i(idnum)

rename _j panelwave

* remove underscores

foreach x of varlist * {

		local length = length("`x'") 
		local end = substr("`x'", `length', 1)
		if "`end'" == "_" {
			local lengthminus1 = `length' - 1
			local newx = substr("`x'", 1, `lengthminus1')
			rename `x' `newx'
		}
		
}
