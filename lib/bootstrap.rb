
     

      Bare1Article.create(:title  =>'Hello World!',
                          :author =>'Mr Typo',
                          :body   =>'Welcome to Typo. This is your first article. Edit or delete it, then start blogging!',
                          :allow_comments => true,
                          :allow_pings    => true,
                          :published      => true,
                          :permalink      => 'hello-world',
                          :stage          => 'published')

      Bare13TextFilter.transaction do
        Bare13TextFilter.create(:name   => 'none',                 :description => 'None',
                                :markup => 'none',                 :filters     => [],             :params => {})
        Bare13TextFilter.create(:name   => 'markdown',             :description => 'Markdown',
                                :markup => "markdown",             :filters     => [],             :params => {})
        Bare13TextFilter.create(:name   => 'smartypants',          :description => 'SmartyPants',
                                :markup => 'none',                 :filters     => [:smartypants], :params => {})
        Bare13TextFilter.create(:name   => 'markdown smartypants', :description => 'Markdown with SmartyPants',
                                :markup => 'markdown',             :filters     => [:smartypants], :params => {})
        Bare13TextFilter.create(:name   => 'textile',              :description => 'Textile',
                                :markup => 'textile',              :filters     => [],             :params => {})
      end




      end
    
    end
module Typo::Bootstrap
  
  def self.setup
  end
  
  def self.initialize_profiles_and_rights
    return if Profile.count > 0
    # ------------------------------------------------------------
    # Profiles
    # ------------------------------------------------------------
    Profile.transaction do
      @admin       = Profile.create(:label    => 'admin',
                                    :nicename => 'Typo administrator',
                                    :modules  => [:dashboard, :write, :content, :feedback, :themes, :sidebar, :users, :settings, :profile])
      @publisher   = Profile.create(:label    => 'publisher',
                                    :nicename => 'Blog publisher',
                                    :modules  => [:dashboard, :write, :content, :feedback, :profile])
      @contributor = Profile.create(:label    => 'contributor',
                                    :nicename => 'Contributor',
                                    :modules  => [:dashboard, :profile])
    end

    Right.transaction do
        # --------------------------------------------------------
        # Global admin rights
        # --------------------------------------------------------
        Right.create(:name => 'admin', :description => 'Global administration', :profiles => [@admin])

        # --------------------------------------------------------
        # Article
        # --------------------------------------------------------
        Right.create(:name => 'content_create', :description => 'Create article', :profiles => [@admin, @publisher])
        Right.create(:name => 'content_edit',   :description => 'Edit article',   :profiles => [@admin, @publisher])
        Right.create(:name => 'content_delete', :description => 'Delete article', :profiles => [@admin, @publisher])

        # --------------------------------------------------------
        # Users
        # --------------------------------------------------------
        Right.create(:name => 'user_create',    :description => 'Create users',      :profiles => [@admin])
        Right.create(:name => 'user_edit',      :description => 'Edit users',        :profiles => [@admin])
        Right.create(:name => 'user_self_edit', :description => 'Edit self account', :profiles => [@admin, @publisher, @contributor])
        Right.create(:name => 'user_delete',    :description => 'Delete users',      :profiles => [@admin])

        # --------------------------------------------------------
        # Feedback
        # --------------------------------------------------------
        Right.create(:name => 'feedback_create',      :description => 'Add a comment',        :profiles => [@admin, @publisher, @contributor])
        Right.create(:name => 'feedback_self_edit',   :description => 'Edit self comments',   :profiles => [@admin, @publisher, @contributor])
        Right.create(:name => 'feedback_edit',        :description => 'Edit any comment',     :profiles, => [@admin, @publisher, @contributor])
        Right.create(:name => 'feedback_self_delete', :description => 'Delete self comments', :profiles => [@admin, @publisher, @contributor])
        Right.create(:name => 'feedback_delete',     :description => 'Delete any comment',    :profiles => [@admin, @publisher, @contributor])

        # --------------------------------------------------------
        # Page
        # --------------------------------------------------------
        Right.create(:name => 'page_create', :description => 'Create a category', :profiles => [@admin, @publisher])
        Right.create(:name => 'page_edit',   :description => 'Edit a category',   :profiles => [@admin, @publisher])
        Right.create(:name => 'page_delete', :description => 'Delete a category', :profiles => [@admin, @publisher])

        # --------------------------------------------------------
        # Category
        # --------------------------------------------------------
        Right.create(:name => 'category_create', :description => 'Create a category', :profiles => [@admin, @publisher])
        Right.create(:name => 'category_edit', :description => 'Edit a category', :profiles => [@admin, @publisher])
        Right.create(:name => 'category_delete', :description => 'Delete a category', :profiles => [@admin, @publisher])

    end
  end
end
