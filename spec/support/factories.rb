FactoryGirl.define do
  factory :shipped_order_no_user, :parent => :shipped_order do
    after(:create) do |order|
      order.user = nil
      order.save!
    end
  end
end
