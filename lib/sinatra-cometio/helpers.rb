module Sinatra
  module CometIO
    module Helpers

      def cometio_js
        "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/cometio/cometio.js"
      end

      def cometio_url
        "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/cometio/io"
      end

    end
  end
end
