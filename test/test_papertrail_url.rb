require 'minitest_helper'

class TestRollbarSearchUrl < Minitest::Test
  def setup
    @user = random_text
    @project = random_text
    @limit = random_number
    @group_by = random_text
    @order_by = random_text
    @query = RollbarSearchUrl::Query.new user: @user, project: @project
  end

  def test_that_it_has_a_version_number
    refute_nil ::RollbarSearchUrl::VERSION
  end

  def test_it_throws_exception_without_user_and_project
    assert_raises ArgumentError do
      RollbarSearchUrl::Query.new user:@user
    end
    assert_raises ArgumentError do
      RollbarSearchUrl::Query.new project:@project
    end
  end

  def test_it_should_start_with_base_url
    assert_match /^https:\/\/rollbar.com\/#{@user}\/#{@project}\/rql\?q=/, @query.url
  end

  def test_it_selects_all_columns_from_item_occurence_by_default
    assert_includes @query.url, escape("select * from item_occurrence")
  end

  #SELECT TESTS

  def test_it_supports_multiple_select_statements
    @query.select("column1")
    @query.select("column2")
    assert_includes @query.url, escape("select column1, column2")
  end

  # WHERE TESTS
  def test_it_contains_no_where_if_not_specified
    refute_includes @query.url, "where"
  end

  def test_it_supports_multiple_where_statements
    where_statement1 = "#{random_text} = #{random_text}"
    where_statement2 = "#{random_text} = #{random_text}"
    @query.where(where_statement1)
    @query.where(where_statement2)
    assert_includes @query.url, escape("where #{where_statement1} and #{where_statement2}")
  end

  # LIMIT TESTS

  def test_it_supports_limiting_result_size
    @query.limit(@limit)
    assert_includes @query.url, escape("limit #{@limit}")
  end

  # GROUP BY TESTS

  def test_it_supports_group_by
    @query.group_by(@group_by)
    assert_includes @query.url, escape("group by #{@group_by}")
  end

  # ORDER BY TESTS

  def test_it_supports_order_by
    @query.order_by(@order_by)
    assert_includes @query.url, escape("order by #{@order_by}")
  end

  private

  def random_text
    SecureRandom.hex
  end

  def random_number
    SecureRandom.random_number
  end

  def escape string
    URI.escape string
  end
end
