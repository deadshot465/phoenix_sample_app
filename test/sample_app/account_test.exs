defmodule SampleApp.AccountTest do
  use SampleApp.DataCase, async: true

  @valid_attrs %{
    name: "Joseph",
    email: "joseph@example.com",
    password: "abcdef",
    password_confirmation: "abcdef"
  }

  @invalid_attrs %{}

  alias SampleApp.Account

  test "with valid data inserts a new user" do
    assert {:ok, %Account.User{id: id} = user} = Account.register_user(@valid_attrs)
    assert user.name == "Joseph"
    assert user.email == "joseph@example.com"
    assert [%Account.User{id: ^id}] = Account.list_users()
  end

  test "with invalid data does not insert user" do
    assert {:error, _changeset} = Account.register_user(@invalid_attrs)
    assert Account.list_users() == []
  end

  test "enforces unique emails" do
    assert {:ok, %Account.User{id: id}} = Account.register_user(@valid_attrs)
    assert {:error, changeset} = Account.register_user(@valid_attrs)

    assert %{email: ["has already been taken"]} = errors_on(changeset)
    assert [%Account.User{id: ^id}] = Account.list_users()
  end

  test "does not accept a name that is too short" do
    attrs = %{@valid_attrs | name: "ab"}
    assert {:error, changeset} = Account.register_user(attrs)

    assert %{name: ["should be at least 3 character(s)"]} = errors_on(changeset)
    assert Account.list_users() == []
  end

  test "does not accept a name that is too long" do
    attrs = %{@valid_attrs | name: String.duplicate("a", 60)}
    assert {:error, changeset} = Account.register_user(attrs)

    assert %{name: ["should be at most 50 character(s)"]} = errors_on(changeset)
    assert Account.list_users() == []
  end

  test "does not accept an email that is too short" do
    attrs = %{@valid_attrs | email: "ab@ab.com"}
    assert {:error, changeset} = Account.register_user(attrs)

    assert %{email: ["should be at least 10 character(s)"]} = errors_on(changeset)
    assert Account.list_users() == []
  end

  test "does not accept an email that is too long" do
    attrs = %{
      @valid_attrs
      | email: "#{String.duplicate("a", 150)}@#{String.duplicate("a", 150)}.com"
    }

    assert {:error, changeset} = Account.register_user(attrs)

    assert %{email: ["should be at most 255 character(s)"]} = errors_on(changeset)
    assert Account.list_users() == []
  end

  test "requires password to be at least 6 characters long" do
    attrs = %{@valid_attrs | password: "abcd"}
    assert {:error, changeset} = Account.register_user(attrs)

    assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    assert Account.list_users() == []
  end

  test "does not accept a password that is too long" do
    attrs = %{@valid_attrs | password: String.duplicate("a", 150)}
    assert {:error, changeset} = Account.register_user(attrs)

    assert %{password: ["should be at most 100 character(s)"]} = errors_on(changeset)
    assert Account.list_users() == []
  end

  describe "authenticate/2" do
    @password "123456"

    alias SampleApp.TestHelpers

    setup do
      {:ok,
       %{user: TestHelpers.user_fixture(password: @password, password_confirmation: @password)}}
    end

    test "returns user with correct password and email", %{user: user} do
      assert {:ok, auth_user} = Account.authenticate(user.email, @password)
      assert auth_user.id == user.id
    end

    test "returns unauthorized error with incorrect password and email", %{user: user} do
      assert {:error, :unauthorized} = Account.authenticate(user.email, "111111")
    end

    test "returns not_found error with no matching email and password" do
      assert {:error, :not_found} = Account.authenticate("john@example.com", @password)
    end
  end

  describe "remember_user/2" do
    setup do
      {:ok, %{user: user_fixture()}}
    end

    test "returns a user with a remember digest if remember_me is checked", %{user: user} do
      {:ok, %Account.User{} = user, token} = Account.remember_user(user, %{remember_me: true})
      assert user.remember_digest != nil
      assert String.length(user.remember_digest) > 0
      assert String.length(token) > 0
    end

    test "returns a user with no remember digest when remember_me is not checked", %{user: user} do
      {:ok, %Account.User{} = user, token} = Account.remember_user(user, %{remember_me: false})
      refute user.remember_digest
      assert token == ""
    end
  end
end
