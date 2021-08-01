# email-filechange-notif-action
> This action allows you to notify users once a file is changed

### How To Use

For using this action, you need to create a workflow file like this: 
```yaml
name: 'Notify users on file change'
on:
  push:
    branches: [ master ]
jobs:
  notif:
    runs-on: ubuntu-latest
    steps:
      - uses: danthe1st/email-filechange-notif-action@v1
        with: 
          # Address to send E-Mails from
          senderEmail: ${{ secrets.SENDER_EMAIL }}
          # optional, The subject of the E-Mails to send
          subjectLine: 'GitHub file change notification'
          # A file in the repository or HTTP address that contains file patterns with E-Mail addresses that should be notified on file changes
          mailingList: ${{ secrets.MAILING_LIST }}
          # The SMTP server used to send E-Mails
          smtpServer: ${{ secrets.SMTP_SERVER }}
          # optional, The SMTP port used to send E-Mails
          smtpPort: 587
          # The SMTP user name used to send E-Mails
          smtpUsername: ${{ secrets.SMTP_USER }}
          # The SMTP password used to send E-Mails
          smtpPassword: ${{ secrets.SMTP_PASSWORD }}
```

This file should be located in the directory `.github/workflows` and the file ending should be `.yml`.

The secrets can be configured in the `Settings` tab of the GitHub repository under `Secrets`.

The input `mailingList` can either be the path to a file in the repository or a HTTP(s) link to such a file.
Every line in this file consists of a file pattern (gitignore format) followed by one space and an E-Mail address.
If the workflow is executed and a file matching the pattern is changed, an E-mail should be sent to the address configured.

