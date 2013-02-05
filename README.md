Heroku Nav
==========

[![Build Status](https://travis-ci.org/heroku/heroku-nav.png?branch=master)](https://travis-ci.org/heroku/heroku-nav)

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

By default the header will be inserted only in responses with status 200. You can insert it in responses with different status codes with the `:status` config param:

    config.middleware.use Heroku::Nav::Provider, :status => [200, 404]

To don't display the header on a given request path you can use the `:except` config param:

    config.middleware.use Heroku::Nav::Provider, :except => /admin/

## Meta #######################################################################

Written by Pedro Belo, with contributions from:

* Todd Matthews
* David Dollar
* Caio Chassot
* Raul Murciano
* Jonathan Dance

Released under the MIT license. http://github.com/heroku/heroku-nav
