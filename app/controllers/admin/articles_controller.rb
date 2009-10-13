class Admin::ArticlesController < Admin::BaseController

  layout "administration", :except => [:show, :autosave]
  cache_sweeper :blog_sweeper
  
  def index
    @drafts = Article.draft.all
    setup_categories
    @search = params[:search] ? params[:search] : {}
    @articles = Article.search_without_drafts(@search).paginate( :page => params[:page], :per_page => this_blog.admin_display_elements)
    
    if request.xhr?
      render :partial => 'list', :object => @articles
    else
      @article = Article.new(params[:article])
    end
  end

  def new 
    @article = Article.new(:allow_comments => this_blog.default_allow_comments,
                           :allow_pings    => this_blog.default_allow_pings,
                           :text_filter    => current_user.text_filter,
                           :published      => false)
    load_needed_objects
  end
  
  def create
    @article = Article.new(params[:article])
    update_state_as_needed
    set_article_author
    unless params[:auto_save]
      if @article.save
        set_article_categories
        save_attachments
      end
      return redirect_to admin_articles_url
    else #auto_save is called from the client
      auto_save
    end
  end
  
  def edit
    @article = Article.find(params[:id])
    @selected = @article.category_ids
    
    unless @article.access_by? current_user 
      redirect_to :action => 'index'
      flash[:error] = _("Error, you are not allowed to perform this action")
      return
    end
    load_needed_objects
    render :action => 'new'
  end


  def update
    @article = Article.find(params[:id])
    unless @article.access_by? current_user 
      redirect_to :action => 'index'
      flash[:error] = _("Error, you are not allowed to perform this action")
      return
    end
    @article.attributes = params[:article]
    update_state_as_needed
    set_article_author
    unless params[:auto_save]
      if @article.save
        set_article_categories
        save_attachments
      end
      redirect_to admin_articles_url
    else
      auto_save
    end
  end

  def destroy
    @article = Article.find(params[:id])
    
    unless @article.access_by?(current_user)
      flash[:error] = _("Error, you are not allowed to perform this action")
      return redirect_to admin_articles_url
    end
    
    @article.destroy
    redirect_to admin_articles_url
  end
  
  def insert_editor
    return unless params[:editor].to_s =~ /simple|visual/
    current_user.editor = params[:editor].to_s
    current_user.save!
    
    render :partial => "admin/shared/#{params[:editor].to_s}_editor"
  end

  def attachment_box_add
    render :update do |page|
      page["attachment_add_#{params[:id]}"].remove
      page.insert_html :bottom, 'attachments',
          :partial => 'admin/articles/attachment',
          :locals => { :attachment_num => params[:id], :hidden => true }
      page.visual_effect(:toggle_appear, "attachment_#{params[:id]}")
    end
  end

  def auto_complete_for_keywords
    @items = Tag.find_with_char params[:article][:keywords].strip
    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end

  # NB: remove previous implementation of resource to trade with code readability and maintainability
  def update_resource
    @article = Article.find(params[:id])
    setup_resources
    @resource = Resource.find(params[:resource_id])
    case request.method
    when :put
      @article.resources<< @resource
    when :delete
      @article.resources.delete @resource
    end
    render :partial => 'show_resources'
  end
  
  private
  
  def setup_categories
    @categories = Category.find(:all, :order => 'UPPER(name)')
  end

  def setup_resources
    @resources = Resource.find(:all, :order => 'filename')
  end

  def load_needed_objects
    @drafts  = Article.drafts
    @macros  = TextFilter.available_filters.select { |filter| TextFilterPlugin::Macro > filter }
    setup_resources
    setup_categories
  end

  # this will be called on both create and update actions
  def auto_save
    if @article.save
      return render(:update) do |page|
        page.replace_html('permalink', text_field('article', 'permalink'))
        page << "$$('.autosave').each(function(e){ e.writeAttribute( 'action', '#{admin_article_path(:id => @article.id)}')})"
      end
    end
    render :text => nil
  end
  
  def set_article_categories
    @article.categorizations.clear
    if params[:categories]
      begin
        @article.categories = Category.find(params[:categories])
      rescue
      end
    end
    @selected = params[:categories] || []
  end
  
  def save_attachments
    return if params[:attachments].nil?
    params[:attachments].each do |k,v|
      a = attachment_save(v)
      @article.resources << a unless a.nil?
    end
  end
  
  def attachment_save(attachment)
    begin
      Resource.create(:filename => attachment.original_filename,
                      :mime => attachment.content_type.chomp, :created_at => Time.now).write_to_disk(attachment)
    rescue => e
      logger.info(e.message)
      nil
    end
  end
  
  def set_article_author
    return if @article.author
    @article.author = current_user.login
    @article.user   = current_user
  end

  def set_article_title_for_autosave
    lastid = Article.find(:first, :order => 'id DESC').id
    @article.title = @article.title.blank? ? "Draft article " + lastid.to_s : @article.permalink = @article.stripped_title
  end

  def update_state_as_needed
    if params[:draft]
      if @article.state.to_s || @article.draft?
        @article.published = false
        @article.state = "draft"
      end
    end
  end
end
