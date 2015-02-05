# fakesmtp-app
This is a very simple development tool for snooping SMTP connections to a fake mail server on Mac OS X.

In many cases you can just use Python instead to create a dummy SMTP server for testing outgoing mail during development:

~~~
sudo python -m smtpd -n -c DebuggingServer localhost:25
~~~

The main difference between the two is that FakeSMTP also shows the bidirectional commands and reply codes of the SMTP transaction, as well as the message source.

## TODO

* Update build files to the latest XCode
* Convert from Obj-C to Swift
