# spec/factories/products.rb
FactoryBot.define do
  factory :product, class: 'Spree::Product' do
    sequence(:name) { |n| "Product #{n}" }
    price { 10.0 }
    available_on { Time.current }

    # Ensure a master variant exists for Spree product
    after(:build) do |product|
      product.master ||= build(:variant, product: product)
    end
  end

  factory :variant, class: 'Spree::Variant' do
    price { 10.0 }
    sku { "SKU-#{SecureRandom.hex(4)}" }
    association :product
  end
end
