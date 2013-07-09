module Paperclip
  class StringAdapter < AbstractAdapter
    def initialize(target)
      @target = target
      cache_current_values
      @tempfile = copy_to_tempfile(@target)
    end

    attr_writer :content_type

    private

    def cache_current_values
      @original_filename = @target.original_filename if @target.respond_to?(:original_filename)
      @original_filename ||= 'string.txt'
      self.original_filename = @original_filename.strip

      @content_type = @target.content_type if @target.respond_to?(:content_type)
      @content_type ||= 'text/plain'

      @size = @target.size
    end

    def copy_to_tempfile(src)
      destination.write(src)
      destination.rewind
      destination
    end

  end
end

Paperclip.io_adapters.register Paperclip::StringAdapter do |target|
  String === target
end