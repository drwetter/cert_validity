# cert_validity
Small hackish script to monitor expiration time

### prerequisites
* bash
* openssl 
* awk

### usage

* cert_validity.sh <hostname> (port 443 assumed)
* cert_validity.sh <hostname:port>

It would then warn if the expiry date is lower than "1 2 3 5 10 15 30" days, that means on the 29th day, 14th day, 9th day,... ahead of expiration time.

If you don't like this you can supply another sequence as a second argument -- mind the quotes:

```
prompt> ./cert_validity.sh testssl.sh "2 3 5 7 10 15 80"
Certificate from "testssl.sh:443" expires in < 100 days
 --> at Dec  6 12:59:34 2020 GMT
prompt> 
```

### cron
You should best not run this manually but in a crontab like

```
42 22 * * * MAILTO=recipient@example.com <PATH>/cert_validity.sh testssl.sh "1 2 3 4 5 6 8 9 10 11 12 13 14 15"
```

MAILTO is only needed when the owner's crontab mail is ending up where you don't intended it.
