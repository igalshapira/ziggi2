[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Ziggi 2.0

Ziggi version 2 is the version current available in [http://ziggi.co.il](http:ziggi.co.il) and in [http://www.ziggi.co](http://www.ziggi.co)
It was deployed in 2013, and is no longer maintained.

See [Ziggi 3.0](https://github.com/igalshapira/ziggi3) for next version sion of Ziggi based on Nodejs.

## Info

This repository contains the full source code of Ziggi 2.0

Since I no longer wish to maintain ziggi.co.il, nor I have the time and resources to do so.

Anyone wishes to duplicate Ziggi can do it using this source code.

Ziggi was orignally deployed to [Heroku](http://www.heroku.com) and later on it was deployed on Azure VM using [Dokku](http://dokku.viewdocs.io/dokku/)

## Deploying

For using some of the advanced features you need to set several variables. See (config/application.rb)[config/application.rb]

* GOOGLE_USER and GOOGLE_KEY to allow login with google
* FACEBOOK_USER and FACEBOOK_KEY to allow login with facebook
* POSTMARK_TOKEN, POSTMARK_INBOUND_ADDRESS, POSTMARK_SMTP_SERVER, POSTMARK_API_KEY to use [Postmark](https://postmarkapp.com/) - mail service is used to send 'Forgot my password' emails.

