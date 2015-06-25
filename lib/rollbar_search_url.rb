require "rollbar_search_url/version"

module RollbarSearchUrl

  BASE_URL = "https://rollbar.com/%{user}/%{project}/rql"

  class Query

    def initialize user: "", project: ""
      raise ArgumentError if user.nil? || project.nil? || user.empty? || project.empty?
      @user     = user
      @project  = project
      @where    = []
      @select   = []
      @limit    = nil
      @order_by = ""
      @group_by = ""
    end

    def select select_statement
      @select << select_statement
    end

    def where where_statement
      @where << where_statement
    end

    def group_by group_by_statement
      @group_by = group_by_statement
    end

    def order_by order_by_statement
      @order_by = order_by_statement
    end

    def limit limit
      @limit = limit
    end

    def url
      URI.escape(BASE_URL % {user: @user, project: @project} + "?q=#{query}")
    end

    private

    def query
      statements = []
      statements << "select"
      statements << (@select.empty? ? ['*'] : @select).join(', ')
      statements << "from item_occurrence"
      statements << "where #{@where.join ' and '} " unless @where.empty?
      statements << "group by #{@group_by}" unless @group_by.empty?
      statements << "order by #{@order_by}" unless @order_by.empty?
      statements << "limit #{@limit}" unless @limit.nil?

      statements.join ' '
    end
  end
end
