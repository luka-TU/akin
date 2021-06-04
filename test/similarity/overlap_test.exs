defmodule OverlapTest do
  use ExUnit.Case

  import Akin.Similarity.Overlap, only: [compare: 3]

  test "returns nil with empty arguments" do
    assert compare("n", "naght", 2) == nil
    assert compare("night", "n", 2) == nil
    assert compare("ni", "naght", 3) == nil
    assert compare("night", "na", 3) == nil
  end

  test "returns nil with invalid arguments" do
    assert compare("", "", 1) == nil
    assert compare("abc", "", 1) == nil
    assert compare("", "abc", 1) == nil
  end

  test "returns 1 with equal arguments" do
    assert compare("abc", "abc", 1) == 1
    assert compare("abc", "abc", 2) == 1
    assert compare("abc", "abc", 3) == 1
  end

  test "returns 0 with unequal arguments" do
    assert compare("abc", "xyz", 1) == 0
    assert compare("abc", "xyz", 2) == 0
    assert compare("abc", "xyz", 3) == 0
  end

  test "return distance with valid arguments" do
    assert compare("bob", "bobman", 1) == 1
    assert compare("bob", "manbobman", 1) == 1
    assert compare("night", "nacht", 1) == 0.6
    assert compare("night", "naght", 1) == 0.8
    assert compare("context", "contact", 1) == 0.7142857142857143
    assert compare("night", "nacht", 2) == 0.25
    assert compare("night", "naght", 2) == 0.5
    assert compare("context", "contact", 2) == 0.5
    assert compare("contextcontext", "contact", 2) == 0.5
    assert compare("context", "contactcontact", 2) == 0.5
    assert compare("ht", "nacht", 2) == 1
    assert compare("xp", "nacht", 2) == 0
    assert compare("ht", "hththt", 2) == 1
    assert compare("night", "nacht", 3) == 0
    assert compare("night", "naght", 3) == 0.3333333333333333
    assert compare("context", "contact", 3) == 0.4
  end
end
