FactoryGirl.define do
  factory :seo_page do
    title "this is a test"
    slug  nil
  end

  # This will use the User class (Admin would have been guessed)
  factory :seo_post do
    another_title "this is a test"
    slug  nil
  end
end