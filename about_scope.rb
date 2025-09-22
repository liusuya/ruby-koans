require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutScope < Neo::Koan
  module Jims
    class Dog
      def identify
        :jims_dog
      end
    end
  end

  module Joes
    class Dog
      def identify
        :joes_dog
      end
    end
  end

  def test_dog_is_not_available_in_the_current_scope
    assert_raise(NameError) do
      Dog.new
    end
  end

  def test_you_can_reference_nested_classes_using_the_scope_operator
    fido = Jims::Dog.new
    rover = Joes::Dog.new
    assert_equal :jims_dog, fido.identify
    assert_equal :joes_dog, rover.identify

    assert_equal true, fido.class != rover.class
    assert_equal true, Jims::Dog != Joes::Dog
  end

  # ------------------------------------------------------------------

  class String
  end

  def test_bare_bones_class_names_assume_the_current_scope
    assert_equal true, AboutScope::String == String
  end

  def test_nested_string_is_not_the_same_as_the_system_string
    assert_equal false, String == "HI".class
  end

  def test_use_the_prefix_scope_operator_to_force_the_global_scope
    assert_equal true, ::String == "HI".class
  end

  # ------------------------------------------------------------------

  PI = 3.1416

  def test_constants_are_defined_with_an_initial_uppercase_letter
    assert_equal 3.1416, PI
  end

  # ------------------------------------------------------------------

  MyString = ::String
  $my_string = ::String
  $my_other_string = "String"
  # instance var, so since an instance was not create, @my_string_in_about_scope is not set???
  @my_string_in_about_scope_instance_var = ::String
  # @@ is a class var, ie, all instances of the class shares the same var
  @@my_string_in_about_scope = ::String

  # consts are class scoped but vars are locally scoped
  def test_class_names_are_just_constants
    assert_equal true, MyString == ::String
    assert_equal true, MyString == "HI".class
    assert_equal true, $my_string == "HI".class
    assert_equal "String", $my_other_string
    assert_equal nil, @my_string_in_about_scope_instance_var
    assert_equal ::String, @@my_string_in_about_scope

    # you cannot create an instance of a class inside that class. thank goodness
    # about_scope_instance = AboutScope.new("aboutScopeInstance")
    # assert_equal ::String, about_scope_instance.instance_variable_get(@my_string_in_about_scope_instance_var)

  end

  def test_constants_can_be_looked_up_explicitly
    assert_equal true, PI == AboutScope.const_get("PI")
    assert_equal true, MyString == AboutScope.const_get("MyString")
  end

  def test_you_can_get_a_list_of_constants_for_any_class_or_module
    assert_equal [:Dog], Jims.constants
    assert Object.constants.size > 0
  end
end

# will this run at the end of all the tests?
# TODO
def test_string_instance_outside_of_class
  about_scope_instance = AboutScope.new("aboutScopeInstance")
  assert_equal "String", about_scope_instance.instance_variable_get(@my_string_in_about_scope_instance_var)
end