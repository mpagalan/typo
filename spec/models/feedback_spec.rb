require File.dirname(__FILE__) + '/../spec_helper'

describe Feedback do
  before do
  end
end

describe Feedback, "on named scopes " do
  before(:each) do
    Feedback.delete_all #NB: remove all objects since fixtures are used in parallel
    @spam_comment          = Factory(:comment,   :created_at => 1.day.ago, :state => 'spam')
    @published_comment     = Factory(:comment,   :created_at => 2.day.ago, :state => 'ham', :published => true)
    @published_trackback   = Factory(:trackback, :created_at => 3.day.ago, :state => 'ham', :published => true)
    @unconfirmed_trackback = Factory(:trackback, :created_at => 4.day.ago, :state => 'presumed_ham')
    @unconfirmed_comment   = Factory(:comment,   :created_at => 5.day.ago, :state => 'presumed_ham')
  end

  describe "#most_recent" do
    it "should return all feedbacks ordered by most recent" do
      Feedback.most_recent == [@spam_comment, @published_comment, @published_trackback, @unconfirmed_trackback, @unconfirmed_comment]
    end
  end

  describe "#unconfirmed" do
    it "should return all unconfirmed feedbacks" do
      Feedback.unconfirmed.should == [@unconfirmed_trackback, @unconfirmed_comment]
    end
  end

  describe "#unpublished" do
    before(:each) do
      @unpublished_comment   = Factory(:comment,   :published => false, :state => 'spam')
      @unpublished_trackback = Factory(:trackback, :published => false, :state => 'presumed_spam')
    end

    it "should return all unpublished feedbacks" do
      Feedback.unpublished.should == [@spam_comment, @unpublished_comment, @unpublished_trackback]
    end
  end

  describe "#hams" do
    before(:each) do
      @author_search = Factory(:comment,   :author => "James Stewart")
      @url_search    = Factory(:comment,   :url    => "typo.blog.com")
      @title_search  = Factory(:trackback, :title  => 'related post in hello world')
      @ip_search     = Factory(:comment,   :ip     => "192.168.241.1")
      @email_search  = Factory(:trackback, :email  => 'emil_stewart@example.com')
    end

    it "should return feedbacks with simillar author of eg: 'James'" do
      Feedback.search('James').should == [@author_search]
    end

    it "should return feedbacks with simillar url of eg: 'typo.blog.com'" do
      Feedback.search('typo.blog.com').should == [@url_search]
    end

    it "should return feedbacks with simillar title of eg: 'hello world'" do
      Feedback.search('hello world').should == [@title_search]
    end

    it "should return feedbacks with simillar ip of eg: '192.168.241'" do
      Feedback.search('192.168.241').should == [@ip_search]
    end

    it "should return feedback with simillar email of eg: 'emil_stewart@example.com'" do
      Feedback.search('emil_stewart@example.com').should == [@email_search]
    end
  end
end
