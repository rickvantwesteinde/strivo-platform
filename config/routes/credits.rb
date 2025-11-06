# == Store Credits ==
scope module: :storefront do
  resource :credits, only: [:show], controller: :credits, path: "account/credits"
end
