Comet Chat
==========

* Ruby 1.8.7+ or 1.9.2+
* Sinatra 1.3+


Install Dependencies
--------------------

    % gem install bundler foreman
    % bundle install


Run
---

    % foreman start

=> http://localhost:5000


Deploy
------

    % heroku create --stack cedar
    % git push heroku master
    % heroku open
