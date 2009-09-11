class Right < ActiveRecord::Base
  include BareMigration
end

class ProfilesRight < ActiveRecord::Base
  include BareMigration
end
     

module Typo::Bootstrap
  
  def self.setup
    if initialize_profiles_and_rights
       initialize_textfilters
       initialize_articles
    end
  end
 
  def self.teardown
    if teardown_profiels_and_rights
      teardown_texfilters
      teardown_articles
    end
  end

  protected
  def self.initialize_profiles_and_rights
    return false if Profile.count > 0
    puts "initializing profiles and rights"
    # ------------------------------------------------------------
    # Blog
    # ------------------------------------------------------------
    Blog.transaction do
      Blog.create(:base_url => 'http://localhost:3000',
                  :settings => {:blog_name              => 'My Shiny Weblog!',
                                :theme                  => 'scribbish',
                                :allow_signup           => 0,
                                :admin_displat_elements => 10,
                                :lang                   => 'en_US'})
    end
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
        right = Right.create(:name     => 'admin',  :description => 'Global administration')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)

        # --------------------------------------------------------
        # Article
        # --------------------------------------------------------
        right = Right.create(:name => 'content_create', :description => 'Create article')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @publisher.id)
        right = Right.create(:name => 'content_edit',   :description => 'Edit article')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @publisher.id)
        right = Right.create(:name => 'content_delete', :description => 'Delete article')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @publisher.id)

        # --------------------------------------------------------
        # Users
        # --------------------------------------------------------
        right = Right.create(:name => 'user_create',    :description => 'Create users')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        right = Right.create(:name => 'user_edit',      :description => 'Edit users')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        right = Right.create(:name => 'user_self_edit', :description => 'Edit self account')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @publisher.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @contributor.id)
        right = Right.create(:name => 'user_delete',    :description => 'Delete users')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)

        # --------------------------------------------------------
        # Feedback
        # --------------------------------------------------------
        right = Right.create(:name     => 'feedback_create',      :description => 'Add a comment')
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @publisher.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @contributor.id)
        right = Right.create(:name     => 'feedback_self_edit',   :description => 'Edit self comments')
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @publisher.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @contributor.id)
        right = Right.create(:name     => 'feedback_edit',        :description => 'Edit any comment')
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @publisher.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @contributor.id)
        right = Right.create(:name     => 'feedback_self_delete', :description => 'Delete self comments')
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @publisher.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @contributor.id)
        right = Right.create(:name     => 'feedback_delete',      :description => 'Delete any comment')
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @publisher.id)
        ProfilesRight.create(:right_id => right.id,               :profile_id  => @contributor.id)

        # --------------------------------------------------------
        # Page
        # --------------------------------------------------------
        right = Right.create(:name => 'page_create', :description => 'Create a category')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @publisher.id)
        right = Right.create(:name => 'page_edit',   :description => 'Edit a category')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @publisher.id)
        right = Right.create(:name => 'page_delete', :description => 'Delete a category')
        ProfilesRight.create(:right_id => right.id, :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id, :profile_id  => @publisher.id)

        # --------------------------------------------------------
        # Category
        # --------------------------------------------------------
        right = Right.create(:name     => 'category_create', :description => 'Create a category')
        ProfilesRight.create(:right_id => right.id,          :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,          :profile_id  => @publisher.id)
        right = Right.create(:name     => 'category_edit',   :description => 'Edit a category')
        ProfilesRight.create(:right_id => right.id,          :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,          :profile_id  => @publisher.id)
        right = Right.create(:name     => 'category_delete', :description => 'Delete a category')
        ProfilesRight.create(:right_id => right.id,          :profile_id  => @admin.id)
        ProfilesRight.create(:right_id => right.id,          :profile_id  => @publisher.id)
    end
    return true
  end

  def self.initialize_textfilters
    puts "initializing textfilters"
    TextFilter.transaction do
      TextFilter.create(:name   => 'none',                 :description => 'None',
                        :markup => 'none',                 :filters     => [],             :params => {})
      TextFilter.create(:name   => 'markdown',             :description => 'Markdown',
                        :markup => "markdown",             :filters     => [],             :params => {})
      TextFilter.create(:name   => 'smartypants',          :description => 'SmartyPants',
                        :markup => 'none',                 :filters     => [:smartypants], :params => {})
      TextFilter.create(:name   => 'markdown smartypants', :description => 'Markdown with SmartyPants',
                        :markup => 'markdown',             :filters     => [:smartypants], :params => {})
      TextFilter.create(:name   => 'textile',              :description => 'Textile',
                        :markup => 'textile',              :filters     => [],             :params => {})
    end
  end

  def self.initialize_articles
    puts "initializing arcticle and page"
    Article.transaction do
      @textfilter = TextFilter.find_by_name 'textile'
      Article.create(:title  => 'Hello World!',
                     :author => 'Mr Typo',
                     :body   => 'Welcome to Typo. This is your first article. Edit or delete it, then start blogging!',
                     :allow_comments => true,
                     :allow_pings    => true,
                     :published      => true,
                     :permalink      => 'hello-world',
                     :state          => 'published',
                     :text_filter_id => @textfilter.id,
                     :user_id        => 1)

      Page.create(   :title  => 'about',
                     :name   => 'about',
                     :body   => 'This is an example of a Typo page. You can edit this to write information about yourself or your site so readers know who you are. You can create as many pages as this one as you like and manage all of your content inside Typo.',
                     :published      => true,
                     :state          => 'published',
                     :text_filter_id => @textfilter.id,
                     :user_id        => 1)
    end
  end

  def self.teardown_profiels_and_rights
    return false if Profile.count <= 0
    Profile.transaction do
      Blog.destroy_all
      Profile.destroy_all
      Right.destroy_all
      ProfilesRight.destroy_all
    end
    return true
  end

  def self.teardown_texfilters
    TextFilter.destroy_all
  end

  def self.teardown_articles
    Content.destroy_all
  end
end
