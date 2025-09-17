require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutBlocks < Neo::Koan
  def method_with_block
    result = yield
    result
  end

  def test_methods_can_take_blocks
    yielded_result = method_with_block { 1 + 2 }
    assert_equal 3, yielded_result
  end

  def test_blocks_can_be_defined_with_do_end_too
    yielded_result = method_with_block do
      1 + 2
    end
    assert_equal 3, yielded_result
  end

  # ------------------------------------------------------------------

  def method_with_block_arguments
    yield("Jim")
  end

  def test_blocks_can_take_arguments
    method_with_block_arguments do |argument|
      assert_equal "Jim", argument
    end
  end

  # ------------------------------------------------------------------

  def many_yields
    yield(:peanut)
    yield(:butter)
    yield(:and)
    yield(:jelly)
  end

  def test_methods_can_call_yield_many_times
    result = []

    # ok, so here, many_yields has access to the result var
    many_yields { |item| result << item }
    assert_equal [:peanut, :butter, :and, :jelly], result
  end

  # ------------------------------------------------------------------

  def yield_tester
    if block_given?
      yield
    else
      :no_block
    end
  end

  def test_methods_can_see_if_they_have_been_called_with_a_block
    assert_equal :with_block, yield_tester { :with_block }
    assert_equal :no_block, yield_tester
  end

  # ------------------------------------------------------------------

  # what... this makes no sense. why is value affected by whats called in a block

  # the block "remembers" its original scope, it can directly access and reassign the value variable
  # i wonder if its similar to like a nameless {}

  # in other news, just blew my mind that var and let behave differently in js
  # var is function scoped while let is block scoped, which can be seen in a for loop with an
  # async function (like button.click()). Since var is function-scoped, and synchronous, when the
  # code runs, it goes through all the loops and doesnt wait for the actual even. for with let is
  # different. wild
  #
  def test_block_can_affect_variables_in_the_code_where_they_are_created
    value = :initial_value
    method_with_block { value = :modified_in_a_block }
    assert_equal :modified_in_a_block, value
  end

  def test_blocks_can_be_assigned_to_variables_and_called_explicitly
    add_one = lambda { |n| n + 1 }
    assert_equal 11, add_one.call(10)

    # Alternative calling syntax

    # i dont like this one. its confusing cuz its not clear that add_one is a function
    assert_equal 11, add_one[10]
  end

  def test_stand_alone_blocks_can_be_passed_to_methods_expecting_blocks
    #   def method_with_block_arguments
    #     yield("Jim")
    #   end

    make_upper = lambda { |n| n.upcase }
    result = method_with_block_arguments(&make_upper)
    assert_equal "JIM", result
  end

  def multiply_2(param_var)
    yield(param_var * 2)
  end

  # this shows that the block that's passed in acts on the yielded value of
  # the method thats called. eg multiply_2 is run first, then add_one
  def test_order_of_call
    add_one = lambda { |n| n + 1 }
    assert_equal 47, multiply_2(23, &add_one)
  end

  # ------------------------------------------------------------------

  def method_with_explicit_block(&block)
    block.call(10)
  end

  def test_methods_can_take_an_explicit_block_argument
    assert_equal 20, method_with_explicit_block { |n| n * 2 }

    add_one = lambda { |n| n + 1 }
    assert_equal 11, method_with_explicit_block(&add_one)
  end

end
