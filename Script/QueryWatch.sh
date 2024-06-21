#!/bin/bash



#	Vars

###	If you dont need a session to query your api no need to touch these:
SessionCookie="SessionCookieValue"
SessionCookieName="SessionCookieName"

CSRF="YouCSRFToken"
CSRFHeaderName="CSRFHeaderName"

###	Where?
name="name"
path="/your/path/to/GraphQl"$name
url="https://example.com/graphql"

###	Date and how the filename syntax
d=$(date '+%Y-%m-%d-Time:%H:%M:%S')
FileName=$(echo "$d""__""$name")

#	INIT
if [ $1 == 'Init' ]; then
	mkdir $path
	mkdir $path/GraphqlChanges
	touch $path/GraphqlChanges/LatestGraphQL.txt

fi


#	Send Introspection
curl ''$url'' -H ''$CSRFHeaderName': '$CSRF'' -H 'Cookie: '$SessionCookieName'='$SessionCookie'' -H 'Content-Type: application/json' -d '{"query":"query IntrospectionQuery {\n  __schema {\n\n      types {\n      kind\n      name\n               }\n   \n        \n      }\n    }","variables":{},"operationName":"IntrospectionQuery"}' -o $path/GraphqlChanges/$FileName.txt.temp

# Format it
sed s/,/\\n/g $path/GraphqlChanges/$FileName.txt.temp > $path/GraphqlChanges/$FileName.txt
rm $path/GraphqlChanges/$FileName.txt.temp

#	Check changes
change=$(grep -xvFf $path/GraphqlChanges/$FileName.txt $path/GraphqlChanges/LatestGraphQL.txt; grep -xvFf $path/GraphqlChanges/LatestGraphQL.txt $path/GraphqlChanges/$FileName.txt)
echo "This as been added or removed : ""$change"



##	Notify + Log
if [[ $(grep "Invalid CSRF token" $path/GraphqlChanges/$FileName.txt) != '' ]]; then
	echo "$d"" : [ERROR] - "$name" session was invalidated please reset it." >> $path/logs.txt
elif [$change == ''];
then
	echo "$d"" : No changes where made to "$name" GraphQL" >> $path/logs.txt
else
	echo "$d"" : Changes detected in "$name" GraphQL" >> $path/logs.txt
	echo $change >> $path/changesAT-$d.txt
	##	Send mail (to add)

	#	Set current introspection to latest
	cp $path/GraphqlChanges/$FileName.txt $path/GraphqlChanges/LatestGraphQL.txt
fi

#	Cleaning
tooOld=$(date '+%Y-%m-%d' --date="3 days ago")
rm $path/GraphqlChanges/$tooOld*

