require 'factory_girl'

Factory.define :user do |u|
  u.login 'shingara'
  u.email 'cyril.mougel@gmail.com'
end

Factory.define :article do |a|
  a.title 'A big article'
  a.body 'A content with several data'
  a.permalink 'a-big-article'
  a.published_at Time.now
  a.user Factory.build(:user)
end

Factory.define :second_article, :parent => :article do |a|
  a.title 'Another big article'
  a.published_at Time.now - 2.seconds
end

Factory.define :article_with_accent_in_html, :parent => :article do |a|
  a.title 'article with accent'
  a.body '&eacute;coute The future is cool!'
  a.permalink 'article-with-accent'
  a.published_at Time.now - 2.seconds
end

Factory.define :pingable_and_commentable_article, :parent => :article do |f|
  f.sequence(:title) {|n| "a pingable article-#{n}"}
  f.allow_pings    true
  f.allow_comments true
  f.published      true
end

Factory.define :blog do |b|
end

Factory.define :profile_admin, :class => :profile do |l|
  l.label 'admin'
  l.nicename 'Typo administrator'
  l.modules [:dashboard, :write, :content, :feedback, :themes, :sidebar, :users, :settings, :profile]
end
Factory.define :profile_publisher, :class => :profile do |l|
  l.label 'published'
  l.nicename 'Blog publisher'
  l.modules [:dashboard, :write, :content, :feedback, :profile]
end
Factory.define :profile_contributor, :class => :profile do |l|
  l.label 'contributor'
  l.nicename 'Contributor'
  l.modules [:dashboard, :profile]
end

Factory.define :category do |c|
  c.name 'SoftwareFactory'
  c.permalink 'softwarefactory'
  c.position 1
end

Factory.define :categorization do |f|
  f.association :article, :factory => :article
  f.association :category, :factory => :category
end

Factory.define :feedback do |f|
  f.sequence(:author) {|n| "typo author-#{n}"}
  f.sequence(:body)   {|n| "nice post -#{n} general feedback"}
  f.sequence(:ip)     {|n| "255.0.0.#{rand(255-n)}"}
  f.association :article, :factory => :pingable_and_commentable_article
end

Factory.define :comment, :parent => :feedback, :class => :comment do |f|
  f.sequence(:body) {|n| "nice post -#{n} as comment"}
end

Factory.define :trackback, :parent => :feedback, :class => :trackback do |f|
  f.sequence(:blog_name) {|n| "Some Blog-#{n}"}
  f.sequence(:title)     {|n| "a blog to remember-#{n}"}
  f.sequence(:excerpt)   {|n| "...... remember... #{n}"}
  f.url "wwww.example.com"
end

