Heroku Nav
==========

This is a Ruby gem providing a Rack middleware to help Heroku add-on providers
displaying a customized header for users coming from a single sign-on session.


## Usage ######################################################################

Use it just like any Rack middleware:

    require 'heroku/nav'
    use Heroku::Nav::Provider

That will fetch the latest header from our API and insert it as the first
element inside the body tag when the cookie "heroku-nav-data" is defined.

For Rails apps, add it to your Gemfile:

    gem 'heroku-nav', :require => 'heroku/nav'

And add the middleware like:

    config.middleware.use Heroku::Nav::Provider


## Meta #######################################################################

Maintained by Pedro Belo, contributions by Todd Matthews and David Dollar.

Released under the MIT license. http://github.com/heroku/heroku-nav