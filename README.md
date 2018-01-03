# SleepINNOVATE (https://sleepinnovate.org)

[![Build Status](https://travis-ci.org/sleepepi/sleepinnovate.org.svg?branch=master)](https://travis-ci.org/sleepepi/sleepinnovate.org)
[![Dependency Status](https://gemnasium.com/sleepepi/sleepinnovate.org.svg)](https://gemnasium.com/sleepepi/sleepinnovate.org)
[![Code Climate](https://codeclimate.com/github/sleepepi/sleepinnovate.org/badges/gpa.svg)](https://codeclimate.com/github/sleepepi/sleepinnovate.org)

Website for the [SleepINNOVATE](https://sleepinnovate.org) project.

Running on Rails 5.2+ and Ruby 2.5+.

## Installation

[Prerequisites Install Guide](https://github.com/remomueller/documentation):
Instructions for installing prerequisites like Ruby, Git, JavaScript compiler,
etc.

[Install ImageMagick](https://github.com/nsrr/www.sleepdata.org#installing-mini-magick---image-upload-resizing)

Once you have the prerequisites in place, you can proceed to install bundler
which will handle most of the remaining dependencies.

```
gem install bundler --no-document
```

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

Run Rails Server (or use Apache or nginx)

```
rails s -p80
```

Open a browser and go to: [http://localhost](http://localhost)

All done!

## Refreshing Sitemap

Edit Cron Jobs `sudo crontab -e` to run scheduled tasks.

```
SHELL=/bin/bash

# Refresh Sitemap
0 2 * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && /usr/local/rvm/gems/ruby-2.5.0/bin/bundle exec rake sitemap:refresh RAILS_ENV=production

# Import TestMyBrain CSVs
0 6 * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && /usr/local/rvm/gems/ruby-2.5.0/bin/bundle exec rake brains:nightly_import RAILS_ENV=production

# Launch Followup Events
30 6 * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && /usr/local/rvm/gems/ruby-2.5.0/bin/bundle exec rake events:followup RAILS_ENV=production

# Export Admin CSV
15,45 * * * * source /etc/profile.d/rvm.sh && cd /var/www/sleepinnovate.org && /usr/local/rvm/gems/ruby-2.5.0/bin/bundle exec rake admin:export RAILS_ENV=production
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
