# Override the default rails debug method to use css class debug-dump rather than debug_dump
module ActionView
  module Helpers
    module DebugHelper
      include TagHelper
      def debug(object)
        Marshal::dump(object)
        object = ERB::Util.html_escape(object.to_yaml)
        content_tag(:pre, object, class: 'debug-dump')
      rescue # errors from Marshal or YAML
        # Object couldn't be dumped, perhaps because of singleton methods -- this is the fallback
        content_tag(:code, object.inspect, class: 'debug-dump')
      end
    end
  end
end
