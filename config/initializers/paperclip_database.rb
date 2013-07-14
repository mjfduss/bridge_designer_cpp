module Paperclip
  module Storage
    module Database

      def self.extended(base)
        base.instance_eval do
          setup_paperclip_files_model
          override_default_options base
        end
        Paperclip.interpolates(:database_path) do |attachment, style|
          attachment.database_path(style)
        end
        Paperclip.interpolates(:relative_root) do |attachment, style|
          begin
            if ActionController::AbstractRequest.respond_to?(:relative_url_root)
              relative_url_root = ActionController::AbstractRequest.relative_url_root
            end
          rescue NameError
          end
          if !relative_url_root && ActionController::Base.respond_to?(:relative_url_root)
            ActionController::Base.relative_url_root
          end
        end
        ActiveRecord::Base.logger.info("[paperclip] Database Storage Initalized.")
      end

      def setup_paperclip_files_model
        @paperclip_files = "#{instance.class.name.gsub('::', 'ModulePathSeparator').underscore}_#{name.to_s}_paperclip_files"
        if !Object.const_defined?(@paperclip_files.classify)
          @paperclip_file = Object.const_set(@paperclip_files.classify, Class.new(::ActiveRecord::Base))
          @paperclip_file.table_name = @options[:database_table] || name.to_s.pluralize
          @paperclip_file.validates_uniqueness_of :style, :scope => instance.class.table_name.classify.underscore + '_id'
          case Rails::VERSION::STRING
            when /^2/
              @paperclip_file.named_scope :file_for, lambda {|style| { :conditions => ['style = ?', style] }}
            else # 3.x
              @paperclip_file.scope :file_for, lambda {|style| @paperclip_file.where('style = ?', style) }
          end
        else
          @paperclip_file = Object.const_get(@paperclip_files.classify)
        end
        @database_table = @paperclip_file.table_name
        #FIXME: This fails when using  set_table_name "<myname>" in your model
        #FIXME: This should be fixed in ActiveRecord...
        instance.class.has_many @paperclip_files, :foreign_key => instance.class.table_name.classify.underscore + '_id'
      end
      private :setup_paperclip_files_model

      def copy_to_local_file(style, dest_path)
        File.open(dest_path, 'wb+'){|df| to_file(style).tap{|sf| File.copy_stream(sf, df); sf.close;sf.unlink} }
      end

      def override_default_options(base)
        if @options[:url] == base.class.default_options[:url]
          @options[:url] = ":relative_root/:class/:attachment/:id?style=:style"
        end
        @options[:path] = ":database_path"
      end
      private :override_default_options

      def database_table
        @database_table
      end

      def database_path(style)
        paperclip_file = file_for(style)
        if paperclip_file
          "#{database_table}(id=#{paperclip_file.id},style=#{style.to_s})"
        else
          "#{database_table}(id=new,style=#{style.to_s})"
        end
      end

      def exists?(style = default_style)
        if original_filename
          !file_for(style).nil?
        else
          false
        end
      end

      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file(style = default_style)
        if @queued_for_write[style]
          @queued_for_write[style]
        elsif exists?(style)
          tempfile = Tempfile.new instance_read(:file_name)
          tempfile.binmode
          tempfile.write file_contents(style)
          tempfile.flush
          tempfile.rewind
          tempfile
        else
          nil
        end

      end
      alias_method :to_io, :to_file

      def file_for(style)
        db_result = instance.send("#{@paperclip_files}").send(:file_for, style.to_s).to_ary
        raise RuntimeError, "More than one result for #{style}" if db_result.size > 1
        db_result.first
      end

      def file_contents(style)
        file_for(style).file_contents
      end

      def flush_writes
        ActiveRecord::Base.logger.info("[paperclip] Writing files for #{name}")
        @queued_for_write.each do |style, file|
          ActiveRecord::Base.logger.info("[paperclip] instance=#{instance.inspect}.@paperclip_files=#{@paperclip_files}")
          paperclip_file = instance.send(@paperclip_files).send(:find_or_create_by_style, style.to_s)
          paperclip_file.file_contents = file.read
          paperclip_file.save!
          instance.reload
        end
        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        ActiveRecord::Base.logger.info("[paperclip] Deleting files for #{name}")
        @queued_for_delete.uniq! ##This is apparently necessary for paperclip v 3.x
        @queued_for_delete.each do |path|
          /id=([0-9]+)/.match(path)
          if @options[:cascade_deletion] && !instance.class.exists?(instance.id)
            raise RuntimeError, "Deletion has not been done by through cascading." if @paperclip_file.exists?($1)
          else
            @paperclip_file.destroy $1
          end
        end
        @queued_for_delete = []
      end

      module ControllerClassMethods
        def self.included(base)
          base.extend(self)
        end
        def downloads_files_for(model, attachment, options = {})
          define_method("#{attachment.to_s.pluralize}") do
            model_record = Object.const_get(model.to_s.camelize.to_sym).find(params[:id])
            style = params[:style] ? params[:style] : 'original'
            send_data model_record.send(attachment).file_contents(style),
                      :filename => model_record.send("#{attachment}_file_name".to_sym),
                      :type => model_record.send("#{attachment}_content_type".to_sym)
          end
        end
      end
    end
  end
end