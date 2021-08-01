#!/bin/bash
set -e

workspaceDir="$GITHUB_WORKSPACE"
before="$(jq -r ".before" "$GITHUB_EVENT_PATH")"
after="$(jq -r ".after" "$GITHUB_EVENT_PATH")"

mailingList="$1"
senderEmail="$2"
subjectLine="$3"
smtpServer="$4"
smtpPort="$5"
smtpUsername="$6"
smtpPassword="$7"
githubToken="$8"

if [ -z "$before" ]; then
	echo 'Not a push event'
	cat "$GITHUB_EVENT_PATH"
	exit 1
fi

if [ -z "$after" ]; then
	echo 'Not a push event'
	cat "$GITHUB_EVENT_PATH"
	exit 1
fi
gitUrl="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
if [ -n $githubToken ]; then
	gitUrl="https://PAT:$githubToken@$(echo "$gitUrl"|cut -d'/' -f3- )"
fi
git clone "$gitUrl" /tmp/repo
cd /tmp/repo

if [[ "$mailingList" == *"://"* ]]; then
	mailingListContent="$(curl "$mailingList")"
else
	mailingListContent="$(cat "$mailingList")"
fi

changes="$(git diff --name-only "$before" "$after")"
declare -a toNotify

mkdir /tmp/validate
cd /tmp/validate
git init

while read -r mailingListEntry; do
	filePattern="$(echo "$mailingListEntry"|cut -d' ' -f1)"
	email="$(echo "$mailingListEntry"|cut -d' ' -f2)"
	echo "$filePattern" > .gitignore
	set +e
	git check-ignore --no-index $changes
	ignoreResult=$?
	set -e
	if [ $ignoreResult -eq 0 ]; then
		if [[ ! " ${toNotify[@]} " =~ " ${email} " ]]; then
			if [[ "$email" != -* ]]; then
				toNotify+=("$email")
			fi
		fi
	fi
done <<< $mailingListContent
message="The following files in the repository $GITHUB_REPOSITORY have been changed: "

for change in $changes; do
	message="$message\n$change"
done

message="$message\n\nYou can view the changes using this link: $(jq -r ".compare" "$GITHUB_EVENT_PATH")"

if [ ${#toNotify} -ne 0 ]; then
	sendemail -f "$senderEmail" -bcc "${toNotify[@]}" -u "$subjectLine" -m "$message" -s "$smtpServer:$smtpPort" -o tls=yes -xu "$smtpUsername" -xp "$smtpPassword"
fi

