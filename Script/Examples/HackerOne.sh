#!/bin/bash



#	Set Vars
d=$(date '+%Y-%m-%d-Time:%H:%M:%S')
FileName=$(echo "$d""__H1GraphQL")

##	Change this
HostSession="YourHostSess"
CSRF="TOKEN"
path="/you/path"


#	INIT
if [ $1 = 'Init' ]; then
	mkdir $path/HackeroneGraphqlChanges
	touch $path/HackeroneGraphqlChanges/LatestH1GraphQL.txt

fi


#	Send Introspection
curl 'https://hackerone.com/graphql' -H 'X-Csrf-Token: '$CSRF'' -H 'Cookie: __Host-session='$HostSession'' -H 'Content-Type: application/json' -d '{"query":"query IntrospectionQuery {\n  __schema {\n\n    queryType { name }\n    mutationType { name }\n    subscriptionType { name }\n    types {\n      kind\n      name\n               }\n   \n        \n      }\n    }","variables":{},"operationName":"IntrospectionQuery"}' -o $path/HackeroneGraphqlChanges/$FileName.txt.temp

#	Format it
sed s/,/\\n/g $path/HackeroneGraphqlChanges/$FileName.txt.temp > $path/HackeroneGraphqlChanges/$FileName.txt
rm $path/HackeroneGraphqlChanges/$FileName.txt.temp

#	Check changes
change=$(grep -xvFf $path/HackeroneGraphqlChanges/$FileName.txt $path/HackeroneGraphqlChanges/LatestH1GraphQL.txt; grep -xvFf $path/HackeroneGraphqlChanges/LatestH1GraphQL.txt $path/HackeroneGraphqlChanges/$FileName.txt)
echo "This as been added or removed : ""$change"



##	Notify + Log
if [[ $(grep "Invalid CSRF token" $path/HackeroneGraphqlChanges/$FileName.txt) != '' ]]; then
	echo "$d"" : [ERROR] - Hackerone session was invalidated please reset it." >> $path/logs.txt
elif [$change == ''];
then
	echo "$d"" : No changes where made to Hackerone GraphQL" >> $path/logs.txt
else
	echo "$d"" : Changes detected in Hackerone GraphQL" >> $path/logs.txt
	echo $change >> $path/changesAT-$d.txt
	

	#	Set current introspection to latest
	cp $path/HackeroneGraphqlChanges/$FileName.txt $path/HackeroneGraphqlChanges/LatestH1GraphQL.txt
fi

#	Cleaning
tooOld=$(date '+%Y-%m-%d' --date="3 days ago")
rm $path/HackeroneGraphqlChanges/$tooOld*

