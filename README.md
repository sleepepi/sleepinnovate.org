# SleepINNOVATE (https://sleepinnovate.org)

[![Build Status](https://travis-ci.com/sleepepi/sleepinnovate.org.svg?branch=master)](https://travis-ci.com/sleepepi/sleepinnovate.org)
[![Code Climate](https://codeclimate.com/github/sleepepi/sleepinnovate.org/badges/gpa.svg)](https://codeclimate.com/github/sleepepi/sleepinnovate.org)

Website for the [SleepINNOVATE](https://sleepinnovate.org) project.

Running on Rails 6.1+ and Ruby 3.0+.

## Installation

[Prerequisites Install Guide](https://github.com/remomueller/documentation):
Instructions for installing prerequisites like Ruby, Git, JavaScript compiler,
etc.

[Install ImageMagick](https://github.com/nsrr/www.sleepdata.org#installing-mini-magick---image-upload-resizing)

This readme assumes the following installation directory: /var/www/sleepinnovate.org

```
cd /var/www

git clone https://github.com/sleepepi/sleepinnovate.org.git

cd sleepinnovate.org

bundle install
```

Install default configuration files for database connection, email server
connection, server url, and application name.

```
ruby lib/initial_setup.rb

rails db:migrate RAILS_ENV=production

rails assets:precompile RAILS_ENV=production
```

Run Rails server.

```
rails s
```

Open a browser and go to: http://localhost:3000

All done!

## Refreshing Sitemap

Edit Cron Jobs `sudo crontab -e` to run scheduled tasks.

```
SHELL=/bin/bash

# Refresh Sitemap
0 2 * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && rvm 3.0.2 && rails sitemap:refresh RAILS_ENV=production

# Import TestMyBrain CSVs
0 6 * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && rvm 3.0.2 && rails brains:nightly_import RAILS_ENV=production

# Launch Followup Events
30 6 * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && rvm 3.0.2 && rails events:followup RAILS_ENV=production

# Export Admin CSV
15,45 * * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && rvm 3.0.2 && rails admin:export RAILS_ENV=production
```

## Contributing to SleepINNOVATE

- Check out the latest master to make sure the feature hasn't been implemented
  or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it
  and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a
  future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to
  have your own version, or is otherwise necessary, that is fine, but please
  isolate to its own commit so I can cherry-pick around it.

## License

SleepINNOVATE is released under the [MIT License](http://www.opensource.org/licenses/MIT).
