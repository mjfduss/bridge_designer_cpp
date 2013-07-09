module Admin::DocumentsHelper
  def editor_config
    {
        toolbarGroups: [
            {:name => 'document', :groups => %w(mode document doctools)},
            {:name => 'clipboard', :groups => %w(clipboard undo)},
            {:name => 'editing', :groups => %w(find selection spellchecker)},
            '/',
            {:name => 'basicstyles', :groups => %w(basicstyles cleanup)},
            {:name => 'paragraph', :groups => %w(list indent blocks align)},
            {:name => 'links'},
            {:name => 'insert'},
            '/',
            {:name => 'styles'},
            {:name => 'colors'},
            {:name => 'tools'},
            {:name => 'others'},
        ],
    }
  end
end