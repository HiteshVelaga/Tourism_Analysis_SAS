libname data "/folders/myfolders/ecrb94_ue/ECRB94/data";
libname outpath "/folders/myfolders/Output";

data outpath.cleaned_tourism;
	length Country_Name $50 Tourism_type $20;
	retain Country_Name "" Tourism_type "";
	set data.Tourism(drop=_1995-_2013);
	if A ne . then Country_Name=Country;
	if lowcase(Country) = "inbound tourism" then Tourism_Type = "inbound tourism";
	else if lowcase(Country) = "outbound tourism" then Tourism_Type = "outbound tourism";
	if Country_Name ne Country and lowcase(Country) ne Tourism_Type;
	series=upcase(series);
	if series=".." then series="";
	Coversion_Type=scan(Country,-1," ");
	if _2014=".." then _2014=".";
	if Coversion_Type="Mn" then do;
		if _2014 ne "." then Y2014=input(_2014,16.)*1000000;
		else Y2014=.;
		Category=cat(scan(Country,1,"-",'r'),' -USD');
	end;
	else if Coversion_Type="Thousands" then do;
		if _2014 ne "." then Y2014=input(_2014,16.)*1000;
		else Y2014=.;
		Category=scan(Country,1,"-",'r');
	end;
	format Y2014 comma25.;
	drop A Coversion_Type Country _2014;
run;

proc format;
	value contIDs
		1 = "North America"
		2 = "South America"
		3 = "Europe"
		4 = "Africa"
		5 = "Asia"
		6 = "Oceania"
		7 = "Antarctica";
run;

proc sort data=data.country_info(rename=(Country=Country_Name)) out=country_sorted;
	by country_name;
run;

data outpath.final_tourism outpath.NoCountryFound(keep=Country_Name);
	merge cleaned_tourism(in=t) country_sorted(in=c);
	by country_name;
	if t=1 and c=1 then output Final_tourism;
	if t=1 and c=0 and first.Country_Name=1 then output NoCountryFound;
	format continent contIDs.;
run;

